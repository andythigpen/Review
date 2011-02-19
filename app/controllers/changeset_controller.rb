class ChangesetController < ApplicationController
  def create
    @changeset = Changeset.new params[:changeset]

    respond_to do |format|
      if @changeset.save
        format.json { render :json => { :status => "ok", 
                                        :id => @changeset.id } }
      else 
        format.json { render :json => { :status => "error", 
                                        :errors => @changeset.errors } }
      end
    end
  end

  def update
    @changeset = Changeset.find(params[:id])

    respond_to do |format|
      if @changeset.update_attributes(params[:changeset])
        format.json { render :partial => "review_events/status",
                             :locals => { :changeset => @changeset } }
      else
        format.json { render :json => { :status => "error",
                                        :errors => @changeset.errors } }
      end
    end
  end

  def destroy
    @comment = Changeset.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.js  { render :json => { :status => "ok" } }
    end
  end

end
