class Employee < ActiveRecord::Base
  attr_accessible :name, :phone, :mobile , 
                  :email, :bbm_pin, :address 
  
  validates_presence_of :name 
  has_many :deliveries 
  
  def self.active_objects
    self.where(:is_deleted => false ).order("created_at DESC")
  end
  
  def generate_code
  end
  
  def self.create_by_employee(employee, params) 
    return nil if employee.nil? 
    company = Company.first   # company info will be extracted from the employee's job attachment 
     
    new_object = self.new
    new_object.creator_id = employee.id
    new_object.company_id = company.id 
    new_object.name         = params[:name] 
    new_object.mobile_phone = params[:mobile_phone]
    new_object.address      = params[:address]

    if new_object.save
      new_object.generate_code
    end 
    
    return new_object
  end
  
  def update_by_employee(employee, params)
     
    self.creator_id = employee.id 
    self.name         = params[:name] 
    self.mobile_phone = params[:mobile_phone]
    self.address      = params[:address]

    if self.save
      self.generate_code
    end 
    
    return self
  end
  
  def delete( employee) 
    return nil if employee.nil?
    
    self.is_deleted = true 
    self.save 
  end
end
