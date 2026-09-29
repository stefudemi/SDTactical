class Category < ApplicationRecord
<<<<<<< HEAD
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true
=======
    has_many :products, dependent: :restrict_with_error

    validates :name, presence: true
>>>>>>> e646093 (Complete admin categories and orders CRUD)
end
