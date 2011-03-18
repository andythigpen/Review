class ReviewersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @users = User.where("username LIKE ? OR email LIKE ?", 
                        "#{params[:term]}%", "#{params[:term]}%")
    @usernames = @users.map { |u| { :label => u.username, :id => u.id } }

    respond_to do |format|
      format.json { render :json => @usernames }
    end
  end
end
