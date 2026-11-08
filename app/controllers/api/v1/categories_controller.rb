class Api::V1::CategoriesController < Api::V1::ApiController
  def index
    categories = Category.order(:name)
    render json: categories.map { |category| { id: category.id, name: category.name, description: category.description } }
  end
end
