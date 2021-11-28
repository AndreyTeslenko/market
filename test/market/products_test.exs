defmodule Market.ProductsTest do
  use ExUnit.Case
  doctest Market.Products

  alias Market.Baskets
  alias Market.Baskets.Basket
  alias Market.Products
  alias Market.Products.Product

  describe "create_products/3" do
    test "with valid parameters" do
      code = Faker.UUID.v4()
      name = Faker.Food.dish()
      price = Market.Helpers.random_float()

      assert {:ok, %Product{code: code, name: name, price: price}} ==
               Products.create_product(code, name, price)
    end

    test "with invalid parameters" do
      code = Faker.UUID.v4()
      name = :rand.uniform(10_000)
      price = Faker.Person.first_name()

      assert {:error, "Invalid parameters, Expects: binary(), binary, float()"} ==
               Products.create_product(code, name, price)
    end
  end

  describe "calculate_total_price/1" do
    test "with a list of products" do
      {:ok, prod1} = Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), 1.5)
      {:ok, prod2} = Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), 2.5)
      {:ok, prod3} = Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), 3.5)
      products = [prod1, prod2, prod3]

      assert Products.calculate_total_price(products) == 7.5
    end

    test "with a basket" do
      {:ok, prod1} = Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), 2.5)
      {:ok, prod2} = Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), 3.5)
      {:ok, prod3} = Products.create_product(Faker.UUID.v4(), Faker.Food.dish(), 4.5)
      products = [prod1, prod2, prod3]

      {:ok, basket} = Baskets.create_basket(products)
      assert %Basket{total_price: 10.5} = Products.calculate_total_price(basket)
    end

    test "with invalid parameters" do
      assert {:error, "Invalid parameters, Expects: a list of Product or Basket"} ==
               Products.calculate_total_price(1)
    end
  end
end
