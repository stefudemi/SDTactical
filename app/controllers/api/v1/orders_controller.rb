class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: :show

  def index
    orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
    render json: orders.map { |order| order_json(order) }
  end

  def show
    render json: order_json(@order)
  end

  def create
    order = Orders::Create.new(user: current_user, items: order_params).call
    render json: order_json(order), status: :created
  rescue Orders::Create::InvalidItems, Orders::Create::UnavailableProduct, Orders::Create::InsufficientStock => error
    render json: { error: error.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.to_hash }, status: :unprocessable_entity
  end

  private

  def set_order
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Pedido no encontrado" }, status: :not_found
  end

  def order_params
    raw_items = params.require(:order)[:items]
    return [] unless raw_items.is_a?(Array)

    raw_items.map do |item|
      item.permit(:product_id, :quantity).to_h
    end
  rescue ActionController::ParameterMissing
    []
  end

  def order_json(order)
    {
      id: order.id,
      status: order.status,
      total: order.total,
      created_at: order.created_at,
      items: order.order_items.map do |item|
        { product_id: item.product_id, product_name: item.product.name, quantity: item.quantity, unit_price: item.unit_price }
      end
    }
  end
end