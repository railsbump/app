class ApplicationMailer < ActionMailer::Base
  default from: "notifier@ready4rails.net"

  def new_gem_admin_notification gem
    @gem = gem
    mail(
      to:      ENV['ADMIN_EMAILS'],
      subject: "A new gem has been registered! '#{gem.name}'"
    )
  end
end
