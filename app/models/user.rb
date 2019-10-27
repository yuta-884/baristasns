class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: {maximum: 25}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :profile, length: {maximum: 150}
  validates :sns, format: /\A#{URI::regexp(%w(http https))}\z/, length: {maximum: 100}, allow_blank: true
                  
  has_one_attached :avatar
  
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: "Relationship", foreign_key: "follow_id"
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :from_messages, class_name: "Message", foreign_key: "from_id", dependent: :destroy
  has_many :sent_messages, through: :from_messages, source: :to
  has_many :to_messages, class_name: "Message", foreign_key: "to_id", dependent: :destroy
  has_many :received_messages, through: :to_messages, source: :from
  
  scope :baristas, -> { where(kind: true).order(id: :desc) }
  
  def thumbnail
    return self.avatar.variant(combine_options:{resize: "95x95^", crop: "95x95+0+0", gravity: :center}).processed
  end
  
  def icon
    return self.avatar.variant(combine_options:{resize: "125x125^", crop: "125x125+0+0", gravity: :center}).processed
  end
  
  def forpost
    return self.avatar.variant(combine_options:{resize: "35x35^", crop: "35x35+0+0", gravity: :center}).processed
  end
  
  def send_message(to_id, content)
    from_messages.create!(to_id: to_id, content: content)
  end
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_messages
    Message.where(from_id: self.following_ids + [self.id]).or(Message.where(to_id: [self.id]))
  end
  
  def user_recent
    Message.where("from_id = ? or to_id = ?", [self.id], [self.id]).last(250)
  end
end
