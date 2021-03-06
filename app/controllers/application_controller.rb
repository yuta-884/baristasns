class ApplicationController < ActionController::Base
  
  include SessionsHelper
  
  private
  
    def require_user_logged_in
      unless logged_in?
        store_location
        flash[:danger] = "ログインが必要です"
        redirect_to login_url
      end
    end
    
    def counts(user)
      @count_messages = user.from_messages.count
      @count_followings = user.followings.count
      @count_followers = user.followers.count
    end
end
