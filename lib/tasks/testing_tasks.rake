namespace :test do
  Rails::TestTask.new("lib") do |t|
    t.pattern = "test/lib/**/*_test.rb"
  end
end
