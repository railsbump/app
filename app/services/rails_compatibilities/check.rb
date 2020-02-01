module RailsCompatibilities
  class Create < ::Services::Base
    REPO = 'git@github.com:krautcomputing/railsbump-checker.git'
    TMP  = Rails.root.join('tmp')
    PATH = TMP.join('railsbump-checker')

    def call(rails_compatibility)
      branch_name = [
        rails_compatibility.gemmy.name,
        rails_compatibility.version,
        'rails',
        rails_compatibility.rails_release.version
      ].join('_')

      ssh_key = ENV['SSH_KEY']&.dup
      if ssh_key.present?
        unless ssh_key[-1] == "\n"
          ssh_key << "\n"
        end
        ssh_key_file = TMP.join('ssh_key')
        File.write ssh_key_file, ssh_key
        ENV['GIT_SSH_COMMAND']="ssh -o StrictHostKeyChecking=no -i #{ssh_key_file}"
      end

      git = if PATH.exist?
        Git.open(PATH)
      else
        Git.clone(REPO, PATH)
      end

      git.config 'user.name',  'RailsBump Checker'
      git.config 'user.email', 'hello@railsbump.org'

      git.checkout

      git.branches.select { |branch| branch.name == branch_name }.each do |branch|
        if branch.remote
          git.push branch.remote.name, branch_name, delete: true
        else
          branch.delete
        end
      end

      git.branch(branch_name).checkout

      files = {
        '.travis.yml' => <<~CONTENT,
                           language: ruby
                           rvm:
                             - 2.6
                           notifications:
                             webhooks: #{api_travis_notifications_url}
                         CONTENT
        'Gemfile'     => <<~CONTENT,
                           source 'https://rubygems.org'

                           gem 'rails', '#{rails_compatibility.rails_release.version}'
                           gem '#{rails_compatibility.gemmy.name}', '#{rails_compatibility.version}'
                         CONTENT
        'Rakefile'    => 'task :default'
      }

      files.each do |filename, content|
        File.write PATH.join(filename), content
        git.add filename
      end

      git.commit "test compatibility of #{rails_compatibility.gemmy.name} #{rails_compatibility.version} with rails #{rails_compatibility.rails_release.version}"

      git.push 'origin', branch_name
    end
  end
end
