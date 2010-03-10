class PalletAutoAssociatedRole < ActiveRecord::Base
  validates_uniqueness_of :role_id
end
