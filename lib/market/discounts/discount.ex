defmodule Market.Discounts.Discount do
  @moduledoc """
  Discount struct

  Contains target group, rules and group base total price .
  Target group is a list of product which can be apply a discount only if in the basket contains full set.

  Rules is a list of Rule struct

  Group base price is total price of the products on the target group
  """

  alias Market.Products.Product
  alias Market.Discounts.Rule

  @type t :: %__MODULE__{
          target_group: [Product.t()],
          rules: [Rule.t()],
          group_base_price: number()
        }

  defstruct [
    :target_group,
    :rules,
    :group_base_price
  ]
end
