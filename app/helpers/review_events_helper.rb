module ReviewEventsHelper
  def link_to_add_reviewer(name, f)
    new_object = ReviewEventUser.new
    fields = f.fields_for(:review_event_users, new_object, 
                      :child_index => "new_review_event_user") do |builder|
      render("new_reviewer", :f => builder)
    end
    fields += "<input type=\"text\" value=\"\" class=\"reviewer_autocomplete\" />".html_safe
#link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
    link_to_function(name, "add_reviewer(this, \"#{escape_javascript(fields)}\");")
  end
end
