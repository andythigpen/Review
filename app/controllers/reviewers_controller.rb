class ReviewersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @users = User.where("username LIKE ? OR email LIKE ?", 
                        "#{params[:term]}%", "#{params[:term]}%")
    @profiles = Profile.where("first_name LIKE ? or last_name LIKE ?",
                              "%#{params[:term]}%", "#{params[:term]}%")
    @profile_usernames = @profiles.map do |p| 
      label = p.full_name_and_username 
      { :label => label, :id => p.user.id }
    end
    @usernames = @users.map {|u| { :label => u.profile_name, :id => u.id } }
    @usernames = @usernames | @profile_usernames

    respond_to do |format|
      format.json { render :json => @usernames }
    end
  end

  def reviewer
    #FIXME: refactor to be more generic
    if params.has_key?(:review_event_id)
      begin
        @parent = ReviewEvent.find(params[:review_event_id])
      rescue ActiveRecord::RecordNotFound
        @parent = ReviewEvent.new
      end
      @user_type = :review_event_users
      user = @parent.review_event_users.find_by_user_id(params[:user_id])
      if user.nil?
        user = ReviewEventUser.new(:user_id => params[:user_id], 
          :review_event_id => @parent.id)
      end
    elsif params.has_key?(:group_id)
      begin
        @parent = Group.find(params[:group_id])
      rescue ActiveRecord::RecordNotFound
        @parent = Group.new
      end
      @user_type = :group_members
      user = @parent.members.find_by_id(params[:user_id])
      if user.nil?
        user = GroupMember.new(:user_id => params[:user_id], 
          :group_id => @parent.id)
      end
    end

    respond_to do |format|
      format.json { render :partial => "review_events/reviewers_row",
        :locals => { :r => user, :adding => true } }
    end
  end

  def group
    begin
      @parent = ReviewEvent.find(params[:review_event_id])
    rescue ActiveRecord::RecordNotFound
      @parent = ReviewEvent.new
    end
    @user_type = :review_event_users
    group = current_user.groups.find(params[:group_id])

    members = group.members.map do |m|
      r = ReviewEventUser.new :user_id => m.id, 
        :review_event_id => @parent.id 
      self.formats = 'html'
      content = render_to_string(:partial => "review_events/reviewers_row", 
                                 :locals => { :r => r, :adding => true })
      { :user_id => m.id, :content => content }
    end

    respond_to do |format|
      format.json do 
        render :json => members
      end
    end
  end

end
