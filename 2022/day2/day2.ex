defmodule Day2 do
  def part1(input) do
    input
    |> parse_input(1)
    |> calculate_game_score(1)
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input(2)
    |> calculate_game_score(2)
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input, part) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [a, b] ->
      case part do
        1 -> {convert_shape_to_int(a), convert_shape_to_int(b)}
        2 -> {convert_shape_to_int(a), convert_shape_to_result(b)}
      end
    end)
  end

  defp convert_shape_to_int(shape) when shape in ["A", "X"], do: 0
  defp convert_shape_to_int(shape) when shape in ["B", "Y"], do: 1
  defp convert_shape_to_int(shape) when shape in ["C", "Z"], do: 2

  defp convert_shape_to_result("X"), do: :lose
  defp convert_shape_to_result("Y"), do: :draw
  defp convert_shape_to_result("Z"), do: :win

  defp calculate_game_score(game, part) do
    game
    |> Enum.map(&calculate_round_score(&1, part))
    |> Enum.sum()
  end

  defp calculate_round_score({opponent, player}, 1) do
    get_outcome_score(player, opponent) + get_shape_score(player)
  end

  defp calculate_round_score({opponent, expected_result}, 2) do
    player_shape = get_player_shape(expected_result, opponent)

    get_outcome_score(player_shape, opponent) + get_shape_score(player_shape)
  end

  defp get_shape_score(shape_int), do: shape_int + 1

  defp get_outcome_score(player, opponent) do
    cond do
      player == opponent -> 3
      player == rem(opponent + 1, 3) -> 6
      true -> 0
    end
  end

  defp get_player_shape(expected_result, opponent) do
    case expected_result do
      :win -> rem(opponent + 1, 3)
      :draw -> opponent
      :lose -> rem(opponent + 2, 3)
    end
  end
end

File.read!("input.txt")
|> tap(&Day2.part1/1)
|> tap(&Day2.part2/1)
