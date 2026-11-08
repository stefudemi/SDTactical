class Api::V1::ProductsController < ActionController::API
  include Rails.application.routes.url_helpers

  def index
    products = Product.includes(:category, image_attachment: :blob).order(:id)
    products = products.where(category_id: params[:category_id]) if params[:category_id].present?
    if params[:q].present?
      term = "%#{Product.sanitize_sql_like(params[:q].to_s.strip)}%"
      products = products.where("products.name LIKE :term OR products.description LIKE :term", term: term)
    end
    render json: products.map { |product| product_json(product) }
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
