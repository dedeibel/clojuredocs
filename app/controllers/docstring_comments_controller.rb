class DocstringCommentsController < ApplicationController
  layout 'main'

  def index
    @dcs = DocstringComment.find(:all, :order => 'updated_at DESC')
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

    if current_user_session
      @notify_me = NotifyByEmail.find_by_user_id_and_target_id_and_target_type(current_user.id, @function.id, 'function_docstring_comment')
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

    to_notify = NotifyByEmail.find_all_by_target_id(dc.function.id, 'function_docstring_comment')

    to_notify.each do |tn|
      CommentsNotifier.deliver_comment_added(tn.user, dc)
    end

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

  def notify_me
    
    if not current_user_session
      render json_fail "You must be logged in up change your notification preferences." and return
    end

    if not params[:enabled]
      render json_fail "Notify me state not provided in request." and return
    end

    f = Function.find_by_id(params[:function_id])

    if not f
      render json_fail "Docstring not found." and return
    end

    enabled = (params[:enabled] == "true" ? true : false)

    existing = NotifyByEmail.find_by_user_id_and_target_id_and_target_type(current_user.id, f.id, 'function_docstring_comment')

    # ugly ugly

    if existing
      if not enabled
        existing.delete
      end
    elsif enabled
      n = NotifyByEmail.new
      n.user_id = current_user.id
      n.target_id = f.id
      n.target_type = 'function_docstring_comment'
      n.save
    end
    
    render :json => {:success => true, :enabled => enabled}
  end
end
