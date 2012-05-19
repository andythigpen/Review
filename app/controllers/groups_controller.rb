class GroupsController < ApplicationController
  rescue_from User::NotAuthorized, :with => :user_not_authorized

  def check_authorization
    raise User::NotAuthorized if current_user != @group.owner
  end

  # GET /groups
  # GET /groups.xml
  def index
    @groups = current_user.groups

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])
    check_authorization

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    check_authorization

    # for the reviewers html partial
    @parent = @group
    @users = @group.group_members.active
    @user_type = :group_members
  end

  # POST /groups
  # POST /groups.xml
  def create
    params[:group][:user_id] = current_user.id
    @group = Group.new(params[:group])
    # @group.update_attribute :user_id, current_user.id

    # for the reviewers html partial
    @parent = @group
    @users = @group.group_members.active
    @user_type = :group_members

    respond_to do |format|
      if @group.save
        format.html { redirect_to(groups_path, :notice => 'Group was successfully created.') }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])
    check_authorization

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to(groups_path, :notice => 'Group was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    check_authorization
    @group.destroy

    respond_to do |format|
      format.json { render :json => { :status => "ok" } }
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
