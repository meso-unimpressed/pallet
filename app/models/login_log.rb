class LoginLog < ActiveRecord::Base
  belongs_to :pallet
  belongs_to :user
  
  def self.last_login(user_id)
    LoginLog.find_all_by_user_id(user_id, :order => 'login_time DESC').first
  end
  
  def self.recently_accessed_pallet(user_id)
    last_logins = LoginLog.find_all_by_user_id(user_id, :conditions => 'pallet_id > 0', :order => 'login_time DESC')
    recently_accessed_pallet = last_logins.first.pallet rescue nil
    return recently_accessed_pallet
  end
  
  def self.update_pallet_id(user_id, pallet_id)
    last_login = LoginLog.last_login(user_id)
    return unless last_login
    LoginLog.update(last_login, :pallet_id => pallet_id)
  end
  
end
