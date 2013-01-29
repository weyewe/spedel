class Price < ActiveRecord::Base
  # attr_accessible :title, :body
  
  belongs_to :delivery_scenario 
  validate :price_must_be_larger_than_zero
  # validate :can_only_have_one_active_price
  
  def price_must_be_larger_than_zero
    if not price.present? or price <= BigDecimal('0')
      errors.add(:price , "Harga harus lebih besar dari 0" )  
    end
  end
  
  # def can_only_have_one_active_price
  #   delivery_scenario_id = self.delivery_scenario_id
  #   if self.customer_id.nil? 
  #     if self.persisted and Price.where{
  #       ( customer_id.eq nil) &   # public price
  #       ( is_active.eq true ) &   # still active 
  #       ( delivery_scenario_id.eq delivery_scenario_id)
  #     }
  #   elsif not self.customer_id.nil?
  #   end
  # end
  
  def self.current_active_price( customer_id, delivery_scenario_id )
    Price.where(
      :is_active => true, 
      :customer_id => customer_id,
      :delivery_scenario_id => delivery_scenario_id
    ).order("created_at DESC").first 
  end
  
  
  def self.create_by_employee( employee , is_corporate,  params )
    # Price.create_public_price_by_employee( @admin, {
    #   :delivery_scenario_id => @first_da.id , 
    #   :price => price_amount ,
    #   :customer_id => nil 
    # })
    
    
    return nil if employee.nil? 
    
                
    
    company = Company.first   # company info will be extracted from the employee's job attachment 
     
    new_object = self.new
    new_object.creator_id = employee.id
    new_object.company_id = company.id  
    new_object.delivery_scenario_id       = params[:delivery_scenario_id]
    new_object.price = BigDecimal( params[:price]  ) 
    if is_corporate
      new_object.customer_id = params[:customer_id]
    end

    
    current_active_price = self.current_active_price(  
                params[:customer_id], 
                params[:delivery_scenario_id])
                
     
    
    if new_object.save  and not current_active_price.nil?  
      current_active_price.is_active = false 
      current_active_price.save
    end
    
    return new_object
  end
end
