class DocstringCommentsController < ApplicationController
  layout 'main'
  
  def index
    @function = Function.find_by_id(params[:id])
  end
end
