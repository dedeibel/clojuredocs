class DocstringCommentsController < ApplicationController
  layout 'main'

  def index
  end
  
  def view
    @function = Function.find_by_id(params[:id])
    @docstring_comment = DocstringComment.new
    
    if request.post? and current_user_session

      @docstring_comment.function = @function
      @docstring_comment.user = current_user
      
      @docstring_comment.body = params[:docstring_comment][:body]
      if @docstring_comment.save
        redirect_to :action => 'index', :id => @function.id
      end
    end
  end

  def delete

    if not current_user_session
      render json_fail "You must be logged in to delete a docstring comment." and return
    end

    dc = DocstringComment.find_by_id(params[:id])
    if not dc
      render json_fail "Couldn't find the comment you wanted to delete." and return
    end

    if dc.user != current_user
      render json_fail "You don't own the comment you'd like to delete." and return
    end

    dc.delete

    render :json => {:success => true, :message => "Comment successfully deleted."}
  end

  def new

    f = Function.find_by_id(params[:function_id])

    if not f
      render json_fail "Couldn't find the var you'd like to comment on." and return
    end

    if not current_user_session
      render json_fail "You must be logged in to post a comment." and return
    end

    dc = DocstringComment.new
    dc.user_id = current_user.id
    dc.function_id = f.id
    dc.body = params[:body]

    if not dc.body
      render json_fail "There was a problem with your comment, is it blank?" and return
    end    

    if not dc.valid?
      render json_fail "There was a problem with your comment, is it blank?" and return
    end

    dc.save

    render :json => {:success => true, :message => "Comment added.", :content => render_to_string(:partial => "docstring_comment_item", :locals => {:dc => dc})}
  end

  def update
    if not current_user_session
      render json_fail "You must be logged in to update a comment." and return
    end

    new_body = params[:body]
    if new_body.blank?
      render json_fail "Updated comment can't be blank." and return
    end

    dc = DocstringComment.find_by_id(params[:id])
    if not dc
      render json_fail "Can't find the comment you'd like to update." and return
    end

    if not dc.user_id == current_user.id
      render json_fail "You don't own the comment you'd like to update." and return
    end

    dc.body = new_body
    dc.save

    render :json => {
      :success => true,
      :message => "Comment updated.",
      :content => render_to_string(:partial => "docstring_comment_item", :locals => {:dc => dc})
    }
  end
end
