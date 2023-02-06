defmodule Day12 do
  def part1(input) do
    pos_list = parse_input(input)
    velocity_list = Enum.map(pos_list, &get_init_velocity/1)

    Enum.zip(pos_list, velocity_list)
    |> simulate_until_step(1_000)
    |> calc_total_energy()
    |> IO.inspect(label: "part1")
  end

  # NOTE 핵심 아이디어.
  # 각각의 축은 서로 독립적이다. 그러니 각각의 축에 대해 초기 상태로 돌아오는 단계 수를 구하고, 이들의 최소공배수를 구하면 된다.
  def part2(input) do
    pos_list = parse_input(input)

    pos_x_list = pos_list |> Enum.map(fn %{x: val} -> %{x: val} end)
    pos_y_list = pos_list |> Enum.map(fn %{y: val} -> %{y: val} end)
    pos_z_list = pos_list |> Enum.map(fn %{z: val} -> %{z: val} end)

    period_x =
      pos_x_list
      |> Enum.map(&get_init_velocity/1)
      |> then(&Enum.zip(pos_x_list, &1))
      |> then(&simulate_until_same_moons(&1, &1))

    period_y =
      pos_y_list
      |> Enum.map(&get_init_velocity/1)
      |> then(&Enum.zip(pos_y_list, &1))
      |> then(&simulate_until_same_moons(&1, &1))

    period_z =
      pos_z_list
      |> Enum.map(&get_init_velocity/1)
      |> then(&Enum.zip(pos_z_list, &1))
      |> then(&simulate_until_same_moons(&1, &1))

    period_x
    |> lcm(period_y)
    |> lcm(period_z)
    |> IO.inspect(label: "part2")
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

  defp simulate_until_step(moons, wanted_step, step \\ 0)
  defp simulate_until_step(moons, wanted_step, wanted_step), do: moons

  defp simulate_until_step(moons, wanted_step, step) do
    moons
    |> Enum.map(&apply_gravity(&1, moons))
    |> Enum.map(&apply_velocity/1)
    |> simulate_until_step(wanted_step, step + 1)
  end

  defp simulate_until_same_moons(moons, expected_moons, step \\ 0)
  defp simulate_until_same_moons(moons, moons, step) when step > 0, do: step

  defp simulate_until_same_moons(moons, expected_moons, step) do
    moons
    |> Enum.map(&apply_gravity(&1, moons))
    |> Enum.map(&apply_velocity/1)
    |> simulate_until_same_moons(expected_moons, step + 1)
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

  defp gcd(a, 0), do: a
  defp gcd(a, b) when a < b, do: gcd(b, a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(a, b), do: div(a * b, gcd(a, b))
end

File.read!("input.txt")
|> tap(&Day12.part1/1)
|> tap(&Day12.part2/1)
