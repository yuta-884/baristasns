class UsersController < ApplicationController
  def index
    @users = User.baristas.page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      if @user.kind
        flash[:success] = "バリスタとして登録しました。"
        redirect_to @user
      else
        flash[:success] = "ユーザとして登録しました。"
        redirect_to @user
      end
    else
      flash.now[:danger] = "登録に失敗しました"
      render :new
    end
  end

  def edit
  end

  def update
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :kind)
  end
end
