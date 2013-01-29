class Delivery < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :customer
  belongs_to :company 
  
  validates_presence_of :discount, :customer_id 
  
  
  validate :discount_below_upper_limit
  
  def discount_below_upper_limit
    lower_limit = BigDecimal('0')
    upper_limit = BigDecimal('100')
    if discount.present? and discount > upper_limit  or discount <  lower_limit 
      errors.add(:discount , "Diskon harus lebih besar dari #{lower_limit}, dan lebih kecil dari #{upper_limit}" ) 
    end
  end
  
  def generate_price 
    price = Price.current_active_price( self.customer_id, self.delivery_scenario_id )
    
    self.amount = ( 100 - discount ) * price.price 
    self.save 
  end
  
  def generate_code
    # get the total number of sales order created in that month 
    
    # total_sales_order = SalesOrder.where()
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    
   
    separator = '/'
    
    
    string = "DLV" + separator + 
              self.created_at.year.to_s + separator + 
              self.created_at.month.to_s + separator   + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
  
  
  def self.create_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    company = Company.first # extract from employee 
    
    new_object = self.new
    new_object.creator_id = employee.id 
    new_object.delivery_scenario_id = params[:delivery_scenario_id]
    new_object.customer_id          = params[:customer_id] 
    new_object.pickup_address       = params[:pickup_address] 
    new_object.delivery_address     = params[:delivery_address] 
    new_object.discount             = BigDecimal(params[:discount]  ) 

    if new_object.save 
      new_object.generate_code 
      new_object.generate_price 
    end
    
    return new_object 
  end
  
  def update_by_employee( employee, params ) 
    return nil if employee.nil? 
     
     
    self.creator_id = employee.id 
    self.delivery_scenario_id = params[:delivery_scenario_id]
    self.customer_id          = params[:customer_id] 
    self.pickup_address       = params[:pickup_address] 
    self.delivery_address     = params[:delivery_address] 
    self.discount             = BigDecimal(params[:discount]  )
    
    if self.save 
      self.generate_code 
      self.generate_price 
    end
    
    
    return self 
    
  end
  
end
