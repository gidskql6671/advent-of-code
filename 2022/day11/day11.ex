defmodule Day11.Memory do
  def run(name) do
    ets_name = get_ets_name(name)

    :ets.new(ets_name, [:set, :public, :named_table])
  end

  def get(name, key) do
    ets_name = get_ets_name(name)

    :ets.lookup(ets_name, key) |> Keyword.get(key)
  end

  def set(name, keywords) do
    ets_name = get_ets_name(name)

    :ets.insert(ets_name, keywords)
  end

  defp get_ets_name(name), do: String.to_atom("ets-#{name}")
end

defmodule Day11 do
  alias Day11.Memory

  @monkey_number_regex ~r/Monkey (\d+):/
  @start_items_regex ~r/Starting items: (.*)/
  @operation_regex ~r/Operation: new = old (.*)/
  @test_regex ~r/Test: divisible by (\d+)/
  @if_true_regex ~r/If true: throw to monkey (\d+)/
  @if_false_regex ~r/If false: throw to monkey (\d+)/

  def part1(input) do
    input
    |> parse_input()
    |> simulate(20)
    |> find_most_active_monkeys(2)
    |> Enum.product()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(6)
    |> Enum.into(%{}, fn monkey_info ->
      [monkey, start_items, oper, test, if_true, if_false] = monkey_info

      start_items =
        extract_regex_result(@start_items_regex, start_items)
        |> String.split(", ", trim: true)
        |> Enum.map(&String.to_integer/1)

      monkey_number = extract_regex_result(@monkey_number_regex, monkey) |> String.to_integer()
      [operation, operand] = extract_regex_result(@operation_regex, oper) |> String.split(" ")
      test = extract_regex_result(@test_regex, test) |> String.to_integer()
      if_true = extract_regex_result(@if_true_regex, if_true) |> String.to_integer()
      if_false = extract_regex_result(@if_false_regex, if_false) |> String.to_integer()

      {monkey_number,
       %{
         items: start_items,
         operation: operation,
         operand: if(operand == "old", do: "old", else: String.to_integer(operand)),
         test: test,
         if_true: if_true,
         if_false: if_false
       }}
    end)
  end

  defp extract_regex_result(regex, string) do
    Regex.run(regex, string) |> Enum.at(1)
  end

  defp simulate(info, total_round) do
    monkey_total_count = Enum.count(info)
    info = Enum.into(info, %{}, fn {k, v} -> {k, Map.put(v, :inspect_count, 0)} end)

    Enum.each(0..(monkey_total_count - 1), fn index ->
      Memory.run(index)

      Memory.set(index, info |> Map.get(index) |> Enum.map(& &1))
    end)

    Enum.each(1..total_round, fn _ -> do_simulate(monkey_total_count) end)

    monkey_total_count
  end

  defp do_simulate(monkey_total_count) do
    0..(monkey_total_count - 1)
    |> Enum.each(fn monkey_number ->
      %{
        items: items,
        test: test,
        if_true: if_true,
        if_false: if_false,
        operation: operation,
        operand: operand,
        inspect_count: inspect_count
      } = get_data_from_memory(monkey_number)

      items
      |> Enum.map(&inspect_item(&1, {operation, operand}))
      |> Enum.map(&test_item(&1, test))
      |> Enum.each(fn
        {item, true} -> throw_item(item, if_true)
        {item, false} -> throw_item(item, if_false)
      end)

      Memory.set(monkey_number,
        items: [],
        inspect_count: inspect_count + length(items)
      )
    end)
  end

  defp get_data_from_memory(monkey_number) do
    %{
      items: Memory.get(monkey_number, :items),
      test: Memory.get(monkey_number, :test),
      if_true: Memory.get(monkey_number, :if_true),
      if_false: Memory.get(monkey_number, :if_false),
      operation: Memory.get(monkey_number, :operation),
      operand: Memory.get(monkey_number, :operand),
      inspect_count: Memory.get(monkey_number, :inspect_count)
    }
  end

  defp inspect_item(item, {operation, operand}) do
    operand = if operand == "old", do: item, else: operand

    case operation do
      "+" -> item + operand
      "*" -> item * operand
    end
    |> div(3)
  end

  defp test_item(item, test), do: {item, rem(item, test) == 0}

  defp throw_item(item, to) do
    to_monkey_items = Memory.get(to, :items)

    Memory.set(to, items: to_monkey_items ++ [item])
  end

  defp find_most_active_monkeys(monkey_total_count, find_monkey_count) do
    0..(monkey_total_count - 1)
    |> Enum.map(&Memory.get(&1, :inspect_count))
    |> Enum.sort(:desc)
    |> Enum.take(find_monkey_count)
  end
end

File.read!("input.txt")
|> tap(&Day11.part1/1)
