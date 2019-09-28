class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:show, :edit]
  
  def index
    @users = User.baristas.page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])
    @message = Message.new
    @messages = Message.user_recent(@user.id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      if @user.kind
        flash[:success] = "バリスタとして登録しました"
        redirect_to @user
      else
        flash[:success] = "ユーザとして登録しました"
        redirect_to @user
      end
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
    
    if @user.update(user_params)
      flash[:success] = "ユーザ情報が更新されました"
      redirect_to @user
    else
      flash.now[:danger] = "ユーザ情報が更新されませんでした"
      render :edit
    end
  end
  
  private
  
  def user_params
    params.fetch(:user, {}).permit(:name, :email, :password, :password_confirmation, :profile, :sns, :kind, :avatar)
  end
end
