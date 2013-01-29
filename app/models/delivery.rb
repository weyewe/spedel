class Delivery < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :customer
  belongs_to :company 
  belongs_to :employee
  
  validates_presence_of :discount, :customer_id , :delivery_scenario_id 
  
  
  validate :discount_below_upper_limit
  
  def discount_below_upper_limit
    lower_limit = BigDecimal('0')
    upper_limit = BigDecimal('100')
    if discount.present? and discount > upper_limit  or discount <  lower_limit 
      errors.add(:discount , "Diskon harus lebih besar dari #{lower_limit}, dan lebih kecil dari #{upper_limit}" ) 
    end
  end
  
  def generate_price 
    price = BigDecimal('0')
    if self.customer.is_corporate_customer?
      price = Price.current_active_price( self.customer_id, self.delivery_scenario_id )
    else
      price = Price.current_active_price( nil , self.delivery_scenario_id )
    end
    
    
    self.amount = ( 100 - discount ) * price.price / 100.to_f
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
  
  def update_pickup(employee, params)
    self.is_picked_up = params[:is_picked_up]
    self.pickup_time  = params[:pickup_time]
    self.save
  end
  
  
  def update_delivery(employee, params)
    self.is_delivered = params[:is_delivered]
    self.delivery_time  = params[:delivery_time]
    self.save
  end
  
  def assign_employee(  employee )
    if employee.nil?
      errors.add(:employee_id , "Harus memilih karyawan" )
      return self 
    end
    
    self.employee_id = employee.id 
    self.save
    return self 
  end
  
  def approve( employee ) 
    return nil if self.is_approved == true 
    return nil if self.is_canceled == true 
    return nil if employee.nil? 
    customer = self.customer 
    
    ActiveRecord::Base.transaction do
      self.is_approved = true 
      self.approver_id = employee.id 
      self.approved_at = DateTime.now 
      self.save
      
      self.mark_as_paid(employee) if not customer.is_delayed_payment? 
    end
  end
  
  def mark_as_paid(employee)
    self.is_paid = true 
    self.payment_approver_id = employee.id 
    self.save
  end
end
