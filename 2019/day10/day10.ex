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

  def part2(input) do
    asteroids =
      input
      |> parse_input()
      |> get_all_possible_positions()

    best_position =
      asteroids
      |> Enum.map(fn pos -> {pos, count_detected_asteroids(asteroids, pos)} end)
      |> Enum.max_by(fn {_pos, count} -> count end)
      |> elem(0)

    {y, x} =
      asteroids
      |> get_destroyed_asteroids(best_position)
      |> Enum.at(199)

    IO.inspect(x * 100 + y, label: "part2")
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

      # {sin, cos}은 모든 각도에 대해 Unique함
      {sin(-diff_y, diff_x), cos(-diff_y, diff_x)}
    end)
    |> Enum.count()
  end

  def get_destroyed_asteroids(asteroids, base_pos) do
    # NOTE data flow
    # get_sin_cos_map:          %{ {1.0, 0 => [{거리1, pos1}, {거리2, pos2}]} }
    # get_sorted_positions:      [ [pos1, pos2], [pos3], ... ]
    # do_get_destroyed_asteroids: [..., pos2, ... pos3, pos1]
    # Enum.reverse:             [pos1, pos3, ... pos2, ...]

    asteroids
    |> Enum.reject(&(&1 == base_pos))
    |> get_sin_cos_map(base_pos)
    |> get_sorted_positions()
    |> do_get_destroyed_asteroids()
    |> Enum.reverse()
  end

  # NOTE return example: %{ {1.0, 0 => [{거리1, pos1}, {거리2, pos2}]} }
  defp get_sin_cos_map(asteroids, {base_y, base_x}) do
    Enum.reduce(asteroids, %{}, fn {y, x} = pos, acc ->
      diff_y = y - base_y
      diff_x = x - base_x
      hypo = :math.sqrt(diff_y * diff_y + diff_x * diff_x)

      key = {sin(-diff_y, diff_x), cos(-diff_y, diff_x)}

      case Map.get(acc, key) do
        nil ->
          Map.put(acc, key, [{hypo, pos}])

        prev ->
          val =
            [{hypo, pos} | prev]
            |> Enum.sort_by(fn {h, _} -> h end)

          Map.put(acc, key, val)
      end
    end)
  end

  # NOTE return example: [ [pos1, pos2], [pos3], ... ]
  defp get_sorted_positions(sin_cos_map) do
    sin_cos_map
    |> Enum.map(fn {{sin_val, cos_val}, val} ->
      {sin_val, cos_val, val}
    end)
    |> Enum.sort(fn {sin1, cos1, _}, {sin2, cos2, _} ->
      cond do
        cos1 >= 0 and cos2 < 0 ->
          true

        cos1 < 0 and cos2 >= 0 ->
          false

        cos1 >= 0 and cos2 >= 0 ->
          sin1 > sin2

        true ->
          sin1 < sin2
      end
    end)
    |> Enum.map(fn {_, _, val_list} ->
      Enum.map(val_list, fn {_hypo, pos} -> pos end)
    end)
  end

  defp do_get_destroyed_asteroids(asteroids, outputs \\ [])
  defp do_get_destroyed_asteroids([], outputs), do: outputs

  defp do_get_destroyed_asteroids(asteroids, outputs) do
    [asteroid | tail] = asteroids

    case asteroid do
      [pos] ->
        do_get_destroyed_asteroids(tail, [pos | outputs])

      [pos | remains] ->
        do_get_destroyed_asteroids(tail ++ [remains], [pos | outputs])
    end
  end

  defp sin(y, x, precision \\ 3) do
    hypo = :math.sqrt(y * y + x * x)

    (y / hypo) |> Float.round(precision)
  end

  defp cos(y, x, precision \\ 3) do
    hypo = :math.sqrt(y * y + x * x)

    (x / hypo) |> Float.round(precision)
  end
end

File.read!("input.txt")
|> tap(&Day10.part1/1)
|> tap(&Day10.part2/1)
