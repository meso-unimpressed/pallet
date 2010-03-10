class SessionLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :pallet
  
  def self.last_login(user_id)
    SessionLog.find_all_by_user_id(user_id, :order => 'logged_in_at DESC').first
  end
  
  def self.recently_accessed_pallet(user_id)
    last_logins = SessionLog.find_all_by_user_id(user_id, :conditions => 'pallet_id > 0', :order => 'logged_in_at DESC')
    recently_accessed_pallet = last_logins.first.pallet rescue nil
    return recently_accessed_pallet
  end
  
  def self.update_pallet_id(user_id, pallet_id)
    last_login = SessionLog.last_login(user_id)
    return unless last_login
    SessionLog.update(last_login, :pallet_id => pallet_id)
  end

  def oca_creator
    User.find_by_id self.oca_creator_user_id
  end
  
end
