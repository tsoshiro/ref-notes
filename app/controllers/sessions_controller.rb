class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)

    if @user && @user.authenticate(params[:session][:password]) # ユーザーの存在&パスワードチェック
      if @user.activated? # 有効化チェック
        log_in @user

        # チェックボックスがONならユーザーを記憶
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)

        # ログイン前に行こうとしていた画面があるならそこに、ないならユーザープロフィール画面に飛ばす
        redirect_back_or @user
      else
        message = 'アカウントは有効化されていません\n'
        message += 'Emailに送られた有効化リンクを確認してください'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # ログイン失敗 : エラーメッセージ作成
      flash.now[:danger] = 'メールアドレスかパスワードが無効です。'
      render 'new'
    end
  end

  # コールバック
  def create_auth
    auth = request.env['omniauth.auth']
    user = User.find_for_oauth(auth)

    # ユーザー認証が成功したら
    if user
      log_in user
      flash[:notice] = "ユーザー認証が完了しました"
      redirect_back_or user
    else
      flash[:danger] = "ユーザー認証に失敗しました"
      redirect_to root_url
    end
  end

  # SNSログインキャンセル時の処理
  def failure
    flash[:danger] = "SNSログインに失敗しました"
    redirect_to root_url
  end

  def destroy
    log_out if logged_in?
    flash[:notice] = "ログアウトしました"
    redirect_to root_path
  end
end
