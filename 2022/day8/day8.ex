defmodule Day8 do
  def part1(input) do
    input
    |> parse_input()
    |> calculate_visible_tree()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> calculate_scenic_scores()
    |> Enum.max()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {v, index} -> {index, v} end)
    end)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {v, index} -> {index, v} end)
  end

  defp calculate_visible_tree(grid) do
    n = Enum.count(grid) - 1
    m = Enum.count(grid[0]) - 1

    Enum.reduce(0..n, 0, fn y, result ->
      Enum.reduce(0..m, result, fn x, sum ->
        if visible?(grid, y, x, n, m), do: sum + 1, else: sum
      end)
    end)
  end

  defp visible?(_grid, 0, _x, _n, _m), do: true
  defp visible?(_grid, _y, 0, _n, _m), do: true
  defp visible?(_grid, y, _x, y, _m), do: true
  defp visible?(_grid, _y, x, _n, x), do: true

  defp visible?(grid, y, x, n, m) do
    tree_height = get_in(grid, [y, x])

    top_y_list = 0..(y - 1)
    bottom_y_list = (y + 1)..n
    left_x_list = 0..(x - 1)
    right_x_list = (x + 1)..m

    with false <- not Enum.any?(top_y_list, &(get_in(grid, [&1, x]) >= tree_height)),
         false <- not Enum.any?(bottom_y_list, &(get_in(grid, [&1, x]) >= tree_height)),
         false <- not Enum.any?(left_x_list, &(get_in(grid, [y, &1]) >= tree_height)),
         false <- not Enum.any?(right_x_list, &(get_in(grid, [y, &1]) >= tree_height)) do
      false
    end
  end

  defp calculate_scenic_scores(grid) do
    n = Enum.count(grid) - 1
    m = Enum.count(grid[0]) - 1

    for i <- 0..n, j <- 0..m do
      calculate_scenic_score(grid, i, j, n, m)
    end
  end

  defp calculate_scenic_score(grid, y, x, n, m) do
    get_visible_count(grid, y, x, n, m, :left) *
      get_visible_count(grid, y, x, n, m, :right) *
      get_visible_count(grid, y, x, n, m, :up) *
      get_visible_count(grid, y, x, n, m, :down)
  end

  defp get_visible_count(_grid, _y, 0, _n, _m, :left), do: 0
  defp get_visible_count(_grid, _y, x, _n, x, :right), do: 0
  defp get_visible_count(_grid, 0, _x, _n, _m, :up), do: 0
  defp get_visible_count(_grid, y, _x, y, _m, :down), do: 0

  defp get_visible_count(grid, y, x, _n, _m, :left) do
    tree_height = get_in(grid, [y, x])

    Enum.reduce_while((x - 1)..0, 0, fn other_x, acc ->
      other_height = get_in(grid, [y, other_x])

      cond do
        other_height >= tree_height -> {:halt, acc + 1}
        true -> {:cont, acc + 1}
      end
    end)
  end

  defp get_visible_count(grid, y, x, _n, m, :right) do
    tree_height = get_in(grid, [y, x])

    Enum.reduce_while((x + 1)..m, 0, fn other_x, acc ->
      other_height = get_in(grid, [y, other_x])

      cond do
        other_height >= tree_height -> {:halt, acc + 1}
        true -> {:cont, acc + 1}
      end
    end)
  end

  defp get_visible_count(grid, y, x, _n, _m, :up) do
    tree_height = get_in(grid, [y, x])

    Enum.reduce_while((y - 1)..0, 0, fn other_y, acc ->
      other_height = get_in(grid, [other_y, x])

      cond do
        other_height >= tree_height -> {:halt, acc + 1}
        true -> {:cont, acc + 1}
      end
    end)
  end

  defp get_visible_count(grid, y, x, n, _m, :down) do
    tree_height = get_in(grid, [y, x])

    Enum.reduce_while((y + 1)..n, 0, fn other_y, acc ->
      other_height = get_in(grid, [other_y, x])

      cond do
        other_height >= tree_height -> {:halt, acc + 1}
        true -> {:cont, acc + 1}
      end
    end)
  end
end

File.read!("input.txt")
|> tap(&Day8.part1/1)
|> tap(&Day8.part2/1)
