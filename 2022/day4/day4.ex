defmodule Day4 do
  def part1(input) do
    input
    |> parse_input()
    |> find_fully_contains_pair()
    |> Enum.count()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn pair ->
      pair
      |> String.split(",")
      |> Enum.map(fn range ->
        range
        |> String.split("-")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end

  defp find_fully_contains_pair(pairs) do
    Enum.filter(pairs, &fully_contains?/1)
  end

  defp fully_contains?({{l1, r1}, {l2, r2}}) do
    cond do
      l1 <= l2 and r2 <= r1 -> true
      l2 <= l1 and r1 <= r2 -> true
      true -> false
    end
  end
end

File.read!("input.txt")
|> tap(&Day4.part1/1)
