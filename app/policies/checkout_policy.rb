class CheckoutPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  
  def index?
   user_is_admin?  # user can view list of their reservations
  end

  def create?
   user_is_admin?  # user can create a reservation
  end

  def update?
   user_is_admin?  
  end

  def destroy?
   user_is_admin?  # user can delete the reservation
  end

  private

  def user_is_admin?
    record.library_users.exist?(user_id: user.id, is_admin: true) # check if user has an admin record in library_users for this library
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end