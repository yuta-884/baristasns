class Message < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"
  
  default_scope -> {order(id: :desc)}
  
  validates :content, presence: true, length: { maximum: 255 }
  validates :from_id, presence: true
  validates :to_id, presence: true
  
  def Message.user_recent(user_id)
    where(from_id: user_id).last(250)+where(to_id: user_id).last(250)
  end
end
