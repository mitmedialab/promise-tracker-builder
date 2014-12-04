class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, authentication_keys: [:username]
       
  has_many :campaigns
  has_many :surveys

  validates :username, uniqueness: true, presence: true

  def email_required?
    false
  end

  def self.find_or_create_api_user(user_id, username, api_key)
    api_client = ApiKey.find_by(access_token: api_key).client_name
    user = User.where(
      api_client_name: api_client,
      api_client_user_id: user_id).first

    if user
      user
    elsif user_id && username
      User.create(
        username: "#{username} (#{api_client})", 
        password: Digest::SHA1.hexdigest(username),
        api_client_name: api_client,
        api_client_user_id: user_id
      )
    end
  end

  protected
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value", { value: conditions[:username].downcase }]).first
  end
end
