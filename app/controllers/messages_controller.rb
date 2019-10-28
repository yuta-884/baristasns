class MessagesController < ApplicationController
  before_action :require_user_logged_in
  before_action :correct_user, only: [:destroy]
  
  def create
    @message = current_user.from_messages.build(message_params)
    if @message.save
      flash[:success] = "メッセージを作成しました"
      redirect_back(fallback_location: root_path)
    else
      flash[:danger] = "メッセージの作成に失敗しました"
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    @message.destroy
    flash[:success] = "メッセージを削除しました"
    redirect_back(fallback_location: current_user)
  end
  
  private
  
  def message_params
    params.require(:message).permit(:to_id, :content, :reply_id)
  end
  
  def correct_user
    @message = current_user.from_messages.find_by(id: params[:id])
    redirect_back(fallback_location: current_user) if @message.nil?
  end
end
