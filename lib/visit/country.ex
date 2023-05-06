defmodule Plausible.Filters.Visit.Country do
  use Plausible.Filters.Spec

  def prefix() do
    "visit"
  end

  def name() do
    "country"
  end

  def operators() do
    ["==", "!="]
    |> IO.inspect(label: :country_operators)
  end

  def validate_single_value(x) when byte_size(x) == 2 do
    :ok
  end

  def validate_single_value(_) do
    {:error, "Country code must be 2 uppercase characters long"}
  end

  def transform_single_value(x) do
    String.upcase(x)
  end
end
