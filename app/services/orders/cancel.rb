module Orders
  class Cancel
    class NotCancellable < StandardError; end

    def initialize(order:)
      @order = order
    end

    def call
      Order.transaction do
        @order.lock!
        raise NotCancellable, "Solo se pueden cancelar pedidos pendientes" unless @order.status == "pending"

        @order.order_items.includes(:product).each do |item|
          product = Product.lock.find(item.product_id)
          product.update!(stock: product.stock + item.quantity)
        end
        @order.update!(status: "cancelled")
      end
      @order
    end
  end
end
