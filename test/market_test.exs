defmodule MarketTest do
  use ExUnit.Case
  doctest Market

  alias Market.TestRules

  describe "calculate_price_with_discount/2" do
    setup do
      {:ok, gr1} = Market.create_product("gr1", "green tea", 3.11)
      {:ok, sr1} = Market.create_product("sr1", "strawberry", 5.0)
      {:ok, cf1} = Market.create_product("cf1", "coffee", 11.23)

      {:ok, discount1} = Market.create_discount(gr1, TestRules.green_tea_rule())
      {:ok, discount2} = Market.create_discount(sr1, TestRules.strawberry_rule())
      {:ok, discount3} = Market.create_discount(cf1, TestRules.coffee_rule())

      discounts = [discount1, discount2, discount3]

      [gr1: gr1, sr1: sr1, cf1: cf1, discounts: discounts]
    end

    # Special cases with test data from the specification

    test "Basket: GR1,SR1,GR1,GR1,CF1 Total price expected: £22.45", %{
      gr1: gr1,
      sr1: sr1,
      cf1: cf1,
      discounts: discounts
    } do
      products = [gr1, sr1, gr1, gr1, cf1]
      {:ok, basket} = Market.create_basket(products)

      assert "£22.45" = Market.calculate_price_with_discount(basket, discounts)
    end

    test "Basket: GR1,GR1 Total price expected: £3.11", %{gr1: gr1, discounts: discounts} do
      products = [gr1, gr1]
      {:ok, basket} = Market.create_basket(products)

      assert "£3.11" = Market.calculate_price_with_discount(basket, discounts)
    end

    test "Basket: SR1,SR1,GR1,SR1 Total price expected: £16.61", %{
      gr1: gr1,
      sr1: sr1,
      discounts: discounts
    } do
      products = [sr1, sr1, gr1, sr1]
      {:ok, basket} = Market.create_basket(products)

      assert "£16.61" = Market.calculate_price_with_discount(basket, discounts)
    end

    test "Basket: GR1,CF1,SR1,CF1,CF1 Total price expected: £30.57", %{
      gr1: gr1,
      sr1: sr1,
      cf1: cf1,
      discounts: discounts
    } do
      products = [gr1, cf1, sr1, cf1, cf1]
      {:ok, basket} = Market.create_basket(products)

      assert "£30.57" = Market.calculate_price_with_discount(basket, discounts)
    end
  end
end
