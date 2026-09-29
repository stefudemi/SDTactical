class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :restrict_with_error
  has_one_attached :image

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :stock_must_be_integer

  private

  def stock_must_be_integer
    raw_stock = attribute_before_type_cast(:stock)
    return if raw_stock.blank? || raw_stock.to_s.match?(/\A[+-]?\d+\z/)

    errors.add(:stock, :not_an_integer)
  end
end
