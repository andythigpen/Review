class ReviewersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @users = User.where("username LIKE ? OR email LIKE ?", 
                        "#{params[:term]}%", "#{params[:term]}%")
    @profiles = Profile.where("first_name LIKE ? or last_name LIKE ?",
                              "%#{params[:term]}%", "#{params[:term]}%")
    @profile_usernames = @profiles.map do |p| 
      label = "#{p.user.username} (#{p.first_name} #{p.last_name})"
      { :label => label, :id => p.user.id }
    end
    @usernames = @users.map do |u| 
      label = "#{u.username}"
      if not u.profile.nil?
        label += " (#{u.profile.first_name} #{u.profile.last_name})"
      end
      { :label => label, :id => u.id } 
    end
    # labels/id should match so duplicates are removed!
    @usernames = @usernames | @profile_usernames

    respond_to do |format|
      format.json { render :json => @usernames }
    end
  end
end
