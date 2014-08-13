

class User < ActiveRecord::Base
  include Sluggable
  
  has_many :posts
  has_many :comments
  has_many :votes

  has_secure_password validation: false

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, length: {minimum: 5} 

  sluggable_column :username

  def two_factor_auth?
    !self.phone.blank?
  end

  def generate_pin!
    self.update_column(:pin, rand(10 ** 6)) # randome 6 digit number
  end

  def remove_pin!
    self.update_column(:pin, nil) 
  end

  def send_pin_to_twilio
    # put your own credentials here 
    account_sid = 'AC558fa903cbac81e5576269745d22362e' 
    auth_token = '62ac0a5c36fe6e9745c8442f1b959691' 
     
    # set up a client to talk to the Twilio REST API 
    client = Twilio::REST::Client.new account_sid, auth_token 
     
    msg = "Hey, please input the pin to continue login: #{self.pin}"
    to = self.phone
    client.account.messages.create({
      :from => '+18582231358', :to => to, :body => msg   
    })
  end

  def admin?
    self.role == 'admin'
  end

  def moderator?
    self.role == 'moderate'
  end
end