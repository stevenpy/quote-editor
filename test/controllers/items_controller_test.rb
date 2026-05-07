require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quote = Quote.create!(name: "Devis client")
  end

  test "should create item for draft quote" do
    assert_difference "Item.count", 1 do
      post quote_items_path(@quote), params: {
        item: {
          name: "Design",
          quantity: 2,
          unit_price: 100,
          vat_rate: 20
        }
      }
    end

    assert_redirected_to quote_path(@quote)
  end

  test "should not create item for validated quote" do
    @quote.mark_as_validated!

    assert_no_difference "Item.count" do
      post quote_items_path(@quote), params: {
        item: {
          name: "Design",
          quantity: 2,
          unit_price: 100,
          vat_rate: 20
        }
      }
    end

    assert_redirected_to quote_path(@quote)
  end

  test "should update item for draft quote" do
    item = @quote.items.create!(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)

    patch quote_item_path(@quote, item), params: {
      item: {
        name: "Development",
        quantity: 3,
        unit_price: 150,
        vat_rate: 10
      }
    }

    assert_redirected_to quote_path(@quote)
    assert_equal "Development", item.reload.name
    assert_equal 3, item.quantity
    assert_equal 15_000, item.unit_price_cents
    assert_equal 10, item.vat_rate
  end

  test "should not update item for validated quote" do
    item = @quote.items.create!(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)
    @quote.mark_as_validated!

    patch quote_item_path(@quote, item), params: {
      item: {
        name: "Development",
        quantity: 3,
        unit_price: 150,
        vat_rate: 10
      }
    }

    assert_redirected_to quote_path(@quote)
    assert_equal "Design", item.reload.name
    assert_equal 2, item.quantity
    assert_equal 10_000, item.unit_price_cents
    assert_equal 20, item.vat_rate
  end

  test "should destroy item for draft quote" do
    item = @quote.items.create!(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)

    assert_difference "Item.count", -1 do
      delete quote_item_path(@quote, item)
    end

    assert_redirected_to quote_path(@quote)
  end

  test "should not destroy item for validated quote" do
    item = @quote.items.create!(name: "Design", quantity: 2, unit_price_cents: 10_000, vat_rate: 20)
    @quote.mark_as_validated!

    assert_no_difference "Item.count" do
      delete quote_item_path(@quote, item)
    end

    assert_redirected_to quote_path(@quote)
  end
end
