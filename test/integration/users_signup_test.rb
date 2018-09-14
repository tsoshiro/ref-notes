require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid submission" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { user_name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar"}}
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_not flash.nil?
  end
  
  test "valid submission" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { user_name: "hogeo",
                                         email: "user@valid.com",
                                         password: "foofoofoo",
                                         password_confirmation: "foofoofoo"}}
    end
    follow_redirect! # リダイレクト先に遷移
    assert_template 'users/show'
    assert is_logged_in?
  end
end