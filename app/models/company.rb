class Company < ActiveRecord::Base
  attr_accessible :name, :address, :phone 
  has_many :delivery_areas 
end
