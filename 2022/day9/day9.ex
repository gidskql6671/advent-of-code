defmodule Day9 do
  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> hd()
    |> MapSet.size()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> simulate(10)
    |> Enum.take(-1)
    |> hd()
    |> MapSet.size()
    |> IO.inspect(label: "part2")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [oper, distance] = String.split(line, " ")

      oper =
        case oper do
          "U" -> :up
          "D" -> :down
          "L" -> :left
          "R" -> :right
        end

      {oper, String.to_integer(distance)}
    end)
  end

  defp simulate(operations, knot_count \\ 2) do
    [head | tails] = Enum.map(1..knot_count, fn _ -> {0, 0} end)
    visited_list = Enum.map(2..knot_count, fn _ -> MapSet.new([{0, 0}]) end)

    do_simulate(operations, head, tails, visited_list)
  end

  defp do_simulate([], _head, _tails, visited_list), do: visited_list

  defp do_simulate([{dir, distance} | operations], head, tails, visited_list) do
    {head, tails, visited_list} =
      1..distance
      |> Enum.reduce({head, tails, visited_list}, fn _, {head, tails, visited_list} ->
        head = move_head(head, {dir, 1})

        {tails, visited_list} = move_tails(head, tails, visited_list)

        {head, tails, visited_list}
      end)

    do_simulate(operations, head, tails, visited_list)
  end

  defp move_head({y, x}, {:up, distance}), do: {y - distance, x}
  defp move_head({y, x}, {:down, distance}), do: {y + distance, x}
  defp move_head({y, x}, {:left, distance}), do: {y, x - distance}
  defp move_head({y, x}, {:right, distance}), do: {y, x + distance}

  defp move_tails(head, tails, visited_list) do
    Enum.zip(tails, visited_list)
    |> Enum.reduce([{head, MapSet.new()}], fn {tail, visited}, acc ->
      [{prev_knot, _prev_visited} | _] = acc

      {tail, visited} = move_tail(prev_knot, tail, visited)

      [{tail, visited} | acc]
    end)
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.unzip()
  end

  defp move_tail(head, tail, visited) do
    if adjacent?(head, tail) do
      {tail, visited}
    else
      next_tail = next_tail(head, tail)

      move_tail(head, next_tail, MapSet.put(visited, next_tail))
    end
  end

  defp adjacent?({head_y, head_x}, {tail_y, tail_x}),
    do: abs(head_y - tail_y) <= 1 and abs(head_x - tail_x) <= 1

  defp next_tail({head_y, tail_x}, {tail_y, tail_x}) do
    next_tail_y = if tail_y > head_y, do: tail_y - 1, else: tail_y + 1

    {next_tail_y, tail_x}
  end

  defp next_tail({tail_y, head_x}, {tail_y, tail_x}) do
    next_tail_x = if tail_x > head_x, do: tail_x - 1, else: tail_x + 1

    {tail_y, next_tail_x}
  end

  defp next_tail({head_y, head_x}, {tail_y, tail_x}) do
    next_tail_y = if tail_y > head_y, do: tail_y - 1, else: tail_y + 1
    next_tail_x = if tail_x > head_x, do: tail_x - 1, else: tail_x + 1

    {next_tail_y, next_tail_x}
  end
end

File.read!("input.txt")
|> tap(&Day9.part1/1)
|> tap(&Day9.part2/1)
