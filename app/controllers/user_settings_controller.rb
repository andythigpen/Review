class UserSettingsController < ApplicationController
  def edit
    @user = current_user
  end

  # only for email settings at the moment...
  def update
    @user = User.find(current_user.id)
    params[:user].keys.each do |k|
      @user.send "#{k}=", params[:user][k].to_i
    end
    if @user.save
      sign_in @user
    end
    redirect_to edit_user_registration_path
  end
end
