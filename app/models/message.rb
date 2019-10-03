class Message < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"
  
  has_many :replies, class_name: "Message", foreign_key: "reply_id", dependent: :destroy
  belongs_to :original, class_name: "Message", optional: true
  
  default_scope -> {order(id: :desc)}
  
  validates :content, presence: true, length: { maximum: 255 }
  validates :from_id, presence: true
  validates :to_id, presence: true
end
