module ReviewEventsHelper
  def add_reviewer_select(name, f)
    reviewers = User.all.map { |r| [r.profile_name, r.id] }
    reviewers.insert(0, [name, nil])
    select = select_tag("reviewer-select", options_for_select(reviewers),
                        { :class => "chosen reviewers-list",
                          :title => name })
    select.html_safe
  end

  def add_group_select(name, f)
    groups = current_user.groups.map {|g| [g.name, g.id] }
    groups.insert(0, [name, nil])
    select = select_tag("group-select", options_for_select(groups), 
                        { :class => "chosen reviewers-list",
                          :title => name })
    select.html_safe
  end

end
