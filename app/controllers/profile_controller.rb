class ProfileController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @profile = current_user.profile
    if @profile.nil?
      @profile = Profile.new :user => current_user
      @profile.save
    end
  end

  def update
    @profile = current_user.profile

    respond_to do |format|
      success = @profile.update_attributes(params[:profile])

      if success
        format.html { redirect_to(@profile, :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

end
