defmodule Market.Discounts.Services.ApplayDiscounts do
  @moduledoc """
  Service module
  Checks all  conditions of the discount and apply the best discount for target  group
  """
  alias Market.Discounts.Discount
  alias Market.Baskets.Basket

  @doc """
  Calculate a discount price by rules and apply it on the product from the basket

  ## Examples

      iex> conditions_fn = fn(products) -> products > 2 end
      iex> calculate_discount_fn = fn(products, [target_group]) -> target_group.price / 2 end
      iex> rule = %Market.Discounts.Rule{applicable?: conditions_fn, calculate_discounted_total: calculate_discount_fn}
      iex> rule === Market.Discounts.create_rule(conditions_fn, calculate_discount_fn)
      true

  """
  @spec call(Basket.t(), [Discount.t()]) :: Basket.t()
  def call(basket, discounts) do
    Enum.reduce(discounts, basket, fn discount, bskt -> apply_discount(bskt, discount) end)
  end

  defp apply_discount(%Basket{} = basket, %Discount{} = discount) do
    discount_total =
      basket.products
      |> find_target_products_by(discount.target_group)
      |> count_groups_by(discount.target_group)
      |> calc_discount(discount)

    total_price = basket.total_price - discount_total

    %{basket | total_price: Float.round(total_price, 2)}
  end

  defp find_target_products_by(products, target_products_group) do
    Enum.filter(products, fn product -> Enum.member?(target_products_group, product) end)
  end

  defp count_groups_by(products, target_products_group) do
    products = Enum.frequencies_by(products, & &1.code)

    target_products_group
    |> Enum.frequencies_by(& &1.code)
    |> Enum.map(fn {code, count} ->
      case products[code] do
        nil -> 0
        total -> div(total, count)
      end
    end)
    |> Enum.min()
  end

  defp calc_discount(groups_count, discount) do
    groups_count
    |> find_applicable_rules(discount)
    |> Enum.map(fn rule ->
      discount_price = rule.calculate_discounted_total.(groups_count, discount.group_base_price)
      discount.group_base_price * groups_count - discount_price
    end)
    |> Enum.max(&>=/2, fn -> 0 end)
  end

  defp find_applicable_rules(groups_count, discount) do
    Enum.filter(discount.rules, fn rule -> rule.applicable?.(groups_count) end)
  end
end
