class CommentsController < ApplicationController
  before_filter :authenticate_user!

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
