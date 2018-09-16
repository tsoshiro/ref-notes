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
    # ログイン画面に遷移してログイン画面を表示
    get login_path
    assert_template 'sessions/new'
    
    # email/passwordを入力し、ユーザーのプロフィールページに遷移
    post login_path, params: { session: { email: @user.email, password: "hogehogehoge" } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!

    # 遷移先のページのレイアウトテスト
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    
    # ログアウトするとルートURLにリダイレクトされる
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレート
    delete logout_path
    
    # ログアウトした状態のヘッダーをテスト
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,       count: 0
    assert_select "a[href=?]", user_path(@user),  count: 0
  end
  
  test "login with remember me" do
    log_in_as(@user, remember_me: '1')
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test "login without remember me" do
    # クッキー保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    
    # クッキーを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert assigns(:user).remember_token.nil?
    assert_empty cookies['remember_token']
  end
  
  # SNSログイン
  test "login with SNS" do
    OmniAuth.config.test_mode = true
    
    # モックデータ
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      provider: 'twitter', 
      uid: '123545', 
      info: { nickname: 'twfugao' }
    })
    
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
    assert_difference 'User.count', 1 do
      get '/auth/twitter' # Twitterログイン
      assert_redirected_to '/auth/twitter/callback' # 認証し、コールバック
      follow_redirect! # リダイレクト先についていく
      @twitter_user = User.find('twfugao') # この時点でユーザー生成されている
      assert_redirected_to @twitter_user # ユーザーのページに遷移
    end
  end
  
  # SNSログイン失敗
  # test "login failed with SNS" do
  #   OmniAuth.config.test_mode = true
    
  #   # 失敗時にFailureにリダイレクトさせる
  #   OmniAuth.config.on_failure = Proc.new { |env|
  #   OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  #   }
    
  #   # モックデータ
  #   OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
    
  #   Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
    
  #   assert_no_difference 'User.count', 1 do 
  #     get '/auth/twitter' # Twitterログイン
  #     assert_redirected_to '/auth/twitter/callback'
  #     follow_redirect!
  #     assert_redirected_to '/auth/failure' # 認証失敗
  #     follow_redirect! # リダイレクト先についていく
  #     redirected_to root_url
  #     assert_not flash.empty?
  #   end
  # end
end