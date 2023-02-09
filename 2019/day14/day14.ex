defmodule Day14 do
  def part1(input) do
    input
    |> parse_input()
    |> topological_sort(%{FUEL: 1})
    |> Map.get(:ORE, -1)
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> daq(1, 1_000_000, 1_000_000_000_000)
    |> IO.inspect(label: "part2")
  end

  # returns: %{A: {10, %{ORE: 10}}, FUEL: {1, %{A: 2}}}
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " => "))
    |> Enum.into(%{}, fn [source, target] ->
      [target_count, target_name] = String.split(target, " ")

      source =
        source
        |> String.split(", ")
        |> Enum.into(%{}, fn src ->
          [count, name] = String.split(src, " ")

          {String.to_atom(name), String.to_integer(count)}
        end)

      {String.to_atom(target_name), {String.to_integer(target_count), source}}
    end)
  end

  defp topological_sort(reactions, need_resource) do
    reactions
    |> get_counts_of_incoming_edge()
    |> then(&do_topological_sort(reactions, &1, need_resource))
  end

  # %{A: 4, B: 1, C: 1, D: 1, E: 1, FUEL: 0, ORE: 2}
  defp get_counts_of_incoming_edge(reactions) do
    reactions
    |> Enum.flat_map(fn {_, {_, edges}} -> edges end)
    |> Enum.reduce(%{}, fn {node, _}, result -> Map.update(result, node, 1, &(&1 + 1)) end)
    |> Map.put(:FUEL, 0)
  end

  defp do_topological_sort(_, counts, needs) when map_size(counts) == 1, do: needs

  defp do_topological_sort(reactions, counts_of_iedge, need_resources) do
    need_resource =
      counts_of_iedge
      |> Enum.find(fn {_, count} -> count == 0 end)
      |> elem(0)

    counts_of_iedge = remove_ele_from_counts_of_iedges(counts_of_iedge, reactions, need_resource)

    {need_count, need_resources} = Map.pop!(need_resources, need_resource)

    # 1. 초과분 계산하면서 처리
    # 2. 위상정렬
    need_resources =
      reactions
      |> Map.get(need_resource)
      |> calc_need_resources(need_count)
      |> Map.merge(need_resources, fn _k, v1, v2 -> v1 + v2 end)

    do_topological_sort(
      reactions,
      counts_of_iedge,
      need_resources
    )
  end

  # counts_of_iedge에서 resource를 제거하고, resource를 to로 가지는 다른 애들의 카운트를 1 감소
  defp remove_ele_from_counts_of_iedges(counts_of_iedge, reactions, resource) do
    reactions
    |> Map.get(resource)
    |> elem(1)
    |> Enum.into(%{}, fn {from, _} -> {from, -1} end)
    |> Map.merge(counts_of_iedge, fn _k, v1, v2 -> v1 + v2 end)
    |> Map.delete(resource)
  end

  defp calc_need_resources({create_count, needs}, need_count) do
    needs
    |> Enum.into(%{}, fn {source, source_count} ->
      {source, source_count * ceil(need_count / create_count)}
    end)
  end

  # devide and Conquer
  # 단조 증가 혹은 단조 하락
  defp daq(reactions, min_fuel, max_fuel, limit_ore, result \\ 0)

  defp daq(_, min_fuel, max_fuel, _, result) when min_fuel > max_fuel,
    do: result

  defp daq(reactions, min_fuel, max_fuel, limit_ore, result) do
    cur_fuel = div(min_fuel + max_fuel, 2)

    %{ORE: need_ore} = topological_sort(reactions, %{FUEL: cur_fuel})

    cond do
      need_ore <= limit_ore ->
        daq(reactions, cur_fuel + 1, max_fuel, limit_ore, max(result, cur_fuel))

      true ->
        daq(reactions, min_fuel, cur_fuel - 1, limit_ore, result)
    end
  end
end

File.read!("input.txt")
|> tap(&Day14.part1/1)
|> tap(&Day14.part2/1)
