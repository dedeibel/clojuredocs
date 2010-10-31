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
    @dc = DocstringComment.find_by_id(params[:id])
    if not @dc
      render json_fail "Couldn't find the comment you wanted to delete." and return
    end

    if not current_user_session
      render json_fail "You must be logged in to delete a docstring comment." and return
    end

    if @dc.user != current_user
      render json_fail "You don't own the comment you'd like to delete." and return
    end

    @dc.delete

    render json_fail "stuff" and return

    render :json => {:success => true, :message => "Comment successfully deleted."}
  end

  def new
    dc = DocstringComment.new
    dc.user_id = params[:user_id]
    dc.function_id = params[:function_id]
    dc.body = params[:body]

    if not dc.valid?
      render json_fail "There was a problem with your comment, is it blank?" and return
    end

    dc.save

    render :json => {:success => true, :message => "Comment added.", :content => render_to_string(:partial => "docstring_comment_item", :locals => {:dc => dc})}
  end
end
