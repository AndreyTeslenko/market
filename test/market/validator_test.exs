defmodule Market.ValidatorTest do
  use ExUnit.Case
  doctest Market.Products

  alias Market.Products.Product
  alias Market.Validator

  describe "valid?/2" do
    test "with valid parameters" do
      code = Faker.UUID.v4()
      name = Faker.Food.dish()
      price = Market.Helpers.random_float()
      product = %Product{code: code, name: name, price: price}

      assert Validator.valid?(product, Product)
    end

    test "with invalid parameters" do
      assert Validator.valid?(1, Product) == false
    end
  end
end
