class DocstringComment < ActiveRecord::Base
  belongs_to :function
  belongs_to :user
end
