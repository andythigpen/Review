class HomeController < ApplicationController
  def index
    if not user_signed_in?
      redirect_to new_user_session_path
    else
      @current_requests = current_user.current_requests
      @current_requests = Kaminari.paginate_array(@current_requests).
                            page(params[:cur]).per(5)
      @my_reviews = ReviewEvent.find_all_by_user_id(current_user.id, 
                                                    :order => "updated_at DESC")
      @my_reviews = Kaminari.paginate_array(@my_reviews).
                      page(params[:rev]).per(5)
    end 
  end
end
