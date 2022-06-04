defmodule Day1 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&calc_fuel/1)
    |> Enum.sum()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&get_total_fuel(&1))
    |> Enum.sum()
    |> IO.inspect(label: "part2")
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp calc_fuel(mass) do
    mass
    |> div(3)
    |> Kernel.-(2)
    |> max(0)
  end

  defp get_total_fuel(mass, result \\ 0)
  defp get_total_fuel(mass, result) when mass <= 0, do: result

  defp get_total_fuel(mass, result) do
    fuel = calc_fuel(mass)

    get_total_fuel(fuel, result + fuel)
  end
end

File.read!("input.txt")
|> tap(&Day1.part1/1)
|> tap(&Day1.part2/1)
