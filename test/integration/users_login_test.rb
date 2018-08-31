require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:hogeo)
  end
  
  test "should show flash message if not validated" do
    get login_path # ログインページにアクセス
    assert_template 'sessions/new' # ログインページのテンプレートが表示されているか？
    
    post login_path, params: { session: { email: "", password: "" } } # ログインページにemail/passwordセットをPOST
    assert_not flash.empty? # 失敗のflashが出ている？
    get root_path # ホーム画面に遷移したら
    assert flash.empty? # flashが消えている？
  end
  
  test "login with valid information followed by logout" do
    get login_path
    assert_template 'sessions/new'
    
    post login_path, params: { session: { email: @user.email, password: "hogehogehoge" } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!

    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,       count: 0
    assert_select "a[href=?]", user_path(@user),  count: 0
  end
end
