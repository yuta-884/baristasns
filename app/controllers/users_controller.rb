class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:show, :edit, :update, :followings, :followers]
  before_action :authenticate_user, only: [:edit, :update]
  
  def index
    @users = User.baristas.page(params[:page]).per(2)
  end

  def show
    @user = User.find(params[:id])
    @message = current_user.from_messages.build if logged_in?
    @messages = @user.user_recent
    counts(@user)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = @user.kind? ? "バリスタとして登録しました" : "ユーザーとして登録しました"
      redirect_to @user
    else
      flash.now[:danger] = "登録に失敗しました"
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(profile_params)
      flash[:success] = "情報が更新されました"
      redirect_to @user
    else
      flash.now[:danger] = "情報が更新されませんでした"
      render :edit
    end
  end
  
  def followings
    @user = User.find(params[:id])
    @message = Message.new
    @users = @user.followings.page(params[:page])
    counts(@user)
    render "showfollow"
  end
  
  def followers
    @user = User.find(params[:id])
    @message = Message.new
    @users = @user.followers.page(params[:page])
    counts(@user)
    render "showfollow"
  end
  
  private
  
    def user_params
      params.fetch(:user, {}).permit(:name, :email, :password, :password_confirmation, :kind)
    end
    
    def profile_params
      params.fetch(:user, {}).permit(:profile, :sns, :avatar)
    end
    
    def authenticate_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        flash[:danger] = "不正なアクセスです"
        redirect_to root_url
      end
    end
end
