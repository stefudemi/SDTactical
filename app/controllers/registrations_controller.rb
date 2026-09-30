class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params.except(:password_confirmation))
    @user.password_confirmation = registration_params[:password_confirmation]
    @user.admin = false
    @user.valid?
    @user.errors.add(:password_confirmation, :blank) if @user.password_confirmation.blank?

    if @user.errors.empty? && @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Cuenta creada. Iniciaste sesión correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
