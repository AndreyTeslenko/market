defmodule Market.Discounts.Rule do
  @moduledoc """
  Discount rule struct

  Contains a discount condition function and a calculate discount function.
  If the condition is done then the discount can be calculated by calculate discount function.
  """

  alias Market.Products.Product

  @type discounted_total() :: number()
  @type conditions_fun() :: (integer() -> boolean())
  @type target_group() :: [Product.t()]
  @type calculate_discount_fn() :: (integer(), target_group() -> discounted_total())

  @type t :: %__MODULE__{
          applicable?: conditions_fun(),
          calculate_discounted_total: calculate_discount_fn()
        }

  defstruct [
    :applicable?,
    :calculate_discounted_total
  ]
end
