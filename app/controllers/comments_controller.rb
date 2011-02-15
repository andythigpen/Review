class CommentsController < ApplicationController
  def create
    @diff = Diff.find(params[:diff_id])
    @comment = @diff.comments.new params[:comment]
    respond_to do |format|
      if @comment.save
        format.js 
      else 
        format.js  { render :json => @diff.errors, 
                     :status => :unprocessable_entity }
      end
    end
  end

  def update
  end

  def show
  end

  def destroy
  end

end
