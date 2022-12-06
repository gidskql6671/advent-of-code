defmodule Day2 do
  def part1(input) do
    input
    |> parse_input()
    |> calculate_game_score()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [a, b] -> {convert_shape_to_int(a), convert_shape_to_int(b)} end)
  end

  defp convert_shape_to_int(shape) when shape in ["A", "X"], do: 0
  defp convert_shape_to_int(shape) when shape in ["B", "Y"], do: 1
  defp convert_shape_to_int(shape) when shape in ["C", "Z"], do: 2

  defp calculate_game_score(game) do
    game
    |> Enum.map(&calculate_round_score/1)
    |> Enum.sum()
  end

  defp calculate_round_score({opponent, player}) do
    get_outcome_score(player, opponent) + get_shape_score(player)
  end

  defp get_shape_score(shape_int), do: shape_int + 1

  defp get_outcome_score(player, opponent) do
    cond do
      player == opponent -> 3
      player == rem(opponent + 1, 3) -> 6
      true -> 0
    end
  end
end

File.read!("input.txt")
|> tap(&Day2.part1/1)
