class UsersController < ApplicationController
  before_action :logged_in_user,  only: [:edit, :update, :index, :destroy]
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: [:destroy]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated == true
    # @microposts = @user.microposts.paginate(page: params[:page])
    # redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def auto_fix_display_name_and_slug(user)
    user.display_name ||= user.user_name
    user.slug ||= user.display_name.parameterize
    user
  end

  def create
    @user = auto_fix_display_name_and_slug(User.new(user_params))
    if @user.save
      # 保存の成功処理
      @user.send_activation_email
      flash[:info] = "Emailを確認し、アカウントを有効化してください"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 更新成功
      flash[:success] = "ユーザー情報が更新されました"
      redirect_to @user
    else
      # 更新失敗
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーが削除されました"
    redirect_to users_url
  end

  private
    def user_params
      params.require(:user).permit(:display_name, :email, :password, :user_name, :slug)
    end

    # before action

    # ログイン済みユーザーでなければログイン促す
    def logged_in_user
      if !logged_in?
        store_location  # 遷移先を保存
        flash[:danger] = "ログインしてください"
        redirect_to login_url
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless @user == current_user
    end

    # 管理ユーザーかどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
