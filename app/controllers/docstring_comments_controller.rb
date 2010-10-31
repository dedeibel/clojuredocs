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
      flash[:message] = "Couldn't find docstring comment."
      redirect_back_or_default "/"
    end
    
    if current_user_session and @dc.user == current_user
      @dc.delete
      flash[:message] = "Comment deleted."
      redirect_back_or_default "/"
    end
  end

  def new
    ds = DocstringComment.new
    ds.user_id = params[:user_id]
    ds.function_id = params[:function_id]
    ds.body = params[:body]

    if not ds.valid?
      render json_fail "There was a problem with your comment, is it blank?" and return
    end

    ds.save

    render :json => {:success => true, :message => "Comment added."}
  end
end
