class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update]

  def index
    @orders = Order.includes(:user).order(created_at: :desc)
  end

  def show
    @order_items = @order.order_items.includes(:product)
  end

  def edit
    @statuses = available_statuses
  end

  def update
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Estado del pedido actualizado correctamente."
    else
      @statuses = available_statuses
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.includes(:user).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end

  def available_statuses
    (["pending", "processing", "shipped", "completed", "cancelled"] + [@order.status]).compact.uniq
  end
end
