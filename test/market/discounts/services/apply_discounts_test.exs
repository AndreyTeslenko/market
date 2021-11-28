defmodule Market.Discounts.Services.ApplayDiscountsTest do
  use ExUnit.Case
  doctest Market.Discounts

  alias Market.TestRules
  alias Market.Discounts
  alias Market.Products
  alias Market.Baskets.Basket
  alias Market.Baskets
  alias Market.Discounts.Services.ApplayDiscounts

  describe "call/2" do
    setup do
      {:ok, gt1} = Products.create_product("gt1", "green tea", 3.11)
      {:ok, sr1} = Products.create_product("sr1", "strawberry", 5.0)
      {:ok, cf1} = Products.create_product("cf1", "coffee", 11.23)

      [gt1: gt1, sr1: sr1, cf1: cf1]
    end

    test "when you buy one and get one for free", %{gt1: gt1, sr1: sr1, cf1: cf1} do
      products = [gt1, sr1, gt1, gt1, cf1]
      {:ok, basket} = Baskets.create_basket(products)

      {:ok, discount} = Discounts.create_discount(gt1, TestRules.green_tea_rule())
      assert %Basket{total_price: 22.45} = ApplayDiscounts.call(basket, [discount])
    end

    test "when buying more than three at a reduced price", %{gt1: gt1, sr1: sr1} do
      products = [sr1, sr1, gt1, sr1]
      {:ok, basket} = Baskets.create_basket(products)

      {:ok, discount} = Discounts.create_discount(sr1, TestRules.strawberry_rule())
      assert %Basket{total_price: 16.61} = ApplayDiscounts.call(basket, [discount])
    end

    test "when buying more than three units, the price of the product is reduced by one third", %{
      gt1: gt1,
      sr1: sr1,
      cf1: cf1
    } do
      products = [gt1, cf1, sr1, cf1, cf1]
      {:ok, basket} = Baskets.create_basket(products)
      {:ok, discount} = Discounts.create_discount(cf1, TestRules.coffee_rule())

      assert %Basket{total_price: 30.57} = ApplayDiscounts.call(basket, [discount])
    end

    test "when applies two discounts", %{gt1: gt1, sr1: sr1, cf1: cf1} do
      products = [sr1, sr1, gt1, sr1, gt1, cf1]
      {:ok, basket} = Baskets.create_basket(products)

      {:ok, discount1} = Discounts.create_discount(sr1, TestRules.strawberry_rule())
      {:ok, discount2} = Discounts.create_discount(gt1, TestRules.green_tea_rule())

      assert %Basket{total_price: 27.84} = ApplayDiscounts.call(basket, [discount1, discount2])
    end

    test "when the discount has two rules", %{gt1: gt1, sr1: sr1} do
      products = [sr1, sr1, sr1, gt1]
      {:ok, basket} = Baskets.create_basket(products)

      rules = [
        TestRules.small_discount_rule(),
        TestRules.big_discount_rule()
      ]

      {:ok, discount} = Discounts.create_discount(sr1, rules)

      assert %Basket{total_price: 10.61} = ApplayDiscounts.call(basket, [discount])

      basket =
        basket
        |> Baskets.add_product_to_basket(sr1)
        |> Baskets.add_product_to_basket(sr1)
        |> Products.calculate_total_price()

      assert %Basket{total_price: 9.36} = ApplayDiscounts.call(basket, [discount])
    end

    test "when applies the discount on group of products", %{gt1: gt1, sr1: sr1, cf1: cf1} do
      products = [sr1, sr1, cf1, gt1, gt1, cf1, gt1, sr1, sr1, sr1]
      {:ok, basket} = Baskets.create_basket(products)
      target_group = [sr1, sr1, cf1]
      {:ok, discount} = Discounts.create_discount(target_group, TestRules.group_discount_rule())

      assert %Basket{total_price: 24.95} = ApplayDiscounts.call(basket, [discount])
    end

    test "when applies two discounts on group of products and single product", %{
      gt1: gt1,
      sr1: sr1,
      cf1: cf1
    } do
      products = [sr1, sr1, cf1, gt1, gt1, cf1, gt1, sr1, sr1, sr1]
      {:ok, basket} = Baskets.create_basket(products)
      target_group = [sr1, sr1, cf1]

      {:ok, discount1} = Discounts.create_discount(target_group, TestRules.group_discount_rule())
      {:ok, discount2} = Discounts.create_discount(gt1, TestRules.green_tea_rule())

      discounts = [discount1, discount2]

      assert %Basket{total_price: 21.84} = ApplayDiscounts.call(basket, discounts)
    end
  end
end
