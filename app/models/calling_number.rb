class CallingNumber < ActiveRecord::Base
  validates_presence_of :number 
  belongs_to :customer 
  
  def self.create_main_number_by_employee( employee, customer ,  params )
    new_object = self.new
    new_object.creator_id  = customer.creator_id 
    new_object.customer_id = customer.id 
    new_object.number      = params[:number]
    new_object.case        = CALLING_NUMBER_CASE[:main]
    
    new_object.save
    return new_object 
  end
  
  def update_by_employee(employee,  params)
    return nil if employee.nil? 
    self.creator_id  = employee.id    
    self.number      = params[:number] 

    self.save
    return self 
  end
end
