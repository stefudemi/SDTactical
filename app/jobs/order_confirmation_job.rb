class OrderConfirmationJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  def perform(order_id)
    order = Order.find(order_id)
    order.with_lock do
      return if order.confirmation_email_sent_at?

      OrderConfirmationMailer.with(order_id: order.id).confirmation.deliver_now
      order.update!(confirmation_email_sent_at: Time.current)
    end
  end
end
