defmodule Filters2Test do
  use ExUnit.Case

  alias Plausible.Filters.Event.Goal
  alias Plausible.Filters

  test "greets the world" do
    {:ok, filters} =
      Filters.parse_expression("event:props:fooobar==1;event:goal==Visit /foo|bar")
      |> IO.inspect(label: :parsed)

    Filters.find_by_prefix(filters, "event")
    |> IO.inspect(label: :clauses)
  end
end
