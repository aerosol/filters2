defmodule Plausible.Filters.Event.Props do
  use Plausible.Filters.Spec

  def prefix() do
    "event:props"
  end

  def name() do
    :dynamic
  end

  def validate_key("event:props:" <> key)
      when is_binary(key) and byte_size(key) > 1 and byte_size(key) < 120 do
    :ok
  end

  def validate_key(_key) do
    {:error,
     "Property event:props:{key} is invalid. Dynamic key must be a string of 1..120 characters"}
  end
end
