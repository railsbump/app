module ApplicationHelper
  def alert(level, text = nil, &block)
    content_tag :div, class: "alert alert-#{level} alert-dismissible fade show" do
      concat content_tag(:button, '×', type: 'button', class: 'close', data: { dismiss: 'alert' })
      concat text&.html_safe || capture_haml(&block)
    end
  end

  def flash_messages
    %i(notice alert).map do |level|
      next if flash[level].blank?
      alert_level = { notice: 'success', alert: 'danger' }.fetch(level)
      alert alert_level, flash[level]
    end.compact.join("\n").html_safe
  end
end
