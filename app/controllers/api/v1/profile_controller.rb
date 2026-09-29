class Api::V1::ProfileController < Api::V1::BaseController
  def show
    render json: { id: current_user.id, name: current_user.name, email: current_user.email, admin: current_user.admin? }
  end
end