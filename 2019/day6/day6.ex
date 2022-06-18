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
  @moduledoc """
  Advent of Code 2019의 Day6 Par2 풀이코드

  접근법은 쉽게 생각하면 두 가지가 있다고 생각됨.
  1. 무방향 그래프로 생성 후, bfs
  2. 방향 그래프를 그대로 사용하면서, root에서 탐색 후 간단한 연산

  해당 코드는 2번 방법을 사용했으며, 루트에서 각 노드까지의 depth를 먼저 구한다.
  그리고 두 노드에서 조상 노드로 거슬러 올라갔을 때, 최초로 공통되는 조상 노드의 depth를 구한다.
  마지막으로 두 노드의 depth를 더하고 조상 노드의 depth * 2를 빼주면, 두 노드의 거리가 나온다.

  example)
    A -> B -> C -> D
    A -> B -> E -> F
    라는 그래프가 있고, A가 루트이며, D와 F 사이의 거리를 구한다고 가정해보자.
    D의 depth는 3, F의 depth도 3이다. D와 F의 최초 공통 조상 노드는 B이고, B의 depth는 1이다.
    `3 + 3 - (1 * 2)`라는 공식에 의해 두 노드의 거리는 4가 나온다.
  """

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
