class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validate :quantity_must_be_integer

  private

  def quantity_must_be_integer
    raw_quantity = attribute_before_type_cast(:quantity)
    return if raw_quantity.blank? || raw_quantity.to_s.match?(/\A[+-]?\d+\z/)

    errors.add(:quantity, :not_an_integer)
  end
end
