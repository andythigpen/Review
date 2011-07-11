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

  def modal_dialog(id, &block)
    if block_given?
      inner = capture(&block).html_safe
    end
    <<END_CONTENT.html_safe
    <div id="#{id}" class="hidden">
      <img src="/images/ajax-loader.gif" alt="loading" class="ajax-loader hidden" />
      <div class="dialog-content">
        #{inner}
      </div>
    </div>
END_CONTENT
  end

  def user_profile_popup(user, params={})
    defaults = { :short_format  => false, 
                 :profile_class => "profile-left",
                 :thumbnail     => true, 
                 :username      => user.profile_name }
    params = defaults.merge(params)

    avatar_small = image_tag "/avatars/thumb/missing.png", 
                   :class => "thumbnail" if params[:thumbnail]
    avatar_large = image_tag "/avatars/medium/missing.png", 
                   :class => "thumnail"
    if user.profile
      avatar_small = image_tag user.profile.avatar.url(:thumb), 
                     :class => "thumbnail" if params[:thumbnail]
      avatar_large = image_tag user.profile.avatar.url(:medium), 
                     :class => "thumnail"
    end
    p = user.profile
    name = params[:username]
    name = user.username if params[:short_format]

    <<END_POPUP.html_safe
    <span class="username">
      #{avatar_small} #{name}
      <div class="profile #{params[:profile_class]} hidden">
        <table>
          <tr>
            <td rowspan="5" style="padding-right:1em;">#{avatar_large}</td>
            <td><strong>Username:</strong></td>
            <td>#{user.username}</td>
          </tr>
          <tr>
            <td><strong>Full Name:</strong></td>
            <td>#{user.full_name}</td>
          </tr>
          <tr>
            <td><strong>Profession:</strong></td>
            <td>#{p.try(:profession)}</td>
          </tr>
          <tr>
            <td><strong>Location:</strong></td>
            <td>#{p.try(:location)}</td>
          </tr>
          <tr>
            <td><strong>Quote:</strong></td>
            <td>#{p.try(:quote)}</td>
          </tr>
        </table>
      </div>
    </span>
END_POPUP
  end

end
