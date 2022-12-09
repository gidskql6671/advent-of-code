defmodule Day6 do
  def part1(input) do
    input
    |> find_first_start_of_packet_position()
    |> IO.inspect(label: "part1")
  end

  defp find_first_start_of_packet_position(datastream) do
    datastream
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {ele, index}, acc ->
      cond do
        index > 3 ->
          [_ | acc] = acc ++ [ele]

          if dif_all?(acc), do: {:halt, index + 1}, else: {:cont, acc}

        index == 3 ->
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
