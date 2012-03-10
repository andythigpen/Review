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

  def capture_block(&block)
    return capture(&block).html_safe
  end

  class ModalResponder
    include ActionView::Helpers::CaptureHelper

    attr_accessor :title, :body, :footer
    def initialize(inst)
      @inst = inst
      @title = "Modal Dialog"
      @body = "Nothing to see here!"
      @footer = "<a href=\"#\" class=\"btn btn-primary\" data-dismiss=\"modal\">OK</a>"
    end

    def for_title(&block)
      if block_given?
        @title = @inst.capture(&block).html_safe
      end
    end
    def for_body(&block)
      if block_given?
        @body = @inst.capture(&block).html_safe
      end
    end
    def for_footer(&block)
      if block_given?
        @footer = @inst.capture(&block).html_safe
      end
    end
  end

  def modal_dialog(id, &block)
    responder = ModalResponder.new(self)
    if block_given?
      yield responder
    end
    return <<END_CONTENT.html_safe
    <div id="#{id}" class="modal hidden">
      <div class="modal-header">
        <a class="close" data-dismiss="modal">&times;</a>
        <h3>#{responder.title}</h3>
      </div>
      <div class="modal-body">
        <img src="/images/ajax-loader.gif" alt="loading" class="ajax-loader hidden" />
        <div class="dialog-content">
          <p>#{responder.body}</p>
        </div>
      </div>
      <div class="modal-footer">
        #{responder.footer}
      </div>
    </div>
END_CONTENT
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
  end

end
