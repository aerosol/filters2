# Filters2

## Idea

- Each filter is its own module implementing Filters.Spec behaviour.
- Validations and transformations per filter can be implemented optionally per module.
- Prefixes are automatically added if necessary.
- Filter key can be `:dynamic` and optionally validated as well,
  to support custom props.
- Extra transformations such as `page_regex` subsitution will be
  encapsulated at filter level too (already possible, not implemented)
- Operators can be selectively supported per filter
- (considering) Filter evaluation will be computed at filter level, with (maybe)
  an interface to apply a single filter on an existing Ecto.Query,
  e.g. instead of `case filters["event:goal"] do {:matches, ...} -> q = q |> ...`,
  we'll do something like `Filters.apply(filters, q)`

### MVP TODO

- wildcard/"contains" normalization
- extensive tests

## Examples

See sample filters:

[Goal](lib/event/goal.ex)
[Custom props](lib/event/props.ex)
[Country](lib/visit/country.ex)
[Page](lib/visit/page.ex)

```elixir
iex(1)> parse_expression "foo=bar"
{:error, "Cannot parse filter expression foo=bar"}

iex(2)> parse_expression "foo==bar"
{:error, "foo filter is not supported with operator =="}

iex(3)> parse_expression "visit:country==Poland"
{:error, "Country code must be 2 uppercase characters long"}

iex(4)> parse_expression "visit:country==pl"
{:ok,
 %{
   "visit:country" => %{
     key: "visit:country",
     operator: "==",
     spec_mod: Plausible.Filters.Visit.Country,
     value: "PL"
   }
 }}

iex(5)> parse_expression "visit:country==pl|EE|dE"
{:ok,
 %{
   "visit:country" => %{
     key: "visit:country",
     operator: "==",
     spec_mod: Plausible.Filters.Visit.Country,
     value: ["DE", "EE", "PL"]
   }
 }}

iex(6)> parse_expression "event:goal==Sign Up|Visit /blog/post"
{:ok,
 %{
   "event:goal" => %{
     key: "event:goal",
     operator: "==",
     spec_mod: Plausible.Filters.Event.Goal,
     value: [page: "/blog/post", goal: "Sign Up"]
   }
 }}

iex(7)> parse_expression "event:props:#{String.duplicate("a", 200)}==foo"
{:error,
 "Property event:props:{key} is invalid. Dynamic key must be a string of 1..120 characters"}

iex(8)> parse_expression "event:props:prop1==foo;event:props:prop2==escaped\\|pipe;event:props:prop3=element1|element2"
{:error, "Cannot parse filter expression event:props:prop3=element1|element2"}

iex(9)> parse_expression "event:props:prop1==foo;event:props:prop2==escaped\\|pipe;event:props:prop3!=element1|element2"
{:ok,
 %{
   "event:props:prop1" => %{
     key: "event:props:prop1",
     operator: "==",
     spec_mod: Plausible.Filters.Event.Props,
     value: "foo"
   },
   "event:props:prop2" => %{
     key: "event:props:prop2",
     operator: "==",
     spec_mod: Plausible.Filters.Event.Props,
     value: "escaped|pipe"
   },
   "event:props:prop3" => %{
     key: "event:props:prop3",
     operator: "!=",
     spec_mod: Plausible.Filters.Event.Props,
     value: ["element2", "element1"]
   }
 }}

iex(10)> parse_expression("country==pl") == parse_expression("visit:country==PL")
true
```
