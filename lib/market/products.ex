defmodule Market.Products do
  @moduledoc """
  Manage Products
  """
  import Market.Validator

  alias Market.Products.Product
  alias Market.Baskets.Basket

  @doc """
  Creates a new product

  ## Examples

      iex> Market.Products.create_product("sr1", "Green Tea", 3.11)
      {:ok, %Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}}

  """
  @spec create_product(binary(), binary(), float()) :: {:ok, Product.t()} | {:error, binary()}
  def create_product(code, name, price)
      when is_binary(code) and is_binary(name) and is_number(price) do
    {:ok, %Product{code: code, name: name, price: price}}
  end

  def create_product(_, _, _),
    do: {:error, "Invalid parameters, Expects: binary(), binary, float()"}

  @doc """
  Calculates a total price of the products

  ## Examples

      iex> products = [%Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}, %Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}]
      iex> Market.Products.calculate_total_price(products)
      6.22

  """
  @spec calculate_total_price([Product.t()] | Basket.t()) :: number() | {:error, binary()}
  def calculate_total_price(products) when is_list(products) do
    if valid?(products, Product) do
      products |> Enum.map(& &1.price) |> Enum.sum()
    else
      {:error, "Invalid parameters, Expects: a list of Product or Basket"}
    end
  end

  def calculate_total_price(%Basket{products: products} = basket) do
    total_price = calculate_total_price(products)
    %{basket | total_price: total_price}
  end

  def calculate_total_price(_),
    do: {:error, "Invalid parameters, Expects: a list of Product or Basket"}
end
