class ChangesetUserStatusController < ApplicationController
  def update
    @status = ChangesetUserStatus.find_by_user_id_and_changeset_id(
            current_user.id, params[:changeset_user_status][:changeset_id])
    params[:changeset_user_status][:user_id] = current_user.id
    success = false
    if @status.nil?
      @status = ChangesetUserStatus.new params[:changeset_user_status]
      success = @status.save
    else
      success = @status.update_attributes params[:changeset_user_status]
    end

    respond_to do |format|
      if success
        UserMailer.status_email(@status, 
                                @status.changeset.review_event.owner,
                                current_user).deliver
        format.json { render :json => { :status => "ok" } }
      else
        format.json { render :json => { :status => "error",
                                        :errors => @status.errors } }
      end
    end
  end

  def destroy
    @status = ChangesetUserStatus.find(params[:id])
    @status.destroy

    respond_to do |format|
      format.html { redirect_to :back }    
      format.json { render :json => { :status => "ok" } }
    end
  end
end
