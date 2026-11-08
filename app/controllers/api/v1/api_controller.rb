class Api::V1::ApiController < ActionController::API
  around_action :use_spanish_locale

  rescue_from ActionController::ParameterMissing do |error|
    render json: { error: "Falta el parámetro #{error.param}" }, status: :bad_request
  end

  rescue_from ActionDispatch::Http::Parameters::ParseError do
    render json: { error: "El cuerpo de la petición no es un JSON válido" }, status: :bad_request
  end

  private

  def use_spanish_locale(&block)
    I18n.with_locale(:es, &block)
  end

  def bearer_token
    scheme, token = request.authorization.to_s.split(" ", 2)
    token if scheme&.casecmp("Bearer")&.zero? && token.present?
  end

  def render_record_errors(record)
    render json: { errors: record.errors.to_hash }, status: :unprocessable_entity
  end
end
