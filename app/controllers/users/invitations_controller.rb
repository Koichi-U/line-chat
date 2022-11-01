class Users::InvitationsController < Devise::InvitationsController
  def update
    if some_condition
      redirect_to root_path
    else
      super
    end
  end
end