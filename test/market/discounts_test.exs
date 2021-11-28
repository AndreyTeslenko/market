defmodule Market.DiscountsTest do
  use ExUnit.Case
  doctest Market.Discounts

  alias Market.TestRules
  alias Market.Discounts
  alias Market.Products
  alias Market.Discounts.{Discount, Rule}
  alias Market.Baskets.Basket
  alias Market.Baskets
  alias Market.Products.Product

  describe "create_discount/2" do
    test "with valid params" do
      product = %Product{
        code: Faker.UUID.v4(),
        name: Faker.Food.dish(),
        price: Market.Helpers.random_float()
      }

      assert {:ok, %Discount{target_group: [target_product], rules: [rule]}} =
               Discounts.create_discount(product, TestRules.small_discount_rule())

      assert target_product == product
      assert rule == TestRules.small_discount_rule()
    end

    test "with invalid parameters" do
      assert {:error, "Invalid parameters. Expects: a list of Product and a list of Rule"} ==
               Discounts.create_discount(1, "hello")
    end
  end

  describe "create_rule/2" do
    test "with valid parameters" do
      condition_function = fn total_target_products -> total_target_products == 3 end

      calculate_discount_function = fn target_product, total_target_products ->
        target_product.price / total_target_products
      end

      assert {:ok,
              %Rule{applicable?: condition_fn, calculate_discounted_total: calculate_discount_fn}} =
               Discounts.create_rule(condition_function, calculate_discount_function)

      assert condition_fn == condition_function
      assert calculate_discount_fn == calculate_discount_function
    end

    test "with invalid parameters" do
      assert {:error, "Invalid parameters. Expects: function/1, function/2"} ==
               Discounts.create_rule(1, "hello")
    end
  end

  describe "apply_discounts/2" do
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
      assert {:ok, %Basket{total_price: 22.45}} = Discounts.apply_discounts(basket, [discount])
    end

    test "when discounts are empty list", %{gt1: gt1, sr1: sr1, cf1: cf1} do
      products = [sr1, sr1, gt1, sr1, gt1, cf1]
      {:ok, basket} = Baskets.create_basket(products)

      assert basket == Discounts.apply_discounts(basket, [])
    end

    test "when a basket is invalid type" do
      assert {:error, "Invalid parameters, Expects: Basket and a list of Discount"} ==
               Discounts.apply_discounts(nil, [])
    end

    test "when contains conflict discounts", %{gt1: gt1, sr1: sr1, cf1: cf1} do
      products = [gt1, sr1, gt1, gt1, cf1]
      {:ok, basket} = Baskets.create_basket(products)

      {:ok, discount1} = Discounts.create_discount(gt1, TestRules.green_tea_rule())
      {:ok, discount2} = Discounts.create_discount([gt1, sr1], TestRules.big_discount_rule())

      discounts = [discount1, discount2]

      assert {:error, "The list of discounts contains conflicts"} ==
               Discounts.apply_discounts(basket, discounts)
    end
  end
end
