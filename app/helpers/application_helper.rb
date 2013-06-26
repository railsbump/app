module ApplicationHelper
  Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

  def markdown content
    Markdown.render(content).html_safe
  end
end
