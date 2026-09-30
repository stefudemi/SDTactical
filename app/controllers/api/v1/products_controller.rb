class Api::V1::ProductsController < ActionController::API
  include Rails.application.routes.url_helpers

  def index
    render json: Product.includes(:category, image_attachment: :blob).order(:id).map { |product| product_json(product) }
  end

  def show
    product = Product.includes(:category, image_attachment: :blob).find(params[:id])
    render json: product_json(product)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Producto no encontrado" }, status: :not_found
  end

  private

  def product_json(product)
    {
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      category: { id: product.category_id, name: product.category.name },
      image_url: product.image.attached? ? rails_blob_path(product.image, only_path: true) : nil
    }
  end
end
