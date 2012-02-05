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
    href = "#"
    onclick = "add_comment_form('#{location}', '#{commentable.id}', '#{commentable.class.name}', '#{leftline}', '#{rightline}');return false;"
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

  class ModalResponder
    attr_accessor :title, :body, :footer
    def initialize
      @title = "Modal Dialog"
      @body = "Nothing to see here!"
      @footer = "<a href=\"#\" class=\"btn btn-primary\" data-dismiss=\"modal\">OK</a>"
    end

    def for_title(&block)
      # @title = capture(&block).html_safe
      if block_given?
        @title = yield 
      end
    end
    def for_body(&block)
      # @body = capture(&block).html_safe
      if block_given?
        @body = yield
      end
    end
    def for_footer(&block)
      # @footer = capture(&block).html_safe
      if block_given?
        @footer = yield
      end
    end
  end

  def modal_dialog(id, &block)
    responder = ModalResponder.new
    if block_given?
      # inner = capture(&block).html_safe
      yield responder
    end
    return <<END_CONTENT.html_safe
    <div id="#{id}" class="modal hidden">
      <div class="modal-header">
        <a class="close" data-dismiss="modal">&times;</a>
        <h3>#{responder.title.html_safe}</h3>
      </div>
      <div class="modal-body">
        <p>#{responder.body.html_safe}</p>
      </div>
      <div class="modal-footer">
        #{responder.footer.html_safe}
      </div>
    </div>
END_CONTENT
    if false
    <<END_CONTENT.html_safe
    <div id="#{id}" class="hidden">
      <img src="/images/ajax-loader.gif" alt="loading" class="ajax-loader hidden" />
      <div class="dialog-content">
        #{inner}
      </div>
    </div>
END_CONTENT
    end
  end

  def user_profile_popup(user, params={})
    defaults = { :short_format  => false, 
                 :profile_class => "profile-left",
                 :thumbnail     => true, 
                 :username      => user.username }
    params = defaults.merge(params)
    if params[:thumbnail] and not params[:short_format]
      avatar_small = image_tag "/avatars/thumb/missing.png", 
                     :class => "thumbnail" 
    end
    avatar_large = image_tag "/avatars/medium/missing.png", 
                   :class => "thumnail"
    if user.profile
      if params[:thumbnail] and not params[:short_format]
        avatar_small = image_tag user.profile.avatar.url(:thumb), 
                       :class => "thumbnail" 
      end
      avatar_large = image_tag user.profile.avatar.url(:medium), 
                     :class => "thumnail"
    end
    p = user.profile
    name = params[:username]
    name = user.username if params[:short_format]
    
    popup = "<div class=\"pull-left\" style=\"margin-right:10px\">#{avatar_large}</div>"
    popup += "<div class=\"clearfix\">"
    #popup += "<div><strong>Username:</strong> #{user.username}</div>"
    popup += "<div><strong>Full Name:</strong> #{user.full_name}</div>" if not user.full_name.blank?
    if not p.nil?
      popup += "<div><strong>Profession:</strong> #{p.profession}</div>" if not p.profession.blank?
      popup += "<div><strong>Location:</strong> #{p.location}</div>" if not p.location.blank?
      popup += "<div><strong>Quote:</strong> #{p.quote}</div>" if not p.quote.blank?
    end
    popup += "</div>"
    
    return content_tag(:span, "#{avatar_small} #{name}".html_safe, 
                       :class => "username", 
                       :title => "#{name}", 
                       "data-content" => "#{popup.html_safe}") 

    if false
    <<END_POPUP.html_safe
    <span class="username" data-original-title="#{user.username}"
      data-content="<strong>#{user.username}</strong>">
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
end
