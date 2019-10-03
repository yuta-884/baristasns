class ToppagesController < ApplicationController
  def index
    if logged_in?
      @messages = current_user.feed_messages.page(params[:page])
      @message = Message.new
    else
      @messages = Message.last(10)
    end
  end
end
