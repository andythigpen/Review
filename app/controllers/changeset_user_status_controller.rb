class ChangesetUserStatusController < ApplicationController
  def update
    @status = ChangesetUserStatus.find_by_user_id_and_changeset_id(params[:changeset_user_status][:changeset_id], params[:changeset_user_status][:changeset_id])
    success = false
    if @status.nil?
      @status = ChangesetUserStatus.new params[:changeset_user_status]
      success = @status.save
    else
      success = @status.update_attributes params[:changeset_user_status]
    end

    respond_to do |format|
      if success
        format.json { render :json => { :status => "ok" } }
      else
        format.json { render :json => { :status => "error",
                                        :errors => @status.errors } }
      end
    end
  end
end
