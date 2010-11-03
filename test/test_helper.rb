ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'factory_girl'
require 'digest/sha1'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  # => 
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def self.should_response(action_name, response, params = {})
    context "The #{action_name} action with params #{params.inspect}" do
      setup do
        get action_name, params
      end

      should respond_with response
    end
  end
  
  def self.should_succeed(action_name, params = {})
    should_response action_name, :success, params
  end
  
  def json_resp
    JSON.parse(@response.body)
  end
  
  def self.should_have_json_prop(property, value)
    should "return json with property #{property} set to value #{value}" do
      resp = JSON.parse(@response.body)
      assert_equal value, resp[property]
    end
  end

  def self.should_json_fail
    self.should_have_json_prop('success', false)
  end

  def self.should_json_succeed
    self.should_have_json_prop('success', true)
  end
end

Factory.sequence :login do |n|
  "user#{n}"
end

Factory.sequence :email do |n|
  "user#{n}@clojuredocs.org" 
end

Factory.sequence :sha1 do |n|
  Digest::SHA1.hexdigest(n.to_s)
end

Factory.sequence :openid do |n|
  "http://#{n}.com/" + Digest::SHA1.hexdigest(n.to_s)
end

Factory.define :user do |u|
  u.login { Factory.next(:login) }
  u.email { Factory.next(:email) }
  u.crypted_password { Factory.next(:sha1) }
  u.password_salt { Factory.next(:sha1) }
  u.persistence_token { Factory.next(:sha1) }
  u.login_count 0
  u.failed_login_count 0
  u.openid_identifier { Factory.next(:openid) }
  u.password "testing"
  u.password_confirmation "testing"
end

Factory.sequence :function_name do |n|
  "function-#{n}"
end

Factory.sequence :namespace_name do |n|
  "namespace-#{n}"
end

Factory.sequence :library_name do |n|
  "library-#{n}"
end

Factory.define :library do |l|
  l.name { Factory.next(:library_name) }
  l.description "Hello World"
  l.site_url "http://clojure.org"
end
  
Factory.define :namespace do |n|
  n.name { Factory.next(:namespace_name) }
  n.doc "Test namespace docstring"
  n.source_url "/src/main/clojure/core.clj"
  n.version "1.2.0"
  n.association :library
end

Factory.define :function do |f|
  f_name = Factory.next(:function_name)
  f.file "clojure/core.clj"
  f.line 1
  f.arglists_comp "[x y z]"
  f.added "1.0"
  f.doc "Test docstring. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog."
  f.shortdoc "Test docstring. The quick brown fox jumps over the lazy dog. The quick"
  f.source "(defn #{f_name} [] \"hello world\")"
  f.version "1.2.0"
  f.url_friendly_name f_name
  f.association :namespace
end

Factory.define :docstring_comment do |d|
  d.association :user
  d.association :function
  d.body { Factory.next(:sha1) }
end


