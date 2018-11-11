require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

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

  test "valid signup info with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { user_name: "fugao",
                                         display_name: "Fuga Fugao",
                                         slug: "fugao",
                                         email: "user@valid.com",
                                         password: "foofoofoo",
                                         password_confirmation: "foofoofoo"}}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size # 配信メッセージが一つである
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でのログイン -> ログイン失敗する
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正 -> ログイン失敗する
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効 -> ログイン失敗する
    get edit_account_activation_path(user.activation_token, email: 'not-exist')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合 -> ログイン成功
    get edit_account_activation_path(user.activation_token, email:user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

  # test "valid submission" do
  #   get signup_path
  #   assert_difference 'User.count', 1 do
  #     post users_path, params: { user: { user_name: "fugao",
  #                                        display_name: "Fuga Fugao",
  #                                        slug: "fugao",
  #                                        email: "user@valid.com",
  #                                        password: "foofoofoo",
  #                                        password_confirmation: "foofoofoo"}}
  #   end
  #   follow_redirect! # リダイレクト先に遷移
  #   # assert_template 'users/show'
  #   # assert is_logged_in?
  # end
end
