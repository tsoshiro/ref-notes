class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    
    if @user && @user.authenticate(params[:session][:password])
      # ログイン成功
      log_in @user

      # チェックボックスがONならユーザーを記憶
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)

      redirect_to @user # ユーザーのプロフィールページにリダイレクト
    else
      # ログイン失敗 : エラーメッセージ作成
      flash.now[:danger] = 'メールアドレスかパスワードが無効です。'
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end