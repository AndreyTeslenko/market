defmodule Market.Discounts do
  @moduledoc """
  Manage Discounts
  """
  import Market.Validator

  alias Market.Products
  alias Market.Products.Product
  alias Market.Discounts.{Discount, Rule}
  alias Market.Discounts.Services.ApplayDiscounts
  alias Market.Baskets.Basket

  @doc """
  Creates a new discount of a product

  ## Examples

      iex> target_group = [%Market.Products.Product{code: "sr1", name: "Green Tea", price: 4}]
      iex> rules = [%Market.Discounts.Rule{}]
      iex> discount = %Market.Discounts.Discount{target_group: target_group, rules: rules, group_base_price: 4}
      iex> {:ok, discount} === Market.Discounts.create_discount(target_group, rules)
      true

  """
  @spec create_discount([Product.t()], Rule.t() | [Rule.t()]) ::
          {:ok, Market.Discounts.Discount.t()} | {:error, binary()}
  def create_discount(products_group, rules) do
    products_group = List.flatten([products_group | []])
    rules = List.flatten([rules | []])

    if valid?(products_group, Product) && valid?(rules, Rule) do
      group_base_price = Products.calculate_total_price(products_group)

      {:ok,
       %Discount{target_group: products_group, rules: rules, group_base_price: group_base_price}}
    else
      {:error, "Invalid parameters. Expects: a list of Product and a list of Rule"}
    end
  end

  @doc """
  Creates a new rule of a discount.
  # Parameters
    `conditions function` - the function specifies conditions that discount can be applied on the products of the basket
    `calculate discount total` - calculates discount

  ## Examples

      iex> conditions_fn = fn(total) -> total > 2 end
      iex> calculate_discount_fn = fn(products , [target_product]) -> target_product.price / 2 * Enum.count(products) end
      iex> rule = %Market.Discounts.Rule{applicable?: conditions_fn, calculate_discounted_total: calculate_discount_fn}
      iex> {:ok, rule} === Market.Discounts.create_rule(conditions_fn, calculate_discount_fn)
      true

  """
  @spec create_rule(Rule.conditions_fn(), Rule.calculate_discount_fn()) ::
          {:ok, Rule.t()} | {:error, binary()}
  def create_rule(condition_fn, calculate_discount_fn)
      when is_function(condition_fn, 1) and is_function(calculate_discount_fn, 2) do
    {:ok, %Rule{applicable?: condition_fn, calculate_discounted_total: calculate_discount_fn}}
  end

  def create_rule(_, _), do: {:error, "Invalid parameters. Expects: function/1, function/2"}

  @doc """
  Calculates discount and applies it on the products of the basket

  ## Examples

      iex> products = [%Market.Products.Product{code: "gt1", name: "Green Tea", price: 3.11}, %Market.Products.Product{code: "gt1", name: "Green Tea", price: 3.11}]
      iex> product = %Market.Products.Product{code: "gt1", name: "Green Tea", price: 3.11}
      iex> {:ok, basket} = Market.Baskets.create_basket(products)
      iex> rules = [Market.TestRules.green_tea_rule()]
      iex> discount = %Market.Discounts.Discount{target_group: [product], rules: rules, group_base_price: 3.11}
      iex> {:ok, %Market.Baskets.Basket{total_price: total_price}} = Market.Discounts.apply_discounts(basket, [discount])
      ...> total_price
      3.11

  """
  @spec apply_discounts(Basket.t(), [Discount.t()]) :: {:ok, Basket.t()} | {:error, binary()}
  def apply_discounts(%Basket{} = basket, []), do: basket

  def apply_discounts(%Basket{} = basket, discounts) when is_list(discounts) do
    case validate_discounts(discounts) do
      {:error, :conflict_discounts} -> {:error, "The list of discounts contains conflicts"}
      discounts -> {:ok, ApplayDiscounts.call(basket, discounts)}
    end
  end

  def apply_discounts(_, _),
    do: {:error, "Invalid parameters, Expects: Basket and a list of Discount"}

  defp validate_discounts(discounts) do
    is_valid_discounts =
      discounts
      |> Enum.map(fn discount -> Enum.frequencies_by(discount.target_group, & &1.code) end)
      |> Enum.map(&Map.keys/1)
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.all?(fn {_code, total} -> total == 1 end)

    if is_valid_discounts do
      discounts
    else
      {:error, :conflict_discounts}
    end
  end
end
