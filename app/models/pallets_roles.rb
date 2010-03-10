class PalletsRole < ActiveRecord::Base
  belongs_to :pallet
  belongs_to :role
end
