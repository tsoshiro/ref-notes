class User < ApplicationRecord
  extend FriendlyId
  friendly_id :user_name , use: :slugged
  
  VALID_USER_NAME_REGEX = /\A\w[^\.^\s]+\z/i
  validates :user_name, presence: true,
                        uniqueness: { case_sensitive: false },
                        format: { with: VALID_USER_NAME_REGEX },
                        length: { minimum: 3, maximum: 25 }
  validates_presence_of :slug
  
  before_save :downcase
  validates :display_name, presence: true, length: { maximum: 150 }
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

  def downcase
    user_name.downcase!
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
      display_name:       auth.info.nickname,
      email:      auth.info.email || User.dummy_email(auth),
      password:   User.get_random_string(8),
      nickname:   auth.info.nickname,
      image:     auth.info.image,
      location:   auth.info.location,
      user_name: auth.info.nickname || User.auto_user_name(auth.info.email || User.dummy_email(auth))
      )
  end

  # user_nameがない場合は普通のfind
  def self.find(arg)
    friendly.find(arg) || super
  end
  
  private
    def self.dummy_email(auth)
      "#{auth.uid}-#{auth.provider}@example.com"
    end
    
    def self.auto_user_name(email)
      email.split("@")[0].parameterize
    end
    
    # nilじゃなくてもslugを更新する
    def should_generate_new_friendly_id?
     user_name_changed? || super
    end
end