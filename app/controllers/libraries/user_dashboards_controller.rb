class Libraries::UserDashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_library

  def show
    authorize @library, :user_dashboard?

    # Paginate each section with its unique parameter
    @books = @library.books.page(params[:books_page]).per(4)
    @approved_checkouts = current_user.checkouts.approved.includes(:book).page(params[:checkouts_page]).per(4)
    @wishlists = @library.wishlists.where(user: current_user).page(params[:wishlists_page]).per(4)
    @notifications = @library.notifications.order(created_at: :desc).page(params[:notifications_page]).per(4)

    # Initialize review object for the review form
    @review = Review.new
  end

  private

  def set_library
    Rails.logger.info "Params received: #{params.inspect}" # Add this for debugging
    if params[:id].present?
      @library = Library.find(params[:id])
      authorize @library, :user_dashboard?
    else
      redirect_to root_path, alert: "Library ID is missing."
    end
  end


end
