class UsersController < ApplicationController
  
  def admin
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end
