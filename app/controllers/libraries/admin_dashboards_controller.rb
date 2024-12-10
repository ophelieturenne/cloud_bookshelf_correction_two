class Libraries::AdminDashboardsController < ApplicationController
  before_action :set_library

  def show
    authorize @library, :admin_dashboard?

    @books = @library.books.page(params[:page]).per(4) # Paginate books
    @users = @library.users.page(params[:users_page]).per(4) # Paginate users
    @pending_checkouts = @library.checkouts.pending.includes(:book, :user).page(params[:notifications_page]).per(4) # Paginate pending checkouts
    @notification = Notification.new # Initialize the notification object here
  end



  private

  def set_library
    @library = Library.find(params[:id])
    authorize @library, :admin_dashboard?
  end
end
