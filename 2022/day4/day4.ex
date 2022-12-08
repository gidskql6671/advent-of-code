defmodule Day4 do
  def part1(input) do
    input
    |> parse_input()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
  end

end

File.read!("input.txt")
|> tap(&Day4.part1/1)
