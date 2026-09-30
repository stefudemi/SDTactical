class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!

  layout "admin"

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_admin!
    unless current_user
      redirect_to login_path, alert: "Iniciá sesión para continuar."
      return
    end

    redirect_to root_path, alert: "No tenés permisos para acceder." unless current_user.admin?
  end
end
