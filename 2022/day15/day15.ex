defmodule Day15 do
  @regex ~r/Sensor at x=(?<sensor_x>-?\d+), y=(?<sensor_y>-?\d+): closest beacon is at x=(?<beacon_x>-?\d+), y=(?<beacon_y>-?\d+)/

  def part1(input) do
    input
    |> parse_input()
    |> find_beacon_exclusion_zone(2_000_000)
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Regex.named_captures(@regex, &1))
    |> Enum.map(fn %{"sensor_x" => sx, "sensor_y" => sy, "beacon_x" => bx, "beacon_y" => by} ->
      {{String.to_integer(sy), String.to_integer(sx)},
       {String.to_integer(by), String.to_integer(bx)}}
    end)
  end

  defp find_beacon_exclusion_zone(report, search_row) do
    report
    |> Enum.reduce(%{}, fn {{s_y, s_x} = sensor, {b_y, b_x} = beacon}, row ->
      (distance(sensor, beacon) - abs(s_y - search_row))
      |> case do
        x_range when x_range < 0 ->
          row

        x_range ->
          Enum.reduce(-x_range..x_range, row, &Map.put_new(&2, s_x + &1, "#"))
      end
      |> maybe_put(s_x, "S", s_y == search_row)
      |> maybe_put(b_x, "B", b_y == search_row)
    end)
    |> Enum.filter(fn {_, v} ->
      case v do
        "#" -> true
        "S" -> true
        _ -> false
      end
    end)
    |> Enum.count()
  end

  defp maybe_put(map, key, value, true), do: Map.put(map, key, value)
  defp maybe_put(map, _key, _value, false), do: map

  defp distance({y1, x1}, {y2, x2}), do: abs(y1 - y2) + abs(x1 - x2)
end

File.read!("input.txt")
|> tap(&Day15.part1/1)
