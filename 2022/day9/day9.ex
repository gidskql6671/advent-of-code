defmodule Day9 do
  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> MapSet.size()
    |> IO.inspect(label: "part1")
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

  defp simulate(operations) do
    head = {0, 0}
    tail = {0, 0}
    visited = MapSet.new([{0, 0}])

    do_simulate(operations, head, tail, visited)
  end

  defp do_simulate([], _head, _tail, visited), do: visited

  defp do_simulate([operation | operations], head, tail, visited) do
    head = move_head(head, operation)

    {tail, visited} = move_tail(head, tail, visited)

    do_simulate(operations, head, tail, visited)
  end

  defp move_head({y, x}, {:up, distance}), do: {y - distance, x}
  defp move_head({y, x}, {:down, distance}), do: {y + distance, x}
  defp move_head({y, x}, {:left, distance}), do: {y, x - distance}
  defp move_head({y, x}, {:right, distance}), do: {y, x + distance}

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
