class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ログイン成功
      render 'new'
    else
      # ログイン失敗 : エラーメッセージ作成
      flash.now[:danger] = 'メールアドレスかパスワードが無効です。'
      render 'new'
    end
  end
  
  def destroy
  end
end
