defmodule Day12 do
  def part1(input) do
    pos_list = parse_input(input)
    velocity_list = Enum.map(pos_list, &get_init_velocity/1)

    Enum.zip(pos_list, velocity_list)
    |> simulate(1_000)
    |> calc_total_energy()
    |> IO.inspect(label: "part1")
  end

  # return: [%{x: integer(), y: integer(), z: integer()}, ...]
  defp parse_input(input) do
    regex = ~r/x=(?<x>-?[[:digit:]]+), y=(?<y>-?[[:digit:]]+), z=(?<z>-?[[:digit:]]+)/

    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      Regex.named_captures(regex, line)
      |> Enum.into(%{}, fn {key, val} ->
        {String.to_atom(key), String.to_integer(val)}
      end)
    end)
  end

  # input: %{key: any(), ...}
  # return: %{key: 0, ...}
  defp get_init_velocity(pos), do: for({key, _} <- pos, into: %{}, do: {key, 0})

  defp simulate(moons, wanted_step, step \\ 0)
  defp simulate(moons, wanted_step, wanted_step), do: moons

  defp simulate(moons, wanted_step, step) do
    moons
    |> Enum.map(&apply_gravity(&1, moons))
    |> Enum.map(&apply_velocity/1)
    |> simulate(wanted_step, step + 1)
  end

  defp apply_gravity(moon, moons), do: Enum.reduce(moons, moon, &update_velocity(&2, &1))

  defp update_velocity({pos_map, vel_map} = _cur_moon, {other_pos_map, _} = _other_moon) do
    updated_velocity_map =
      Enum.reduce(pos_map, vel_map, fn {key, position}, result ->
        moved_value =
          cond do
            other_pos_map[key] < position -> -1
            other_pos_map[key] > position -> 1
            true -> 0
          end

        Map.update!(result, key, &(&1 + moved_value))
      end)

    {pos_map, updated_velocity_map}
  end

  defp apply_velocity({pos_map, vel_map}) do
    updated_position_map =
      Enum.into(pos_map, %{}, fn {key, pos_value} -> {key, pos_value + vel_map[key]} end)

    {updated_position_map, vel_map}
  end

  defp calc_total_energy(moons) do
    moons
    |> Enum.map(fn {pos_map, vel_map} ->
      pot = pos_map |> Map.values() |> Enum.map(&abs/1) |> Enum.sum()
      kin = vel_map |> Map.values() |> Enum.map(&abs/1) |> Enum.sum()

      pot * kin
    end)
    |> Enum.sum()
  end
end

File.read!("input.txt")
|> tap(&Day12.part1/1)
