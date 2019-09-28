class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  has_one_attached :avatar
  
  
  has_many :from_messages, class_name: "Message", foreign_key: "from_id", dependent: :destroy
  has_many :sent_messages, through: :from_messages, source: :from
  has_many :to_messages, class_name: "Message", foreign_key: "to_id", dependent: :destroy
  has_many :received_messages, through: :to_messages, source: :to
  
  scope :baristas, -> { where(kind: true).order(id: :desc) }
  
  def thumbnail
    return self.avatar.variant(combine_options:{resize: "95x95^", crop: "95x95+0+0", gravity: :center}).processed
  end
  
  def icon
    return self.avatar.variant(combine_options:{resize: "160x160^", crop: "160x160+0+0", gravity: :center}).processed
  end
  
  def forpost
    return self.avatar.variant(combine_options:{resize: "50x50^", crop: "50x50+0+0", gravity: :center}).processed
  end
  
  def send_message(to_id, content)
    from_messages.create!(to_id: to_id, content: content)
  end
end
