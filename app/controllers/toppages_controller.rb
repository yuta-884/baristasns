class ToppagesController < ApplicationController
  def index
    if logged_in?
      @message = current_user.from_messages.build
      @messages = current_user.feed_messages.page(params[:page])
    else
      @messages = Message.last(10)
    end
  end
end
