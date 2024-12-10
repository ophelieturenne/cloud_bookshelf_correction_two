class BookPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:library).where(library: user.libraries)
    end
  end

  def index?
    library_member?
  end

  def show?
    library_member?
  end

  def create?
    library_admin?
  end

  def update?
    library_admin?
  end

  def destroy?
    library_admin?
  end

  def reserve?
    library_member? && record.format == "hardcover" && record.quantity.positive?
  end

  def read?
    library_member? && record.format == "ebook"
  end

  def qr_code_download?
    Rails.logger.debug "User Libraries: #{user.libraries.inspect}"
  Rails.logger.debug "Record Library: #{record.library.inspect}"
  Rails.logger.debug "QR Code Present: #{record.qr_code.present?}"
  library_member? && record.qr_code.present?
  end



  private

  def library_admin?
    user.library_users.exists?(library: record.library, is_admin: true)
  end

  def library_member?
    user.libraries.include?(record.library)
  end
end
