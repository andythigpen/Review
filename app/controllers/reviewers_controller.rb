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
end
