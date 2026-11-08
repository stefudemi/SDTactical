class Api::V1::ProfileController < Api::V1::BaseController
  def show
    render json: profile_json
  end

  def update
    if current_user.update(profile_params)
      render json: profile_json
    else
      render_record_errors(current_user)
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email)
  end

  def profile_json
    { id: current_user.id, name: current_user.name, email: current_user.email, admin: current_user.admin? }
  end
end
