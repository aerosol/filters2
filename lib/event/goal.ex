defmodule Plausible.Filters.Event.Goal do
  use Plausible.Filters.Spec

  def prefix() do
    "event"
  end

  def name() do
    "goal"
  end

  def transform_single_value("Visit " <> page) do
    {:page, page}
  end

  def transform_single_value(goal) do
    {:goal, goal}
  end
end
