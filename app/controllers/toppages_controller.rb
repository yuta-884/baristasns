class ToppagesController < ApplicationController
  def index
    if logged_in?
      @messages = Message.user_recent(current_user.id)
    else
      @messages = Message.last(10)
    end
  end
end
