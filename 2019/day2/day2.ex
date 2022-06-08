defmodule Amplifier do
  def run(memory), do: do_run(memory, 0)

  defp do_run(memory, offset) do
    case Map.get(memory, offset) do
      1 ->
        new_val =
          get_value(memory, offset + 1) + get_value(memory, offset + 2)

        memory = update_memory(memory, offset + 3, new_val)
        do_run(memory, offset + 4)

      2 ->
        new_val =
          get_value(memory, offset + 1) * get_value(memory, offset + 2)

        memory = update_memory(memory, offset + 3, new_val)
        do_run(memory, offset + 4)

      99 ->
        memory
    end
  end

  defp get_value(memory, offset) do
    address = Map.get(memory, offset, 0)
    Map.get(memory, address, 0)
  end

  defp update_memory(memory, offset, value) do
    address = Map.get(memory, offset, 0)
    Map.put(memory, address, value)
  end
end

defmodule Day2 do
  def part1(input) do
    input
    |> parse_input()
    |> Map.put(1, 12)
    |> Map.put(2, 2)
    |> Amplifier.run()
    |> Map.get(0)
  end

  def part2(input) do
    init_memory = input |> parse_input()

    for noun <- 0..99, verb <- 0..99 do
      init_memory
      |> Map.put(1, noun)
      |> Map.put(2, verb)
      |> Amplifier.run()
      |> Map.get(0)
      |> case do
        1969_0720 ->
          noun * 100 + verb

        _ ->
          0
      end
    end
    |> Enum.max()
  end

  defp parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {val, i} -> {i, val} end)
  end
end

File.read!("input.txt")
|> tap(fn input -> input |> Day2.part1() |> IO.inspect(label: "part1") end)
|> tap(fn input -> input |> Day2.part2() |> IO.inspect(label: "part2") end)
