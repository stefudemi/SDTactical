class OrderConfirmationMailer < ApplicationMailer
  def confirmation
    @order = Order.includes(order_items: :product).find(params[:order_id])
    mail(to: @order.user.email, subject: "Confirmación de pedido ##{@order.id}")
  end
end
