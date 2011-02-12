class DiffsController < ApplicationController
  # GET /diffs
  # GET /diffs.xml
  def index
    @diffs = Diff.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @diffs }
    end
  end

  # GET /diffs/1
  # GET /diffs/1.xml
  def show
    @diff = Diff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @diff }
    end
  end

  # GET /diffs/new
  # GET /diffs/new.xml
  def new
    @diff = Diff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @diff }
    end
  end

  # GET /diffs/1/edit
  def edit
    @diff = Diff.find(params[:id])
  end

  # POST /diffs
  # POST /diffs.xml
  def create
    @diff = Diff.new(params[:diff])

    respond_to do |format|
      if @diff.save
        format.html { redirect_to(@diff, :notice => 'Diff was successfully created.') }
        format.xml  { render :xml => @diff, :status => :created, :location => @diff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @diff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /diffs/1
  # PUT /diffs/1.xml
  def update
    @diff = Diff.find(params[:id])

    respond_to do |format|
      if @diff.update_attributes(params[:diff])
        format.html { redirect_to(@diff, :notice => 'Diff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @diff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /diffs/1
  # DELETE /diffs/1.xml
  def destroy
    @diff = Diff.find(params[:id])
    @diff.destroy

    respond_to do |format|
      format.html { redirect_to(diffs_url) }
      format.xml  { head :ok }
    end
  end
end
