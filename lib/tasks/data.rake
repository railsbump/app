# lib/tasks/update_rails_releases.rake
namespace :data do
  SUPPORTED_RAILS_VERSIONS = %w(
    2.3
    3.0
    3.1
    3.2
    4.0
    4.1
    4.2
    5.0
    5.1
    5.2
    6.0
    6.1
    7.0
    7.1
    7.2
    8.0
  )

  task find_or_create_rails_releases: :environment do
    SUPPORTED_RAILS_VERSIONS.each do |version|
      RailsRelease.find_or_create_by(version: version)
    end
  end

  desc "Update minimum Ruby versions from Rails 2.3 to 7.2"
  task update_rails_releases: :find_or_create_rails_releases do
    min_versions = {
      "2.3" => {
        minimum_ruby_version: "1.8.7",
        maximum_ruby_version: "1.9.3",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "3.0" => {
        minimum_ruby_version: "1.8.7",
        maximum_ruby_version: "1.9.3",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "3.1" => {
        minimum_ruby_version: "1.8.7",
        maximum_ruby_version: "2.1.9",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "3.2" => {
        minimum_ruby_version: "1.8.7",
        maximum_ruby_version: "2.1.9",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "4.0" => {
        minimum_ruby_version: "1.9.3",
        maximum_ruby_version: "2.1.9",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "4.1" => {
        minimum_ruby_version: "1.9.3",
        maximum_ruby_version: "2.1.9",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "4.2" => {
        minimum_ruby_version: "1.9.3",
        maximum_ruby_version: "2.2.10",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "5.0" => {
        minimum_ruby_version: "2.2.10",
        maximum_ruby_version: "2.5.9",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "5.1" => {
        minimum_ruby_version: "2.2.10",
        maximum_ruby_version: "2.6.10",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "5.2" => {
        minimum_ruby_version: "2.2.10",
        maximum_ruby_version: "2.7.8",
        minimum_bundler_version: "1.17.3",
        minimum_rubygems_version: "1.3.6"
      },
      "6.0" => {
        minimum_ruby_version: "2.5.9",
        maximum_ruby_version: "3.0.7",
        minimum_bundler_version: "2.3.0",
        minimum_rubygems_version: "2.5.0"
      },
      "6.1" => {
        minimum_ruby_version: "2.5.9",
        maximum_ruby_version: "3.0.7",
        minimum_bundler_version: "2.3.0",
        minimum_rubygems_version: "2.5.0"
      },
      "7.0" => {
        minimum_ruby_version: "2.7.8",
        maximum_ruby_version: "3.1.6",
        minimum_bundler_version: "2.4.0",
        minimum_rubygems_version: "3.0.1"
      },
      "7.1" => {
        minimum_ruby_version: "2.7.8",
        maximum_ruby_version: "3.2.5",
        minimum_bundler_version: "2.3.27",
        maximum_bundler_version: "2.5.20",
        minimum_rubygems_version: "3.0.1"
      },
      "7.2" => {
        minimum_ruby_version: "3.1.6",
        maximum_ruby_version: "3.3.5",
        minimum_bundler_version: "2.5.20",
        maximum_bundler_version: "2.5.20",
        minimum_rubygems_version: "3.2.3"
       },
      "8.0" => {
        minimum_ruby_version: "3.2.0",
        maximum_ruby_version: "3.4.2",
        minimum_bundler_version: "2.5.20",
        maximum_bundler_version: "2.5.20",
        minimum_rubygems_version: "3.2.3"
       }
    }

    min_versions.each do |version, attrs|
      if rails_release = RailsRelease.find_by(version: version)
        puts "Updating Rails Release #{rails_release} with #{attrs}"
        rails_release.update_columns(attrs)
        puts "Updated Rails Release versions"
      else
        puts "Skipping Rails Release #{version} as it does not exist"
      end
    end

    puts "Rails Releases updated successfully."
  end
end
