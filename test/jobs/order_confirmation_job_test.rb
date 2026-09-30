require "test_helper"

class OrderConfirmationJobTest < ActiveJob::TestCase
  test "delivers once and skips a retry after success" do
    product = products(:one)
    order = Order.create!(user: users(:one))
    order.order_items.create!(product: product, quantity: 1, unit_price: product.price)
    ActionMailer::Base.deliveries.clear

    2.times { OrderConfirmationJob.perform_now(order.id) }

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert order.reload.confirmation_email_sent_at.present?
  end
end
