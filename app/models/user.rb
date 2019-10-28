class User < ApplicationRecord
  attr_accessor :remember_token
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
    followings.include?(other_user)
  end
  
  # def feed_messages
  #   Message.where(from_id: self.following_ids + [self.id]).or(Message.where(to_id: [self.id]))
  # end
  
  def feed_messages
    following_ids = "SELECT follow_id FROM relationships WHERE user_id = :user_id"
    Message.where("from_id IN (#{following_ids}) OR from_id = :user_id OR to_id = :user_id", user_id: id)
  end
  
  def user_recent
    Message.where("from_id = ? OR to_id = ?", id, id)
  end
  
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
end
