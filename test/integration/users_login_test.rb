require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  test "should show flash message if not validated" do
    get login_path # ログインページにアクセス
    assert_template 'sessions/new' # ログインページのテンプレートが表示されているか？
    
    post login_path, params: { session: { email: "", password: "" } } # ログインページにemail/passwordセットをPOST
    assert_not flash.empty? # 失敗のflashが出ている？
    get root_path # ホーム画面に遷移したら
    assert flash.empty? # flashが消えている？
  end
end
