defmodule Market.Baskets do
  @moduledoc """
  Manage Baskets
  """
  import Market.Validator

  alias Market.Baskets.Basket
  alias Market.Products.Product
  alias Market.Products

  @doc """
  Creates a new basket

  ## Examples

      iex> products = [%Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}]
      iex> Market.Baskets.create_basket(products)
      {:ok, %Market.Baskets.Basket{products: [%Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}], total_price: 3.11}}

      iex> product = %Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}
      iex> Market.Baskets.create_basket(product)
      {:ok, %Market.Baskets.Basket{products: [%Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}], total_price: 3.11}}
  """
  @spec create_basket([Product.t()] | Product.t()) :: {:ok, Basket.t()} | {:error, binary()}
  def create_basket(products) do
    products = List.flatten([products | []])

    if valid?(products, Product) do
      total_price = Products.calculate_total_price(products)
      {:ok, %Basket{products: products, total_price: total_price}}
    else
      {:error, "Invalid parameters. Expects: Product or the list of Product"}
    end
  end

  @doc """
  Adds a new product to the basket

  ## Examples

      iex> basket = %Market.Baskets.Basket{products: [%Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}]}
      iex> product = %Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}
      iex> Market.Baskets.add_product_to_basket(basket, product)
      %Market.Baskets.Basket{products: [%Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}, %Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}], total_price: 6.22}
  """
  @spec add_product_to_basket(Basket.t(), Product.t()) :: Basket.t() | {:error, binary()}
  def add_product_to_basket(%Basket{products: products}, %Product{} = product) do
    case create_basket([product | products]) do
      {:ok, basket} -> basket
      error -> error
    end
  end

  def add_product_to_basket(_, _), do: {:error, "Invalid parameters. Expects: Product"}
end
