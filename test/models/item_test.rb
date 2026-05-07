require "test_helper"

class ItemTest < ActiveSupport::TestCase
  setup do
    @quote = Quote.create!(name: "Devis client")
  end

  test "is valid with valid attributes" do
    item = @quote.items.build(name: "Design", quantity: 2, unit_price: 100, vat_rate: 20)

    assert item.valid?
  end

  test "converts unit price to cents" do
    item = @quote.items.build(name: "Design", quantity: 2, unit_price: "123.45", vat_rate: 20)

    assert_equal 12_345, item.unit_price_cents
    assert_equal "123.45".to_d, item.unit_price
  end

  test "requires a name" do
    item = @quote.items.build(name: nil, quantity: 2, unit_price_cents: 10_000, vat_rate: 20)

    assert_not item.valid?
    assert_includes item.errors[:name], "can't be blank"
  end

  test "requires a positive integer quantity" do
    item = @quote.items.build(name: "Design", quantity: 0, unit_price_cents: 10_000, vat_rate: 20)

    assert_not item.valid?
    assert_includes item.errors[:quantity], "must be greater than 0"
  end

  test "requires a non-negative unit price" do
    item = @quote.items.build(name: "Design", quantity: 2, unit_price_cents: -1, vat_rate: 20)

    assert_not item.valid?
    assert_includes item.errors[:unit_price], "must be greater than or equal to 0"
  end

  test "requires a vat rate between 0 and 100" do
    item = @quote.items.build(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 101)

    assert_not item.valid?
    assert_includes item.errors[:vat_rate], "must be less than or equal to 100"
  end

  test "calculates subtotal, vat amount, and total including vat" do
    item = @quote.items.build(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)

    assert_equal 20_000, item.subtotal_excl_vat_cents
    assert_equal 4_000, item.vat_amount_cents
    assert_equal 24_000, item.total_incl_vat_cents
  end

  test "cannot be created when quote is validated" do
    @quote.mark_as_validated!
    item = @quote.items.build(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)

    assert_not item.save
    assert_includes item.errors[:base], "Changement impossible sur un devis validé"
  end

  test "cannot be updated when quote is validated" do
    item = @quote.items.create!(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)
    @quote.mark_as_validated!

    item.name = "Nouveau nom"

    assert_not item.save
    assert_includes item.errors[:base], "Changement impossible sur un devis validé"
  end

  test "cannot be destroyed when quote is validated" do
    item = @quote.items.create!(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)
    @quote.mark_as_validated!

    assert_no_difference "Item.count" do
      assert_not item.destroy
    end
    assert_includes item.errors[:base], "Article non supprimable car devis déjà validé"
  end
end
