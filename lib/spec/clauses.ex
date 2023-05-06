defmodule Plausible.Filters.Spec.Clauses do
  alias Plausible.Filters

  Module.register_attribute(__MODULE__, :specs, accumulate: true)

  for spec_mod <- Filters.setup() do
    case spec_mod.name() do
      name when is_binary(name) ->
        fqn = "#{spec_mod.prefix()}:#{spec_mod.name()}"
        Module.put_attribute(__MODULE__, :specs, {fqn, spec_mod})

        def unwrap([key, operator, value_or_values])
            when (key == unquote(fqn) or key == unquote(spec_mod.name())) and
                   operator in unquote(spec_mod.operators()) do
          {:ok, {unquote(fqn), [unquote(spec_mod), operator, value_or_values]}}
        end

      :dynamic ->
        fqn = "#{spec_mod.prefix()}"
        Module.put_attribute(__MODULE__, :specs, {fqn, spec_mod})

        def unwrap([unquote(fqn) <> ":" <> _ = key, operator, value_or_values])
            when operator in unquote(spec_mod.operators()) do
          {:ok, {key, [unquote(spec_mod), operator, value_or_values]}}
        end
    end
  end

  def unwrap([unknown, operator, _]) do
    {:error, "#{unknown} filter is not supported with operator #{operator}"}
  end

  def unwrap(_) do
    {:error, "Invalid filter expression"}
  end

  def specs() do
    @specs
  end
end
