Rails::TestTask.new :test do |t|
  t.pattern = "test/**/*_test.rb"
end

namespace :test do
  Rails::TestTask.new "lib" do |t|
    t.pattern = "test/lib/**/*_test.rb"
  end
end
