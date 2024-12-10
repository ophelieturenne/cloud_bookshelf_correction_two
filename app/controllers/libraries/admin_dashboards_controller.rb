class Libraries::AdminDashboardsController < ApplicationController
  before_action :set_library

  def show
    authorize @library, :admin_dashboard?

    @books = @library.books
    @users = @library.users
    @pending_checkouts = @library.checkouts.pending.includes(:book, :user)
    @notification = Notification.new # Initialize the notification object here
  end

  

  private

  def set_library
    @library = Library.find(params[:id])
    authorize @library, :admin_dashboard?
  end
end
