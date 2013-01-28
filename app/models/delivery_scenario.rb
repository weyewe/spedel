class DeliveryScenario < ActiveRecord::Base
  # attr_accessible :title, :body
  validates_presence_of :source_id, :target_id , :company_id 
  def source
    DeliveryArea.where(:id => self.source_id ).first 
  end
  
  def target
    DeliveryArea.where(:id => self.target_id  ).first 
  end
end
