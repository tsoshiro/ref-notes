class User < ApplicationRecord
  before_save :downcase_email
  validates :name, presence: true, length: { maximum: 150 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 }, 
                    uniqueness: { case_sensitive: false }, 
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
  validates :password, presence: true,
                       length: { minimum: 8 },
                      allow_nil: true # ユーザー情報更新でpasswordを空にしたときでも動く
  attr_accessor :remember_token
  
  has_many :authorizations
                       
  def downcase_email
    email.downcase!
  end
  
  # 文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # ランダムな文字列を返す
  def User.get_random_string(count)
    SecureRandom.base64(count)
  end
  
  # トークンを記憶させる
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンとダイジェストが一致したらtrue
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # トークンを忘れる
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # SNS Login
  def self.find_for_oauth(auth)
    # Authorizationモデルで検索
    authorization = Authorization.find_from_hash(auth)

    # Authorizationモデルがない場合、AuthorizationとUserを新規作成してUserを返す
    unless authorization
      authorization = Authorization.create_from_hash(auth)
    end
    
    # Authorizationがあるなら、該当するユーザーがいるか検索
    user = User.where(id: authorization.user_id).first

    # Authorizationモデルはあるがユーザーがない場合は、新規作成してUserを返す
    unless user
      user = User.create_from_hash!(auth)
      
      return user
    end
    
    user
  end
  
  # auth情報からユーザー作成して返す
  def self.create_from_hash!(auth)
    User.create(
      name:       auth.info.nickname,
      email:      auth.info.email || User.dummy_email(auth),
      password:   User.get_random_string(8),
      nickname:   auth.info.nickname,
      image:     auth.info.image,
      location:   auth.info.location
      )
  end  
  
  private
    def self.dummy_email(auth)
      "#{auth.uid}-#{auth.provider}@example.com"
    end
end