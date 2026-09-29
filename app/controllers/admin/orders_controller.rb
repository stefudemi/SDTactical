class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:show, :update]

  def index
    @orders = Order.includes(:user).order(created_at: :desc)
  end

  def show
    @order_items = @order.order_items.includes(:product)
  end

  def update
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Estado del pedido actualizado."
    else
      @order_items = @order.order_items.includes(:product)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.includes(:user).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end