class Api::V1::SessionsController < ActionController::API
  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    unless user&.authenticate(params[:password])
      render json: { error: "Email o contraseña inválidos" }, status: :unauthorized
      return
    end

    user.regenerate_api_token
    render json: { token: user.api_token, token_type: "Bearer" }, status: :ok
  end

  def destroy
    scheme, token = request.authorization.to_s.split(" ", 2)
    user = User.find_by(api_token: token) if scheme&.casecmp("Bearer")&.zero? && token.present?
    unless user
      render json: { error: "No autorizado" }, status: :unauthorized
      return
    end

    user.update!(api_token: nil)
    head :ok
  end
end
