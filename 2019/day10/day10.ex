defmodule Day10 do
  def part1(input) do
    asteroids =
      input
      |> parse_input()
      |> get_all_possible_positions()

    asteroids
    |> Enum.map(&count_detected_asteroids(asteroids, &1))
    |> Enum.max()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, i}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.into(acc, fn {val, j} -> {{i, j}, val} end)
    end)
  end

  defp get_all_possible_positions(grid) do
    grid
    |> Map.filter(fn {_key, val} -> val == "#" end)
    |> Map.keys()
  end

  defp count_detected_asteroids(asteroids, {base_y, base_x} = base_pos) do
    asteroids
    |> Enum.reject(&(&1 == base_pos))
    |> Enum.into(MapSet.new(), fn {y, x} ->
      diff_y = y - base_y
      diff_x = x - base_x
      hypo = :math.sqrt(diff_y * diff_y + diff_x * diff_x)

      # {sin, cos}은 모든 각도에 대해 Unique함
      {(diff_y / hypo) |> Float.round(5), (diff_x / hypo) |> Float.round(5)}
    end)
    |> Enum.count()
  end
end

File.read!("input.txt")
|> tap(&Day10.part1/1)
