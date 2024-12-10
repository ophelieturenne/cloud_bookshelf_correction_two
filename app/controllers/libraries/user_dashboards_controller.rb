class Libraries::UserDashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_library

  def show
    authorize @library, :user_dashboard?

    @books = @library.books
    @approved_checkouts = current_user.checkouts.approved.includes(:book)
    @wishlists = @library.wishlists.where(user: current_user)
    @review = Review.new # Initialize review object for form
    @notifications = @library.notifications.order(created_at: :desc).limit(10) # Load latest notifications
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
