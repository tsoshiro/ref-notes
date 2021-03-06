require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:hogeo)
    @other_user = users(:michael)
  end
  
  test "should redirected edit when not logged in" do
    get edit_user_path(@user)
    
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "unsuccessful edit" do
    log_in_as(@user)
    
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { user_name: "fuga fugao",
                                              display_name: " ",
                                              email: "foo@invalid",
                                              password: "foo" }}
    assert_template 'users/edit'
    assert_select 'div#error_explanation li', count: 4
  end
  
  test "successful edit" do
    # Friendly forwarding
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    assert_nil session[:forwarding_url]
    
    user_name = "hoge-hogeo"
    display_name = "Hoge hogeo"
    email ="hogeo@hogehoge.com"
    patch user_path(@user), params: { user: { user_name: user_name,
                                              display_name: display_name,
                                              email: email,
                                              password: "" }}

    assert_not flash.empty?
    @user.reload
    assert_redirected_to @user
    assert_equal user_name, @user.user_name
    assert_equal email, @user.email
  end
  
  # 他人の情報編集ページにはログインしてても遷移できない
  test "should not edit wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  # 他人の情報はログインしてても編集できない
  test "should not update wrong user" do
    log_in_as(@other_user)
    
    name = "Hoge Hoge"
    email ="hogeo@hogehoge.com"
    patch user_path(@user), params: { user: { user_name: name,
                                              email: email }}
    assert flash.empty?
    assert_redirected_to root_url
  end
end