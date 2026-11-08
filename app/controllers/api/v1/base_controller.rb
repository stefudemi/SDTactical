class Api::V1::BaseController < Api::V1::ApiController
  before_action :authenticate_api_user!

  private

  attr_reader :current_user

  def authenticate_api_user!
    @current_user = User.find_by(api_token: bearer_token) if bearer_token
    render json: { error: "No autorizado" }, status: :unauthorized unless @current_user
  end
end
