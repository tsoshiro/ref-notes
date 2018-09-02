module SessionsHelper
  
  # 渡されたユーザーでログイン
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 現在のユーザーを返す
  def current_user
    if (user_id = session[:user_id]) # セッションにuser_idがあれば
      @current_user ||= User.find_by(id: user_id) # nilなら代入するが、そうでなければ何もしない
    elsif (user_id = cookies.signed[:user_id]) # クッキーにuser_idがあれば
      raise
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ログインしているか確認
  def logged_in?
    !current_user.nil?
  end
  
  # 忘れる
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # ログアウト
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # クッキーのトークンとDBのトークンダイジェストの照合
  def remember_me?
    # クッキーに保存されたuser_idからユーザーを取得
    user = User.find_by(id: cookies.signed[:user_id])
    user.authenticate(cookies.signed[:remember_token])
  end
end