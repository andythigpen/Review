class CommentsController < ApplicationController
  def create
    @comment = Comment.new params[:comment]

    respond_to do |format|
      if @comment.save
        level = 0
        level = 1 if @comment.commentable.class == Comment
        format.json { render :partial => "shared/comment", 
            :locals => { :comment => @comment, :level => level } }
#format.js { render :json => { :status => "ok", 
#                                      :content => content } }
      else 
        format.js { render :json => @comment.errors, 
                    :status => :unprocessable_entity }
      end
    end
  end

  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end

  def update
  end

  def show
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.js  { render :json => { :status => "ok" } }
    end
  end

end
