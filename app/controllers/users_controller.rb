class UsersController < ApplicationController
  def index
    @text = "Welcome to ref-notes"
  end
  
  def show
    @user = User.find(params[:id]) 
    
    # @microposts = @user.microposts.paginate(page: params[:page])
    # redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # 保存の成功処理
      log_in @user
      flash[:success] = "#{APP_NAME}へようこそ！"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
