module ReviewEventsHelper
  def add_reviewer_select(name, f)
    reviewers = User.all.map { |r| [r.profile_name, r.id] }
    reviewers.insert(0, [name, nil])
    new_object = ReviewEventUser.new
    fields = f.fields_for(:review_event_users, new_object, 
                      :child_index => "new_review_event_user") do |builder|
      builder.hidden_field :review_event_id, :value => @review_event.id
      builder.select(:user_id, options_for_select(reviewers), {},
               { :class => "chosen reviewers-list", 
                 :title => name })
    end
    "<div id=\"new_reviewer_template\" style=\"display:none\">#{fields}</div>".html_safe
  end
end
