defmodule Market.Validator do
  @moduledoc """
  Type validator
  """

  @doc """
  Validate type of variable

  ## Examples

      iex> product = %Market.Products.Product{code: "sr1", name: "Green Tea", price: 3.11}
      iex> Market.Validator.valid?(product, %Market.Products.Product{})
      true

      iex> Market.Validator.valid?(%{}, %Market.Products.Product{})
      false

  """
  @spec valid?(list(), any) :: boolean()
  def valid?(parameters, expected_type) when is_list(parameters) do
    Enum.all?(parameters, fn val -> valid?(val, expected_type) end)
  end

  def valid?(parameter, expected_type) do
    case parameter do
      %expected_type{} -> true
      _ -> false
    end
  end
end
