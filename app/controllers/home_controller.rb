class HomeController < ApplicationController
  skip_before_filter :role_required,  :only => [  
                                                :front_page
                                                ]
  def front_page
    render :file => 'home/front_page', :layout => 'layouts/front_page'
  end
end
