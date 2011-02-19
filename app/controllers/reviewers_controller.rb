class ReviewersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @users = User.all.find_all do |u| 
      u.username =~ /^#{params[:term]}/ or u.email =~ /^#{params[:term]}/
    end
    @usernames = @users.map { |u| { :label => u.username, :id => u.id } }

    respond_to do |format|
      format.json { render :json => @usernames }
    end
  end
end
