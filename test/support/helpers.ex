defmodule Market.Helpers do
  @moduledoc """
  Helpers module for generation test data
  """
  def random_float do
    (:rand.uniform() * 100)
    |> Float.round(2)
  end
end
