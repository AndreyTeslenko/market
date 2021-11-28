defmodule Market.BasketsTest do
  use ExUnit.Case
  doctest Market.Baskets

  alias Market.Baskets
  alias Market.Baskets.Basket
  alias Market.Products

  describe "create_basket/1" do
    test "with valid parameters" do
      {:ok, product} =
        Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), Market.Helpers.random_float())

      assert {:ok, %Basket{products: [product], total_price: product.price}} ==
               Baskets.create_basket([product])
    end

    test "with invalid parameters" do
      assert {:error, "Invalid parameters. Expects: Product or the list of Product"} ==
               Baskets.create_basket([1])
    end
  end

  describe "add_product_to_basket/2" do
    test "with valid parameters" do
      {:ok, product1} =
        Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), Market.Helpers.random_float())

      {:ok, product2} =
        Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), Market.Helpers.random_float())

      total_price = Products.calculate_total_price([product2, product1])
      {:ok, basket} = Baskets.create_basket(product1)

      assert %Basket{products: [product2, product1], total_price: total_price} ==
               Baskets.add_product_to_basket(basket, product2)
    end

    test "with invalid parameters" do
      {:ok, product} =
        Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), Market.Helpers.random_float())

      {:ok, basket} = Baskets.create_basket(product)

      assert {:error, "Invalid parameters. Expects: Product"} ==
               Baskets.add_product_to_basket(basket, "invalid")
    end
  end
end
