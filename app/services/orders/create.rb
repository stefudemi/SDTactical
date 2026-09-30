module Orders
  class Create
    class InvalidItems < StandardError; end
    class UnavailableProduct < StandardError; end
    class InsufficientStock < StandardError; end

    def initialize(user:, items:)
      @user = user
      @items = items
    end

    def call
      raise InvalidItems, "items debe incluir al menos un ítem" unless @items.is_a?(Array) && @items.any?

      Order.transaction do
        order = @user.orders.create!
        normalized_items.each do |product_id, quantity|
          product = Product.lock.find_by(id: product_id)
          raise UnavailableProduct, "Producto #{product_id} inexistente" unless product
          raise InsufficientStock, "Stock insuficiente para #{product.name}" if product.stock < quantity

          product.update!(stock: product.stock - quantity)
          order.order_items.create!(product: product, quantity: quantity, unit_price: product.price)
        end
        order.recalculate_total
        order.save!
        order
      end
    end

    private

    def normalized_items
      @items.map do |item|
        unless item.respond_to?(:[]) && item["product_id"].present?
          raise InvalidItems, "Cada ítem debe incluir product_id y quantity"
        end

        product_id = parse_integer(item["product_id"])
        quantity = parse_integer(item["quantity"])
        raise InvalidItems, "quantity debe ser positivo" unless quantity.positive?

        [ product_id, quantity ]
      rescue ArgumentError, TypeError
        raise InvalidItems, "product_id y quantity deben ser enteros válidos"
      end
    end

    def parse_integer(value)
      return value if value.is_a?(Integer)
      raise ArgumentError unless value.is_a?(String) && value.match?(/\A[+-]?\d+\z/)

      Integer(value, 10)
    end
  end
end
