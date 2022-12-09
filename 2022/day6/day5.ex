defmodule Day6 do
  def part1(input) do
    input
    |> find_distinct_characters_position(4)
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> find_distinct_characters_position(14)
    |> IO.inspect(label: "part1")
  end

  defp find_distinct_characters_position(datastream, count) do
    datastream
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {ele, index}, acc ->
      cond do
        index > count - 1 ->
          [_ | acc] = acc ++ [ele]

          if dif_all?(acc), do: {:halt, index + 1}, else: {:cont, acc}

        index == count - 1 ->
          acc = acc ++ [ele]

          if dif_all?(acc), do: {:halt, index + 1}, else: {:cont, acc}

        true ->
          {:cont, acc ++ [ele]}
      end
    end)
  end

  defp dif_all?(list), do: Enum.uniq(list) == list
end

File.read!("input.txt")
|> tap(&Day6.part1/1)
|> tap(&Day6.part2/1)
