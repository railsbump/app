module ApplicationHelper
  Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

  def markdown content
    if content.present?
      Markdown.render(content).html_safe
    end
  end

  def display_status status
    content_tag(:span, class: status.gsub(" ", "-")) { status }
  end
end
