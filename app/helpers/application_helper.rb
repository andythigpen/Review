module ApplicationHelper
  def add_comment_button(commentable, location, *args, &block)
    if block_given?
      inner = capture(&block)
    elsif args[0].class == String
      inner = args[0]
    end
    inner = "Add Comment" if inner.nil?
    html_options = args.extract_options!.symbolize_keys
    content = render("shared/comment_form", :commentable => commentable)
    href = "#"
    onclick = "add_comment_form('#{location}', '#{escape_javascript(content)}');return false;"
#"<a href=\"#\" onclick=\"".html_safe() + "#{onclick}" + "\">#{inner}</a>".html_safe
    content_tag(:a, html_options.merge(:href => href, :onclick => onclick)) do 
      inner
    end
  end

  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end

  def link_to_js(func, *args, &block)
    if block_given?
      inner = capture(&block).html_safe
    end
    html_options = args.extract_options!.symbolize_keys
    link_to_function(inner, func, html_options)
  end
end
