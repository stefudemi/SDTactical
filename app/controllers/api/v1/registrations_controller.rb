class Api::V1::RegistrationsController < ActionController::API
  def create
    user = User.new(registration_params)
    user.admin = false

    if user.save
      render json: session_json(user), status: :created
    else
      render json: { errors: user.errors.to_hash }, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def session_json(user)
    { token: user.api_token, token_type: "Bearer", user: { id: user.id, name: user.name, email: user.email } }
  end
end
