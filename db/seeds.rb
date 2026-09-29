# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
categories = [
	["Rifles", "Réplicas largas para airsoft."],
	["Pistolas", "Réplicas cortas para airsoft."],
	["Accesorios", "Accesorios y repuestos."]
]

categories.each do |name, description|
	Category.find_or_create_by!(name: name) { |category| category.description = description }
end

Product.find_or_create_by!(name: "Rifle de entrenamiento") do |product|
	product.category = Category.find_by!(name: "Rifles")
	product.description = "Producto de ejemplo para desarrollo."
	product.price = 150000
	product.stock = 8
end

Product.find_or_create_by!(name: "Pistola de entrenamiento") do |product|
	product.category = Category.find_by!(name: "Pistolas")
	product.description = "Producto de ejemplo para desarrollo."
	product.price = 65000
	product.stock = 12
end

if Rails.env.development?
	admin = User.find_or_initialize_by(email: "admin@sdtactical.test")
	unless admin.persisted?
		admin.name = "Administrador de desarrollo"
		admin.password = "dev-password-123"
	end
	admin.admin = true
	admin.save!
end
#   end
