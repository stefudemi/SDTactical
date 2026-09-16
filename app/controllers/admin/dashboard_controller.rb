class Admin::DashboardController < ApplicationController
  def index
    @product_count = Product.count
    @category_count = Category.count
    @order_count = Order.count
    @user_count = User.count
  end
end
