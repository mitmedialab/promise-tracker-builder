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

  def self.find_or_create_api_user(user_id, api_key)
    api_client = ApiKey.find_by(access_token: api_key).client_name.downcase
    username = "#{api_client}_#{user_id}"
    user = User.find_by(username: username)

    if user
      user
    else
      User.create(
        username: username, 
        password: Digest::SHA1.hexdigest(username),
        api_client_name: api_client
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
