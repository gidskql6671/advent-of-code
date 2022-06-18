defmodule Day6.Part1 do
  def run(graph, root), do: dfs(graph, root)

  defp dfs(graph, cur_node, orbit_depth \\ 0) do
    next_nodes = Map.get(graph, cur_node, [])

    orbit_count_all_descendants =
      next_nodes
      |> Enum.map(&dfs(graph, &1, orbit_depth + 1))
      |> Enum.sum()

    orbit_count_all_descendants + orbit_depth
  end
end

defmodule Day6.Part2 do
  def run(graph, root, start, dest) do
    start_node = get_parent_node(graph, start)
    dest_node = get_parent_node(graph, dest)

    dfs(graph, root, 0, start_node, dest_node)
    |> hd()
  end

  defp get_parent_node(graph, child_node) do
    graph
    |> Enum.find(fn {_, val} -> Enum.member?(val, child_node) end)
    |> elem(0)
  end

  defp dfs(_, cur_node, orbit_depth, cur_node, _), do: [orbit_depth]
  defp dfs(_, cur_node, orbit_depth, _, cur_node), do: [orbit_depth]

  defp dfs(graph, cur_node, orbit_depth, start_node, dest_node) do
    next_nodes = Map.get(graph, cur_node, [])

    next_nodes
    |> Enum.flat_map(&dfs(graph, &1, orbit_depth + 1, start_node, dest_node))
    |> case do
      [finded_orbit_depth1, finded_orbit_depth2] ->
        [finded_orbit_depth1 + finded_orbit_depth2 - orbit_depth * 2]

      [finded_orbit] ->
        [finded_orbit]

      _ ->
        []
    end
  end
end

File.read!("input.txt")
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, ")", trim: true))
|> Enum.reduce(%{}, fn [tail, head], acc ->
  Map.update(acc, tail, [head], &[head | &1])
end)
|> tap(&(Day6.Part1.run(&1, "COM") |> IO.inspect()))
|> tap(&(Day6.Part2.run(&1, "COM", "YOU", "SAN") |> IO.inspect()))
