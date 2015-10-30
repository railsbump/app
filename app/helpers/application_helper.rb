module ApplicationHelper
  def display_status status
    content_tag :span, status, class: status.gsub(" ", "-")
  end

  Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
  def markdown content
    Markdown.render(content.presence || "").html_safe
  end
end
