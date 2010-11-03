require 'test_helper'

class DocstringCommentsControllerTest < ActionController::TestCase

  include Authlogic::TestCase
  setup :activate_authlogic

  should_succeed :index
  
  context "Adding a comment" do
    context "without a valid function id" do
      setup do
        get :new
      end

      should_json_fail
    end

    context "without a valid user" do
      setup do
        @f = Factory.create(:function)
        get :new, :function_id => @f.id
      end

      should_json_fail
    end

    context "with an empty body" do
      setup do
        @f = Factory.create(:function)
        @u = Factory.create(:user)
        UserSession.create(@u)
        
        get :new, :function_id => @f.id
      end

      should_json_fail
    end

    context "with valid info" do
      setup do
        @f = Factory.create(:function)
        @u = Factory.create(:user)
        UserSession.create(@u)
        
        get :new, :function_id => @f.id, :body => "hello world"
      end

      should_json_succeed
    end
  end

  context "Deleting a comment" do
    context "without a logged-in user" do
      setup do
        get :delete
      end

      should_json_fail
    end
    
    context "without a valid docstring comment id" do
      setup do
        @u = Factory.create(:user)
        UserSession.create(@u)

        get :delete
      end

      should_json_fail
    end

    context "with valid info" do
      setup do
        @dc = Factory.create(:docstring_comment)
        UserSession.create(@dc.user)

        get :delete, :id => @dc.id
      end

      should_json_succeed
    end
  end
end
