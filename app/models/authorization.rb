class Authorization < ApplicationRecord
  belongs_to :user
  
  #:providerと:uidはもちろんのことユーザーとの紐付け(:user_id)も保証
  validates_presence_of :user_id, :uid, :provider
  
  #:providerと:uidのペアは一意であることを保証
  validates_uniqueness_of :uid, uniqueness: {:scope => :provider}

  # :providerと:uidからユーザーを検索  
  def self.find_from_hash(hash)
    find_by_provider_and_uid(hash['provider'], hash['uid'])
  end
  
  # :新規Authorization作成
  def self.create_from_hash(hash, user = nil)
    user ||= User.create_from_hash!(hash)
    Authorization.create(:user => user, :uid => hash['uid'], :provider => hash['provider'])
  end
end
