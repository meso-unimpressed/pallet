class PalletOneClickAccess < ActiveRecord::Base
  include NicePasswords
  
  belongs_to :pallet
  belongs_to :user



  def validate
    valid_expiration_date?
    valid_sub_path?
  end

  def before_create
    self.token = nice_token
  end
  


  def access_time_left
    (self.expires_at - Time.now).to_i
  end
  
  def expired?
    return false if self.access_time_left > 0
    true
  end
  
  def valid_sub_path?
    path = self.pallet.path + self.sub_path
    unless File.directory? path
      errors.add :sub_path, "is invalid"
      return false
    end
    true
  end
  
  def valid_expiration_date?
    unless self.expires_at > (Time.now + 5 * 60)
      errors.add :expires_at, "Expiration Date should be at least 5 minutes from now"
      return false
    end
    true
  end

  def invite_email_receivers
    for email_receiver in self.email_receivers.split(',')
      OneClickAccessMailer.deliver_invitation(self, email_receiver)
    end
  end
  
  def nice_token
    token = []
    2.times do
      template = generate_nice_password
      token << template[0..3]
      token << template[4..7]
    end
    return token.join('-')
  end

end
