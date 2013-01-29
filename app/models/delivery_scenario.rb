class DeliveryScenario < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :prices # one for the public customer, and the rest is for the corporate customer 
  
  validates_presence_of :source_id, :target_id , :company_id 
  validate :no_duplicate_delivery_scenario
  
  def no_duplicate_delivery_scenario
    ds_list_count = DeliveryScenario.where(:source_id => self.source_id, 
                :target_id => self.target_id, 
                :company_id => self.company_id) .count 
                
    if self.persisted? and ds_list_count  != 1 
      errors.add(:source_id , "Sudah ada perjalanan dengan asal dan tujuan seperti ini " )  
      errors.add(:target_id , "Sudah ada perjalanan dengan asal dan tujuan seperti ini " )  
    elsif not self.persisted? and ds_list_count != 0 
      errors.add(:source_id , "Sudah ada perjalanan dengan asal dan tujuan seperti ini " )  
      errors.add(:target_id , "Sudah ada perjalanan dengan asal dan tujuan seperti ini " )
    end
    
  end
  
  
  def source
    DeliveryArea.where(:id => self.source_id ).first 
  end
  
  def target
    DeliveryArea.where(:id => self.target_id  ).first 
  end
  
  
  def self.create_by_employee( employee , params )
    return nil if employee.nil? 
    company = Company.first   # company info will be extracted from the employee's job attachment 
     
    new_object = self.new
    new_object.creator_id = employee.id
    new_object.company_id = company.id 
    new_object.source_id  = params[:source_id]
    new_object.target_id  = params[:target_id]
    
    new_object.save 
    
    return new_object
  end
  
  def public_price
    self.prices.where(:is_active => true ).first  
  end
  
end
