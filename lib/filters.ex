defmodule Plausible.Filters do
  alias Plausible.Filters.Spec.Clauses
  alias Plausible.Filters

  def setup() do
    [
      Filters.Event.Goal,
      Filters.Event.Props,
      Filters.Visit.Page
    ]
  end

  @valid_operators_re ~r/(==|!=|~)/
  @non_escaped_pipe_regex ~r/(?<!\\)\|/

  @type filter_set() :: map()

  @spec parse_expression(String.t()) :: {:ok, filter_set()} | {:error, String.t()}
  def parse_expression(expressions) do
    expressions
    |> split_exprs()
    |> Enum.reduce_while({:ok, %{}}, fn expr, {:ok, acc} ->
      with {:ok, expr} <- init(expr),
           {:ok, {prefixed_key, [spec_mod, operator, rhs]}} <- Clauses.unwrap(expr),
           {:ok, value_or_values} <- extract_values(rhs),
           {:ok, value_or_values} <- spec_mod.transform(value_or_values),
           :ok <- spec_mod.validate(prefixed_key, value_or_values) do
        filter = %{
          spec_mod: spec_mod,
          key: prefixed_key,
          operator: operator,
          value: value_or_values
        }

        {:cont, {:ok, Map.put_new(acc, prefixed_key, filter)}}
      else
        error ->
          {:halt, error}
      end
    end)
  end

  def find(filters, by) when is_function(by, 1) do
    Enum.filter(filters, fn {_key, map} ->
      by.(map)
    end)
  end

  def find_by_key(filters, key) do
    find(filters, &(&1.key == key))
  end

  def find_by_prefix(filters, prefix) do
    find(filters, &String.starts_with?(&1.key, prefix))
  end

  defp split_exprs(exprs) do
    String.split(exprs, ";", trim: true)
  end

  defp init(expr) do
    case Regex.split(@valid_operators_re, expr, trim: true, parts: 3, include_captures: true) do
      [_, _, _] = expr ->
        {:ok, trim_all(expr)}

      _ ->
        {:error, "Cannot parse filter expression #{expr}"}
    end
  end

  defp trim_all(expr) when is_list(expr) do
    Enum.map(expr, &String.trim/1)
  end

  defp extract_values(rhs) do
    v_or_vs =
      case String.split(rhs, @non_escaped_pipe_regex) do
        [single] ->
          single |> String.trim() |> remove_escape_chars()

        [_ | _] = multi ->
          Enum.map(multi, fn v -> v |> String.trim() |> remove_escape_chars() end)
      end

    {:ok, v_or_vs}
  end

  defp remove_escape_chars(value) do
    String.replace(value, "\\|", "|")
  end
end
