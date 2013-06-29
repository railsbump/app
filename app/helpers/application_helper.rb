module ApplicationHelper
  def display_status gem
    content_tag :span, gem.status, class: gem.status.gsub(" ", "-")
  end

  Markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
  def markdown content
    Markdown.render(content).html_safe if content.present?
  end

end
