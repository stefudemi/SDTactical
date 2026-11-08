class Api::V1::SessionsController < Api::V1::ApiController
  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    unless user&.authenticate(params[:password])
      render json: { error: "Email o contraseña inválidos" }, status: :unauthorized
      return
    end

    user.regenerate_api_token
    render json: { token: user.api_token, token_type: "Bearer", user: { id: user.id, name: user.name, email: user.email, admin: user.admin? } }, status: :ok
  end

  def destroy
    user = User.find_by(api_token: bearer_token) if bearer_token
    unless user
      render json: { error: "No autorizado" }, status: :unauthorized
      return
    end

    user.update!(api_token: nil)
    head :ok
  end
end
