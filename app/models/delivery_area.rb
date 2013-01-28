class DeliveryArea < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :company 
  
  validates_presence_of :company_id , :name 
  
  def self.create_by_employee( employee,  params ) 
    return nil if employee.nil? 
    
    new_object = self.new
    new_object.creator_id = employee.id 
    new_object.name       = params[:name]
    new_object.company_id = params[:company_id] 

    if new_object.save 
    end
    
    return new_object 
  end
  
  def update_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    self.creator_id = employee.id 
    self.name       = params[:name]
    self.company_id = params[:company_id]
 
    
   
    if self.save 
    end
    
    return self 
  end
  
  
end
