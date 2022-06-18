defmodule Day6.Part1 do
  def run(graph, root \\ "COM"), do: dfs(graph, root)

  defp dfs(graph, cur_node, orbit_depth \\ 0) do
    next_nodes = Map.get(graph, cur_node, [])

    orbit_count_all_descendants =
      next_nodes
      |> Enum.map(&dfs(graph, &1, orbit_depth + 1))
      |> Enum.sum()

    orbit_count_all_descendants + orbit_depth
  end
end

File.read!("input.txt")
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, ")", trim: true))
|> Enum.reduce(%{}, fn [tail, head], acc ->
  Map.update(acc, tail, [head], &[head | &1])
end)
|> tap(&(Day6.Part1.run(&1) |> IO.inspect()))
