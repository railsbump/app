# frozen_string_literal: true

require "securerandom"

class CheckOutWorkerRepo < Baseline::Service
  REPO = "git@github.com:railsbump/checker.git"
  TMP  = Rails.root.join("tmp")

  WorkerRepoCheckedOut = Class.new(Error)

  def call
    hostname = Socket.gethostname
    if hostname.blank?
      raise Error, "Could not determine hostname."
    end
    cache_key = [
      "worker_repo_checked_out_since",
      hostname
    ].join(":")
    if worker_repo_checked_out_since = Kredis.redis.get(cache_key)&.then(&Time.zone.method(:parse))
      if worker_repo_checked_out_since < 10.minutes.ago
        ReportError.call "Worker repo seems to be checked out for a long time already.",
          worker_repo_checked_out_since: worker_repo_checked_out_since
      end
      if Sidekiq.server?
        unless @_call_args && @_call_kwargs
          raise "@_call_args or @_call_kwargs are nil."
        end
        self.class.call_in 30.seconds, *@_call_args, **@_call_kwargs
      end
      raise WorkerRepoCheckedOut
    else
      Kredis.redis.set(cache_key, Time.current.iso8601)
    end

    dir = TMP.join("railsbump_checker_#{SecureRandom.hex(3)}")

    if dir.exist?
      raise Error, "Dir #{dir} exists already."
    end

    ssh_key = ENV["SSH_KEY"]&.dup
    if ssh_key.present?
      ssh_key_file = TMP.join("ssh_key")
      unless ssh_key_file.exist?
        unless ssh_key[-1] == "\n"
          ssh_key << "\n"
        end
        File.write ssh_key_file, ssh_key
        File.chmod 0600, ssh_key_file
      end
      ENV["GIT_SSH_COMMAND"] = "ssh -o StrictHostKeyChecking=no -i #{ssh_key_file}"
    end

    git = 5.tries on: Git::GitExecuteError, delay: 1 do
      Git.clone REPO, dir
    end

    git.config "user.name",  "RailsBump"
    git.config "user.email", "hello@railsbump.org"

    git.checkout "main"

    yield git
  ensure
    Kredis.redis.del cache_key
    if git && File.exist?(git.dir.path)
      FileUtils.rm_rf git.dir.path
    end
  end
end
