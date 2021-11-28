defmodule Market.TestRules do
  @moduledoc """
  Predefined test rules.
  """

  alias Market.Discounts

  @spec green_tea_rule :: Market.Discounts.Rule.t()
  def green_tea_rule do
    condition_fn = fn groups_count -> groups_count > 1 end

    calculate_discount_fn = fn groups_count, group_base_price ->
      (groups_count - div(groups_count, 2)) * group_base_price
    end

    {:ok, rule} = Discounts.create_rule(condition_fn, calculate_discount_fn)
    rule
  end

  @spec strawberry_rule :: Market.Discounts.Rule.t()
  def strawberry_rule do
    condition_fn = fn groups_count -> groups_count > 2 end

    calculate_discount_fn = fn groups_count, _target_product ->
      groups_count * 4.5
    end

    {:ok, rule} = Discounts.create_rule(condition_fn, calculate_discount_fn)
    rule
  end

  @spec coffee_rule :: Market.Discounts.Rule.t()
  def coffee_rule do
    condition_fn = fn groups_count -> groups_count > 2 end

    calculate_discount_fn = fn groups_count, group_base_price ->
      groups_count * group_base_price / 3 * 2
    end

    {:ok, rule} = Discounts.create_rule(condition_fn, calculate_discount_fn)
    rule
  end

  @spec small_discount_rule :: Market.Discounts.Rule.t()
  def small_discount_rule do
    condition_fn = fn groups_count -> groups_count > 2 end

    calculate_discount_fn = fn groups_count, group_base_price ->
      groups_count * group_base_price / 2
    end

    {:ok, rule} = Discounts.create_rule(condition_fn, calculate_discount_fn)
    rule
  end

  @spec big_discount_rule :: Market.Discounts.Rule.t()
  def big_discount_rule do
    condition_fn = fn groups_count -> groups_count > 4 end

    calculate_discount_fn = fn groups_count, group_base_price ->
      groups_count * group_base_price / 4
    end

    {:ok, rule} = Discounts.create_rule(condition_fn, calculate_discount_fn)
    rule
  end

  @spec group_discount_rule :: Market.Discounts.Rule.t()
  def group_discount_rule do
    condition_fn = fn groups_count -> groups_count > 1 end

    calculate_discount_fn = fn groups_count, group_base_price ->
      groups_count * group_base_price / 4
    end

    {:ok, rule} = Discounts.create_rule(condition_fn, calculate_discount_fn)
    rule
  end
end
