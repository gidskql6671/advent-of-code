defmodule Day1 do
  def part1(input) do
    input
    |> parse_input()
    |> find_max_calorie_sum()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> find_3_max_calorie_sum()
    |> IO.inspect(label: "part2")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.reduce([[]], fn
      "", acc ->
        [[] | acc]

      ele, acc ->
        [head | tail] = acc

        calories = String.to_integer(ele)
        [[calories | head] | tail]
    end)
  end

  defp find_max_calorie_sum(calories) do
    calories
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  defp find_3_max_calorie_sum(calories) do
    calories
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end

File.read!("input.txt")
|> tap(&Day1.part1/1)
|> tap(&Day1.part2/1)
