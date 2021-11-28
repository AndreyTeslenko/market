defmodule Market do
  @moduledoc """
  Market module
  """

  alias Market.Baskets.Basket
  alias Market.Discounts.Discount
  alias Market.Discounts

  defdelegate create_product(code, name, price), to: Market.Products
  defdelegate create_discount(target_group, rules), to: Market.Discounts
  defdelegate create_rule(condition_fn, calculate_discount_fn), to: Market.Discounts
  defdelegate create_basket(products), to: Market.Baskets
  defdelegate add_product_to_basket(products, product), to: Market.Baskets

  @doc """
  Calculates total price with discount

  ## Examples

      iex> products = [%Market.Products.Product{code: "gt1", name: "Green Tea", price: 3.11}, %Market.Products.Product{code: "gt1", name: "Green Tea", price: 3.11}]
      iex> product = %Market.Products.Product{code: "gt1", name: "Green Tea", price: 3.11}
      iex> {:ok, basket} = Market.Baskets.create_basket(products)
      iex> rules = [Market.TestRules.green_tea_rule()]
      iex> discount = %Market.Discounts.Discount{target_group: [product], rules: rules, group_base_price: 3.11}
      iex> Market.calculate_price_with_discount(basket, [discount])
      "£3.11"

  """
  @spec calculate_price_with_discount(Basket.t(), [Discount.t()]) :: binary()
  def calculate_price_with_discount(basket, discounts) do
    {:ok, %Basket{total_price: total_price}} = Discounts.apply_discounts(basket, discounts)
    "£#{total_price}"
  end
end
