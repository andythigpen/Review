class ChangesetController < ApplicationController
  before_filter :authenticate_user!

  def show
    @changeset = Changeset.find params[:id]
    redirect_to review_event_path(@changeset.review_event) + "?changeset=#{@changeset.id}"
  end

  def create
    @changeset = Changeset.new params[:changeset]
    if @changeset.name.size == 0
      @changeset.name = "Revision #{@changeset.review_event.changesets.size + 1}"
    end

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
        if @changeset.submitted
          @changeset.review_event.reviewers.each do |r|
            UserMailer.review_request_email(r, current_user, 
                                            @changeset).deliver
          end
        end

        format.json { render :partial => "review_events/status",
                             :locals => { :changeset => @changeset } }
      else
        format.json { render :json => { :status => "error",
                                        :errors => @changeset.errors } }
      end
    end
  end

  def destroy
    @changeset = Changeset.find(params[:id])
    @changeset.destroy

    respond_to do |format|
      format.js  { render :json => { :status => "ok" } }
    end
  end

  def download
    @changeset = Changeset.find(params[:id])
    @patch = ""
    @changeset.diffs.each do |c|
      @patch += "--- " + c.origin_file + "\n"
      @patch += "+++ " + c.updated_file + "\n"
      @patch += c.contents + "\n"
    end
    send_data @patch, :filename => "changeset_#{@changeset.id}.patch"
  end

end
