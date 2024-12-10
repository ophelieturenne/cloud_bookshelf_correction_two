class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  skip_after_action :verify_authorized, only: [:create] # Skip Pundit's authorization check for `create`


  def create
    @notification = Notification.new(notification_params.merge(user: current_user))

    if @notification.save
      redirect_to admin_dashboard_library_path(@notification.library), notice: "Notification created successfully."
    else
      redirect_back fallback_location: root_path, alert: "Failed to create notification."
    end
  end

  private

  def authorize_admin
    library = Library.find(params[:notification][:library_id])
    unless current_user.library_users.exists?(library: library, is_admin: true)
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end

  def notification_params
    params.require(:notification).permit(:content, :library_id)
  end
end
