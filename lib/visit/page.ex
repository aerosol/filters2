defmodule Plausible.Filters.Visit.Page do
  use Plausible.Filters.Spec

  def prefix() do
    "visit"
  end

  def name() do
    "page"
  end

  def operators() do
    ["==", "!="]
  end
end
