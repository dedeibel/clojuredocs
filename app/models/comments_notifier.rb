class CommentsNotifier < ActionMailer::Base
  def comment_added(user, comment)
    @user = user
    @comment = comment
    
    recipients user.email
    from "contact@clojuredocs.org"
    subject "ClojureDocs - Docstring comment added to #{comment.function.namespace.name}/#{comment.function.name}"
  end
end
