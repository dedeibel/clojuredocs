class DocstringCommentsController < ApplicationController
  layout 'main'
  
  def index
    @function = Function.find_by_id(params[:id])
    @docstring_comment = DocstringComment.new
    
    if request.post?
      @docstring_comment.function = @function
      @docstring_comment.user = current_user
      
      @docstring_comment.body = params[:docstring_comment][:body]
      if @docstring_comment.save
        redirect_to :action => 'index', :id => @function.id
      end
    end
  end
end
