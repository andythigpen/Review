module ReviewEventsHelper
  def link_to_add_reviewer(name, f)
    new_object = ReviewEventUser.new
    fields = f.fields_for(:review_event_users, new_object, 
                      :child_index => "new_review_event_user") do |builder|
      render("new_reviewer", :f => builder)
    end
    fields += "<input type=\"text\" value=\"\" class=\"reviewer_autocomplete text ui-corner-all ui-widget-content\" style=\"width:20em;\" />".html_safe
    fields += "<span class=\"ui-icon ui-icon-check right hidden\"></span>".html_safe
    link_to_function(name, "add_reviewer(this, \"#{escape_javascript(fields)}\");")
  end
end
