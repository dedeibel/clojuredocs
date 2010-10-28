class DocstringComment < ActiveRecord::Base
  belongs_to :function
  belongs_to :user

  validates_presence_of :body, :function_id, :user_id
end
