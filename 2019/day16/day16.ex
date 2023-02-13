defmodule Day16 do
  @base_pattern [0, 1, 0, -1]

  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> Enum.take(8)
    |> Enum.join()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end

  defp simulate(input), do: do_simulate(input, length(input), 0)

  defp do_simulate(input, _, 100), do: input

  defp do_simulate(input, input_length, phase) do
    1..input_length
    |> Enum.map(fn pos ->
      pattern = make_pattern(input_length, pos)

      input
      |> apply_pattern(pattern)
      |> abs()
      |> rem(10)
    end)
    |> do_simulate(input_length, phase + 1)
  end

  defp make_pattern(length, dup_count) do
    @base_pattern
    |> Enum.flat_map(&List.duplicate(&1, dup_count))
    |> Stream.cycle()
    |> Enum.take(length + 1)
    |> tl()
  end

  defp apply_pattern(list1, list2) do
    Enum.zip(list1, list2)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end
end

File.read!("input.txt")
|> tap(&Day16.part1/1)
