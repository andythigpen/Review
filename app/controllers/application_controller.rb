class ApplicationController < ActionController::Base
  protect_from_forgery

  def user_not_authorized
    flash[:error] = "User not authorized."
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.json { render :json => { :status => "error", 
        :errors => "Not authorized." } }
    end
  end
end
