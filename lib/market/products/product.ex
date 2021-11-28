defmodule Market.Products.Product do
  @moduledoc """
  Product struct
  """

  @type t :: %__MODULE__{
          code: binary(),
          name: binary(),
          price: float()
        }

  defstruct [
    :code,
    :name,
    :price
  ]
end
