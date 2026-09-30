class Api::V1::BaseController < ActionController::API
  before_action :authenticate_api_user!

  private

  attr_reader :current_user

  def authenticate_api_user!
    scheme, token = request.authorization.to_s.split(" ", 2)
    @current_user = User.find_by(api_token: token) if scheme&.casecmp("Bearer")&.zero? && token.present?
    render json: { error: "No autorizado" }, status: :unauthorized unless @current_user
  end

  def render_record_errors(record)
    render json: { errors: record.errors.to_hash }, status: :unprocessable_entity
  end
end
