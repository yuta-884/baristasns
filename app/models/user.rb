class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  has_one_attached :avatar
  
  scope :baristas, -> { where(kind: true).order(id: :desc) }
  
  def thumbnail
    return self.avatar.variant(gravity: "center", crop: "200x200+0+0", resize: "100x100+0+0").processed
  end
  
  def icon
    return self.avatar.variant(gravity: "center", crop: "300x300+0+0", resize: "200x200+0+0").processed
  end
end
