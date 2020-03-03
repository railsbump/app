require 'securerandom'

class CheckOutGitRepo < Services::Base
  REPO = 'git@github.com:manuelmeurer/railsbump-checker.git'
  TMP  = Rails.root.join('tmp')

  def call
    dir = TMP.join("railsbump_checker_#{SecureRandom.hex(3)}")

    if dir.exist?
      raise Error, "Dir #{dir} exists already."
    end

    ssh_key = ENV['SSH_KEY']&.dup
    if ssh_key.present?
      ssh_key_file = TMP.join('ssh_key')
      unless ssh_key_file.exist?
        unless ssh_key[-1] == "\n"
          ssh_key << "\n"
        end
        File.write ssh_key_file, ssh_key
        File.chmod 0600, ssh_key_file
      end
      ENV['GIT_SSH_COMMAND'] = "ssh -o StrictHostKeyChecking=no -i #{ssh_key_file}"
    end

    Git.clone(REPO, dir).tap do |git|
      git.config 'user.name',  'RailsBump Checker'
      git.config 'user.email', 'hello@railsbump.org'

      git.checkout
    end
  end
end
