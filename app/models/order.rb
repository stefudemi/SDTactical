class Order < ApplicationRecord
  STATUSES = %w[pending confirmed shipped cancelled].freeze

  belongs_to :user
  has_many :order_items, dependent: :restrict_with_exception

  before_validation :set_defaults

  validates :status, inclusion: { in: STATUSES }
  validates :total, numericality: { greater_than_or_equal_to: 0 }

  def recalculate_total!
    self.total = order_items.sum { |item| item.unit_price * item.quantity }
  end

  private

  def set_defaults
    self.status ||= "pending"
    self.total ||= 0
  end
end
