class ApplicationMailer < ActionMailer::Base
  default from: "notifier@ready4rails4.net"

  def new_gem_admin_notification gem
    @gem = gem
    mail(
      to:      ENV['ADMIN_EMAILS'],
      subject: "A new gem has been registered! '#{gem.name}'"
    )
  end

  def updated_gem_admin_notification gem
    @gem = gem
    mail(
      to:      ENV['ADMIN_EMAILS'],
      subject: "'#{gem.name}' has been updated!"
    )
  end
end
