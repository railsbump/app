# remove columns

ActiveRecord::Migration.remove_column :gemmies, :versions
ActiveRecord::Migration.rename_column :gemmies, :versions_and_dependencies, :dependencies_and_versions

# rename gemfiles to lockfiles

ActiveRecord::Migration.rename_table :gemfiles, :lockfiles
ActiveRecord::Migration.rename_table :gemfile_dependencies, :lockfile_dependencies
ActiveRecord::Migration.rename_column :lockfile_dependencies, :gemfile_id, :lockfile_id

# add index to compats

begin
  ActiveRecord::Migration.add_index :compats, [:dependencies, :rails_release_id], unique: true
rescue ActiveRecord::RecordNotUnique => e
  puts e.message
  if e.message =~ /Key \(dependencies, rails_release_id\)=\((.+), (\d)\) is duplicated/
    records=Compat.where(dependencies:JSON.load($1),rails_release_id:$2)
    if records.many?
      records.limit(records.size - 1).each(&:destroy)
      retry
    else
      raise "wat? #{e.message}"
    end
  else
    raise e
  end
end

# add compatible_reason to compats

ActiveRecord::Migration.add_column :compats, :compatible_reason, :string
GitHubNotification.count

# add conclusion to github notifications

ActiveRecord::Migration.add_column :github_notifications, :conclusion, :string
ActiveRecord::Migration.add_column :github_notifications, :action, :string
ActiveRecord::Migration.add_column :github_notifications, :branch, :string

# restart console

GithubNotification.where(action:nil).find_each do |gn|
  gn.action     = gn.data["action"]
  gn.conclusion = gn.data.dig("check_run", "conclusion")
  gn.branch     = gn.data.dig("check_run", "check_suite", "head_branch")
  gn.save validate: false
end
ActiveRecord::Migration.change_column_null :github_notifications, :action, false
ActiveRecord::Migration.change_column_null :github_notifications, :branch, false

GithubNotification.where(id: [142472,142115,142470,141380,141378,141381,141379,141371,141376,141377,140928,141003,140997,140974,140813,140775,140786,140823,140716,140720,140724,140685,140715,140677,140686,140676,140662,140669,140670,140661,140522,140532,140515,140510,140513,140502,140492,140491,140479,140441,140444,140473,140448,140420,140419,140440,140410,140403,140402,140409,140145,140166,140120,140115,140110,140111,140077,140099,140107,140082,140045,140061,140066,140037,140042,140040,140017,140010,140020,140012]).each do |gn|
  gn.unprocessed!
  gn.compat.update! compatible: nil, compatible_reason: nil
  GithubNotifications::Process.call gn
end

# refactor compats

ActiveRecord::Migration.add_column :compats, :status, :integer

Compat.where(compatible: nil).update_all status: Compat.statuses.fetch(:pending)
Compat.where(compatible: true).update_all status: Compat.statuses.fetch(:compatible)
Compat.where(compatible: false).update_all status: Compat.statuses.fetch(:incompatible)

ActiveRecord::Migration.remove_column :compats, :compatible

ActiveRecord::Migration.rename_column :compats, :compatible_reason, :status_determined_by

# recheck all compats after fixes

[Compat.inconclusive,Compat.incompatible.checked_after(Date.new(2020,12,4).beginning_of_day)].each do |scope|
  scope.update_all status: 0, status_determined_by:nil,checked_at:nil
end

# bundler 2 requires ruby >= 2.3.0

# rails 2.3 - ruby 2.7, bundler 2.1.4 (oder der konsistenz wegen auch 1.17.3?)
# rails 3.0 - ruby 2.7, bundler 1.17.3 (3.0.0, 3.0.1 und 3.0.2 brauchen bundler 1.0.x, alle darüber 1.x)
# rails 3.1 - ruby 2.7, bundler 1.17.3
# rails 3.2 - ruby 2.7, bundler 1.17.3
# rails 4.0 - ruby 2.7, bundler 1.17.3
# rails 4.1 - ruby 2.7, bundler 1.17.3
# rails 4.2 - ruby 2.7, bundler 1.17.3
# rails 5.0 - ruby 2.7, bundler 2.1.4
# rails 5.1 - ruby 2.7, bundler 2.1.4
# rails 5.2 - ruby 2.7, bundler 2.1.4

rails_version   = "3.0"
ruby_version    = "2.7"
bundler_version = "1.17.3"

action_file = File.join(git.dir.path, ".github", "workflows", "ci.yml")
File.write action_file, <<~TEXT.chomp
                          name: CI
                          on:
                            push:
                              branches-ignore:
                                - main

                          jobs:

                            verify:
                              name: Verify
                              runs-on: ubuntu-latest

                              steps:

                                - name: Check out code
                                  uses: actions/checkout@v2

                                - name: Set up Ruby
                                  uses: ruby/setup-ruby@v1
                                  with:
                                    ruby-version: #{ruby_version}
                                    bundler: none

                                - name: Install bundler
                                  run: gem install bundler -v #{bundler_version}

                                - name: Try to create lockfile
                                  run: |
                                    gem list
                                    bundle --version
                                    bundle _#{bundler_version}_ install
                        TEXT

gemfile_content = "source "https://rubygems.org"\ngem "rails", "~> #{rails_version}.0""
File.write File.join(git.dir.path, "Gemfile"), gemfile_content

git.add [action_file, "Gemfile"]
git.commit "Rails #{rails_version}, Ruby #{ruby_version}, Bundler #{bundler_version}"
git.push "origin", "test"

# add compat_ids to gemmies

ActiveRecord::Migration.add_column :gemmies, :compat_ids, :text, array: true, default: [], null: false

Compat.find_each do |c|
  c.gemmies.update_all(["compat_ids = array_append(compat_ids, ?)", c.id.to_s])
end

Gemmy.find_each do |g|
  compats = RailsRelease.all.map do
    _1.compats.merge(g.compats)
  end

  next if compats.map(&:size).uniq.one?

  dependencies = compats.flatten.map(&:dependencies).uniq

  dependencies.each do |d|
    RailsRelease.find_each do |rr|
      compat = rr.compats.where(dependencies: d).first_or_create!
      unless g.compat_ids.include?(compat.id.to_s)
        Gemmy.where(id: g).update_all(["compat_ids = array_append(compat_ids, ?)", compat.id.to_s])
        g.touch
      end
    end
  end
end

# fix gemmy dependency encoding

Gemmy.find_each do |g|
  g.dependencies_and_versions.transform_keys! { JSON.generate JSON.load(_1) }
  if g.changed?
    g.save!
  end
end

co=[]
Compat.find_each do |c|
  puts c.id
  co<<c if c.dependencies.size == 1
end;nil

# add dependencies_key to compats

ActiveRecord::Migration.remove_index :compats, %i(dependencies rails_release_id)
ActiveRecord::Migration.add_column :compats, :dependencies_key, :uuid
# restart console
Compat.where(dependencies_key:nil).find_each do |c|
  c.dependencies_key = Digest::MD5.hexdigest(JSON.generate c.dependencies)
  c.save validate: false
end
ActiveRecord::Migration.add_index :compats, %i(dependencies_key rails_release_id), unique: true

# process github notifications

GithubNotification.unprocessed.find_each do
  puts _1.id
  if /\A\d+\z/.match?(_1.branch) && !Compat.find(_1.branch).pending?
    _1.processed!
  else
    GithubNotifications::Process.call(_1)
  end
end

["6.0","5.2","5.1","5.0","4.2","4.1","4.0","3.2","2.3","3.0","3.1","6.1","7.0"].each do |version|
  RailsRelease.create! version: version
end
# [#<Gem::Version "6.0">, #<Gem::Version "5.2">, #<Gem::Version "5.1">, #<Gem::Version "5.0">, #<Gem::Version "4.2">, #<Gem::Version "4.1">, #<Gem::Version "4.0">, #<Gem::Version "3.2">, #<Gem::Version "2.3">, #<Gem::Version "3.0">, #<Gem::Version "3.1">, #<Gem::Version "6.1">, #<Gem::Version "7.0">]

# convert db from postgres to sqlite

# /Users/manuel/Library/Python/3.9/bin/db-to-sqlite "postgresql://railsbump:MUDv4XUUKrpsFGVytPHoduzNZ7ojqY@railsbump.cbqgwmohh80g.eu-central-1.rds.amazonaws.com/railsbump_production" storage/development.sqlite3 --all --progress --skip github_notifications

ActiveRecord::Migration.create_table :github_notifications do |t|
  t.string :conclusion
  t.string :action, :branch, null: false
  t.json :data
  t.datetime :processed_at
  t.references :compat
  t.timestamps
end

# fix db columns

Rails.application.eager_load!
ApplicationRecord.descendants.each do |klass|
  puts klass
  %w(created_at updated_at).each do |column|
    puts column
    next unless klass.columns_hash[column]&.type == :text
    ActiveRecord::Migration.add_column klass.table_name, "#{column}_new", :datetime
    klass.where("#{column}_new": nil).update_all "#{column}_new = DATETIME(#{column})"
    ActiveRecord::Migration.remove_column klass.table_name, column
    ActiveRecord::Migration.rename_column klass.table_name, "#{column}_new", column
    ActiveRecord::Migration.change_column_null klass.table_name, column, false
  end
end

ActiveRecord::Migration.add_column :compats, :checked_at_new, :datetime
Compat.where(checked_at_new: nil).update_all "checked_at_new = DATETIME(checked_at)"
ActiveRecord::Migration.remove_column :compats, :checked_at
ActiveRecord::Migration.rename_column :compats, :checked_at_new, :checked_at

ActiveRecord::Migration.add_column :compats, :dependencies_new, :json
Compat.where(dependencies_new: nil).update_all "dependencies_new = JSON(dependencies)"
ActiveRecord::Migration.remove_column :compats, :dependencies
ActiveRecord::Migration.rename_column :compats, :dependencies_new, :dependencies

ActiveRecord::Migration.add_column :gemmies, :compat_ids_new, :json
Gemmy.where(compat_ids_new: nil).update_all "compat_ids_new = JSON(compat_ids)"
ActiveRecord::Migration.remove_column :gemmies, :compat_ids
ActiveRecord::Migration.rename_column :gemmies, :compat_ids_new, :compat_ids
ActiveRecord::Migration.change_table :gemmies do |t|
  t.check_constraint "JSON_TYPE(compat_ids) = 'array'", name: "gemmy_compat_ids_is_array"
end
ActiveRecord::Migration.change_column_null :gemmies, :compat_ids, false

ActiveRecord::Migration.add_column :gemmies, :dependencies_and_versions_new, :json
Gemmy.where(dependencies_and_versions_new: nil).update_all "dependencies_and_versions_new = JSON(dependencies_and_versions)"
ActiveRecord::Migration.remove_column :gemmies, :dependencies_and_versions
ActiveRecord::Migration.rename_column :gemmies, :dependencies_and_versions_new, :dependencies_and_versions

# update compat dependencies keys

Compat.find_each do |c|
  c.update! dependencies_key: ActiveSupport::Digest.hexdigest(JSON.generate c.dependencies)
end
