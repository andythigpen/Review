class DiffsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    contents = params[:diff][:contents]
    diff_params = params[:diff].clone #{ :content => "" }
    diff_params[:contents] = ""
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
    if diff_params[:contents].size > 0
      @diff = Diff.new diff_params
      @diff.save
    end
#    @diff = Diff.new params[:diff]

    respond_to do |format|
      if @diff.errors.size > 0
        format.json { render :json => { :status => "error", 
                                        :errors => @diff.errors } }
      else 
        format.json { render :json => { :status => "ok", 
                                        :id => @diff.id } }
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
