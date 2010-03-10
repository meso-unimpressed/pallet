class Role < ActiveRecord::Base
  acts_as_tree  # hierarchical, self-referential

  has_many :roles_users
  has_many :users, :through => :roles_users
  has_and_belongs_to_many :pallets
  
  validates_uniqueness_of :title
  validates_length_of :title, :within => 3..160
  
end
