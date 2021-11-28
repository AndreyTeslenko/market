defmodule Market.Baskets.Basket do
  @moduledoc """
  Basket struct

  Contains list of products and total price without discount
  """

  @type t :: %__MODULE__{
          products: list(),
          total_price: integer()
        }

  defstruct [
    :products,
    total_price: 0
  ]
end
