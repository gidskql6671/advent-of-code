defmodule Day10 do
  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> get_signal_strengths([20, 60, 100, 140, 180, 220])
    |> Enum.sum()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      case String.split(line, " ") do
        [oper] -> String.to_existing_atom(oper)
        [oper, value] -> {String.to_existing_atom(oper), String.to_integer(value)}
      end
    end)
  end

  defp simulate(operations) do
    operations
    |> Enum.reduce({1, 1, %{}}, fn operation, acc ->
      operate(operation, acc)
    end)
    |> elem(2)
  end

  defp operate(:noop, {register, cycle, value_when_cycle}) do
    {
      register,
      cycle + 1,
      Map.put(value_when_cycle, cycle, register)
    }
  end

  defp operate({:addx, value}, {register, cycle, value_when_cycle}) do
    {
      register + value,
      cycle + 2,
      value_when_cycle |> Map.put(cycle, register) |> Map.put(cycle + 1, register)
    }
  end

  defp get_signal_strengths(value_when_cycle, cycles),
    do: Enum.map(cycles, &(Map.get(value_when_cycle, &1) * &1))
end

File.read!("input.txt")
|> tap(&Day10.part1/1)
