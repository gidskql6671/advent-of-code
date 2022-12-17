defmodule Day10 do
  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> Map.get(:value_when_cycle)
    |> get_signal_strengths([20, 60, 100, 140, 180, 220])
    |> Enum.sum()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> simulate()
    |> Map.get(:crt)
    |> print_crt()
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
    crt = Enum.into(0..5, %{}, fn row -> {row, Enum.into(0..39, %{}, &{&1, "."})} end)

    {register, cycle, value_when_cycle, crt} =
      Enum.reduce(operations, {1, 1, %{}, crt}, fn operation, acc ->
        operate(operation, acc)
      end)

    %{register: register, cycle: cycle, value_when_cycle: value_when_cycle, crt: crt}
  end

  defp operate(:noop, {register, cycle, value_when_cycle, crt}) do
    {
      register,
      cycle + 1,
      Map.put(value_when_cycle, cycle, register),
      draw_crt(crt, register, cycle)
    }
  end

  defp operate({:addx, value}, {register, cycle, value_when_cycle, crt}) do
    {
      register + value,
      cycle + 2,
      value_when_cycle |> Map.put(cycle, register) |> Map.put(cycle + 1, register),
      crt |> draw_crt(register, cycle) |> draw_crt(register, cycle + 1)
    }
  end

  defp draw_crt(crt, register, cycle) do
    row = div(cycle - 1, 40)
    col = rem(cycle - 1, 40)

    print_char = if register - 1 <= col and col <= register + 1, do: "#", else: "."

    put_in(crt, [row, col], print_char)
  end

  defp get_signal_strengths(value_when_cycle, cycles),
    do: Enum.map(cycles, &(Map.get(value_when_cycle, &1) * &1))

  defp print_crt(crt) do
    for i <- 0..5, into: <<>> do
      line = for j <- 0..39, into: <<>>, do: get_in(crt, [i, j])

      "#{line}\n"
    end
    |> IO.puts()
  end
end

File.read!("input.txt")
|> tap(&Day10.part1/1)
|> tap(&Day10.part2/1)
