defmodule Day5 do
  def part1(input) do
    input
    |> parse_input()
    |> do_procedure(1)
    |> print_top_crates()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> do_procedure(2)
    |> print_top_crates()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    {started_stacks, procedure} =
      input
      |> String.split("\n")
      |> Enum.split_while(& &1 != "")

    {
      parse_started_stacks(started_stacks),
      parse_procedure(Enum.drop(procedure, 1))
    }
  end

  defp parse_started_stacks(started_stacks) do
    started_stacks
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.reduce(%{}, fn line, result ->
      line
      |> String.graphemes()
      |> Enum.chunk_every(4)
      |> Enum.with_index(1)
      |> Enum.reduce(result, fn
        {["[", crate | _], index}, acc ->
          Map.update(acc, index, [crate], & [crate | &1])

        _, acc ->
          acc
      end)
    end)
  end

  defp parse_procedure(procedure) do
    regex = ~r/^move (?<count>[[:digit:]]+) from (?<from>[[:digit:]]+) to (?<to>[[:digit:]]+)$/

    procedure
    |> Enum.map(fn line ->
      %{"count" => count, "from" => from, "to" => to} = Regex.named_captures(regex, line)

      %{
        count: String.to_integer(count),
        from: String.to_integer(from),
        to: String.to_integer(to),
      }
    end)
  end

  defp do_procedure({stacks, []}, _part), do: stacks

  defp do_procedure({stacks, procedure}, part) do
    [%{count: count, from: from, to: to} | procedure] = procedure

    stacks =
      if part == 1,
        do: move_crates_one_at_a_time(stacks, from, to, count),
        else: move_crates_multiple_at_a_time(stacks, from, to, count)

    do_procedure({stacks, procedure}, part)
  end

  defp move_crates_one_at_a_time(stacks, from, to, count) do
    1..count
    |> Enum.reduce(stacks, fn _, acc ->
      [from_top | from_tail] = Map.get(acc, from)

      acc
      |> Map.update!(to, &[from_top | &1])
      |> Map.put(from, from_tail)
    end)
  end

  defp move_crates_multiple_at_a_time(stacks, from, to, count) do
    from_list = Map.get(stacks, from)
    to_list = Map.get(stacks, to)

    moved_crates = Enum.take(from_list, count)

    stacks
    |> Map.put(from, Enum.drop(from_list, count))
    |> Map.put(to, moved_crates ++ to_list)
  end

  defp print_top_crates(stacks) do
    stacks
    |> Enum.map(fn {_index, [top | _tail]} -> top end)
    |> Enum.join()
  end
end

File.read!("input.txt")
|> tap(&Day5.part1/1)
|> tap(&Day5.part2/1)
