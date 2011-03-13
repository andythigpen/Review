class DiffsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    contents = params[:diff][:contents]
    diff_params = params[:diff].clone
    diff_params[:contents] = ""

    if not params[:diff][:patch].nil?
      file = params[:diff][:patch]
      file.open
      contents = file.read
      diff_params.delete :patch
    end

    diff_started = false
    contents.each do |line|
      if line =~ /^---\s+([\w+\/\\:]+)/
        if diff_started
          @diff = Diff.new diff_params
          break if not @diff.save
          diff_params[:contents] = ""
        end
        diff_params[:origin_file] = $1
        diff_started = true
      elsif line =~ /^\+\+\+\s+([\w+\/\\:]+)/
        diff_params[:updated_file] = $1
      elsif line =~ /^(\+|-| |@)/
        diff_params[:contents] += line
      end
    end
    @diff = Diff.new diff_params
    @diff.save

    respond_to do |format|
      if @diff.errors.size > 0
        format.json { render :json => { :status => "error", 
                                        :errors => @diff.errors } }
        format.html { redirect_to :back, :alert => "Error saving diff" }
      else 
        format.json { render :json => { :status => "ok", 
                                        :id => @diff.id } }
        format.html { redirect_to :back, :notice => "Successfully uploaded patch file" }
      end
    end
  end

  def destroy
    @diff = Diff.find(params[:id])
    @diff.destroy
    
    respond_to do |format|
      format.json { render :json => { :status => "ok" } }
    end
  end
end
