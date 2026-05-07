class Item < ApplicationRecord
  belongs_to :quote

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :vat_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :quote_must_be_editable
  before_destroy :prevent_destroy_when_validated

  def unit_price
    return if unit_price_cents.nil?

    unit_price_cents.to_d / 100
  end

  def unit_price=(value)
    decimal = BigDecimal(value.to_s, exception: false)

    self.unit_price_cents = decimal.present? ? (decimal * 100).round : nil
  end

  def subtotal_excl_vat_cents
    quantity * unit_price_cents
  end

  def vat_amount_cents
    ((subtotal_excl_vat_cents * vat_rate.to_d) / 100).round
  end

  def total_incl_vat_cents
    subtotal_excl_vat_cents + vat_amount_cents
  end

  private

  def quote_must_be_editable
    return if quote.editable?

    errors.add(:base, "Changement impossible sur un devis validé")
  end

  def prevent_destroy_when_validated
    return if quote.editable?

    errors.add(:base, "Article non supprimable car devis déjà validé")
    throw :abort
  end
end
