defmodule Plausible.Filters.Spec do
  alias Plausible.Filters
  require Filters

  @type operator() :: String.t()

  @callback name() :: String.t() | :dynamic
  @callback prefix() :: String.t()
  @callback allow_wildcards?() :: boolean()
  @callback operators() :: list(operator)

  @callback validate_key(String.t()) :: :ok | {:error, any()}
  @callback validate_single_value(String.t()) :: :ok | {:error, any()}
  @callback transform_single_value(String.t()) :: term()

  defmacro __using__(_opts) do
    quote do
      @behaviour Filters.Spec
      import Filters.Spec

      def operators() do
        ["==", "!=", "~"]
      end

      def allow_wildcards?() do
        true
      end

      def validate_single_value(_), do: :ok
      def validate_key(_), do: :ok
      def transform_single_value(x), do: x

      def validate(key, value_or_values) do
        with :ok <- validate_key(key),
             :ok <- validate_every(value_or_values) do
          :ok
        end
      end

      def transform(value_or_values) do
        {:ok, transform_every(value_or_values)}
      end

      defp validate_every(v_or_vs) do
        reduce_val(v_or_vs, :ok, fn v, acc ->
          with :ok <- apply(__MODULE__, :validate_single_value, [v]) do
            {:cont, acc}
          else
            error ->
              {:halt, error}
          end
        end)
      end

      defp transform_every(v_or_vs) do
        v_or_vs
        |> reduce_val([], fn v, acc ->
          with new_value <- apply(__MODULE__, :transform_single_value, [v]) do
            {:cont, [new_value | acc]}
          end
        end)
      end

      defmacro for_values(v_or_vs, do: block) do
        quote do
          v_or_vs
          |> List.wrap()
          |> unquote(block)
          |> case do
            [single_value] ->
              single_value

            [_ | _] = list ->
              list

            single_value ->
              single_value
          end
        end
      end

      def map_val(v_or_vs, fun)
          when is_function(fun, 1) do
        for_values(v_or_ws) do
          Enum.map(fun)
        end
      end

      def reduce_val(v_or_vs, initial_acc, fun)
          when is_function(fun, 2) do
        for_values(v_or_ws) do
          Enum.reduce_while(initial_acc, fun)
        end
      end

      defoverridable operators: 0
      defoverridable allow_wildcards?: 0
      defoverridable validate_single_value: 1
      defoverridable transform_single_value: 1
      defoverridable validate_key: 1
    end
  end
end
