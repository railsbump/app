require 'securerandom'

class CheckOutGitRepo < Services::Base
  REPO = 'git@github.com:manuelmeurer/railsbump-checker.git'

  def call
    dir = Rails.root.join('tmp', "railsbump_checker_#{SecureRandom.hex(3)}")

    if dir.exist?
      raise Error, "Dir #{dir} exists already."
    end

    Git.clone(REPO, dir).tap do |git|
      git.config 'user.name',  'RailsBump Checker'
      git.config 'user.email', 'hello@railsbump.org'

      git.checkout
    end
  end
end
