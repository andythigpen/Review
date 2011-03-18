module ApplicationHelper
  def add_comment_button(commentable, location, *args, &block)
    if block_given?
      inner = capture(&block)
    end
    inner = "Add Comment" if inner.nil?

    if args[0].class != Hash
      leftline = args[0]
      rightline = args[1] if args[1].class != Hash
    end
    leftline = nil if not defined? leftline 
    rightline = nil if not defined? rightline 

    html_options = args.extract_options!.symbolize_keys
    #content = render("shared/comment_form", :commentable => commentable, 
    #                 :leftline => leftline, :rightline => rightline)
    href = "#"
    onclick = "add_comment_form('#{location}', '#{commentable.id}', '#{commentable.class.name}', '#{leftline}', '#{rightline}');return false;"
    #onclick = "add_comment_form('#{location}', '#{escape_javascript(content)}');return false;"
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

  def format_comment(text)
    result = text.gsub(/\{\{\{/, "<div class=\"comment-code\">")
    result.gsub!(/\}\}\}/, "</div>")
    result.gsub!(/'''(.*?)'''/, "<strong>\\1</strong>")
    result.html_safe
  end
end
