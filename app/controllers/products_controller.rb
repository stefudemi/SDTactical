class ProductsController < ApplicationController
  def index
    @products = Product.includes(:category, image_attachment: :blob).order(created_at: :desc)
    @categories = Category.all
  end

  def show
    @product = Product.includes(:category).find(params[:id])
    @related_products = Product.includes(:category, image_attachment: :blob)
      .where(category_id: @product.category_id)
      .where.not(id: @product.id)
      .limit(3)
  end
end
