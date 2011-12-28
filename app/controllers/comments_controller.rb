class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @comment = Comment.new params[:comment]

    respond_to do |format|
      if @comment.save
        level = 0
        level = 1 if @comment.commentable.class == Comment

        commentee = nil
        if @comment.commentable.class == Comment
          commentee = @comment.commentable.user
        elsif @comment.commentable.class == Diff
          commentee = @comment.commentable.changeset.review_event.owner
        elsif @comment.commentable.class == ChangesetUserStatus
          commentee = @comment.commentable.changeset.review_event.owner
        end
        if not commentee.nil? and commentee != current_user
          UserMailer.comment_email(@comment, current_user, commentee).deliver
        end
        format.json { render :partial => "shared/comment", 
            :locals => { :comment => @comment, :level => level } }
      else 
        format.js { render :json => @comment.errors, 
                    :status => :unprocessable_entity }
      end
    end
  end

  def show
    @comment = Comment.find(params[:id])
    changeset = @comment.get_changeset
    redirect_to(changeset_path(changeset) + "#comment_#{@comment.id}")
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.js  { render :json => { :status => "ok" } }
    end
  end

end
