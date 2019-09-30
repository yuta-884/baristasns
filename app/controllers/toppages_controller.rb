class ToppagesController < ApplicationController
  def index
    if logged_in?
      @messages = current_user.feed_messages.order(id: :desc).page(params[:page])
    else
      @messages = Message.last(10)
    end
  end
end
