# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
categories = [
  [ "Rifles", "Réplicas largas para airsoft." ],
  [ "Pistolas", "Réplicas cortas para airsoft." ],
  [ "Accesorios", "Accesorios y repuestos." ]
]

categories.each do |name, description|
  Category.find_or_create_by!(name: name) { |category| category.description = description }
end

# Photos from Wikimedia Commons (see db/seeds/images/CREDITS.md for authors and licenses).
catalog = [
  [ "Rifle de entrenamiento", "Rifles", "Réplica de airsoft estilo M4A1 con riel RIS, ideal para iniciarse en el juego.", 150000, 8, "m4a1.jpg" ],
  [ "AK-74M", "Rifles", "Réplica de airsoft del fusil de asalto AK-74M con cuerpo de metal y culata plegable.", 185000, 6, "ak74m.jpg" ],
  [ "Rifle de francotirador L96", "Rifles", "Réplica de cerrojo de largo alcance con mira telescópica, para tirador designado.", 210000, 4, "l96.jpg" ],
  [ "Pistola de entrenamiento", "Pistolas", "Réplica compacta de gas, ideal como arma secundaria.", 65000, 12, "beretta.jpg" ],
  [ "Colt 1911", "Pistolas", "Réplica clásica de la 1911 con corredera metálica y retroceso.", 78000, 9, "colt1911.jpg" ],
  [ "Makarov PM", "Pistolas", "Réplica de la pistola Makarov de resorte, liviana y confiable.", 42000, 15, "makarov.jpg" ],
  [ "Gafas de protección", "Accesorios", "Gafas de seguridad con protección lateral. Obligatorias en cualquier partida.", 12000, 30, "goggles.jpg" ],
  [ "Bolsa de BBs 0.20 g", "Accesorios", "Proyectiles de 6 mm y 0.20 g para réplicas eléctricas y de resorte.", 6500, 50, "bbs.jpg" ],
  [ "Cargador de Glock", "Accesorios", "Cargador de repuesto compatible con réplicas de Glock a gas.", 14000, 18, "glock-mag.jpg" ],
  [ "Portacargadores doble", "Accesorios", "Portacargadores doble para cinturón, para llevar recambios a mano.", 9500, 20, "mag-holder.jpg" ],
  [ "Cargador rápido de BBs", "Accesorios", "Speedloader para recargar los cargadores sin perder tiempo en juego.", 5500, 25, "bb-loader.jpg" ]
]

catalog.each do |name, category_name, description, price, stock, image_file|
  product = Product.find_or_initialize_by(name: name)
  if product.new_record?
    product.assign_attributes(category: Category.find_by!(name: category_name), description: description, price: price, stock: stock)
    product.save!
  end
  next if product.image.attached?

  path = Rails.root.join("db/seeds/images", image_file)
  product.image.attach(io: File.open(path), filename: image_file, content_type: "image/jpeg") if File.exist?(path)
end

if Rails.env.development?
  admin = User.find_or_initialize_by(email: "admin@sdtactical.test")
  unless admin.persisted?
    admin.name = "Administrador de desarrollo"
    admin.password = "dev-password-123"
  end
  admin.admin = true
  admin.save!

  customer = User.find_or_initialize_by(email: "cliente@sdtactical.test")
  unless customer.persisted?
    customer.name = "Cliente de demostración"
    customer.password = "demo-password-123"
  end
  customer.admin = false
  customer.save!
end
#   end
