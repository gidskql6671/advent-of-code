defmodule Day14 do
  @source {0, 500}
  @directions [{1, 0}, {1, -1}, {1, 1}]

  def part1(input) do
    input
    |> parse_input()
    |> make_cave()
    |> simulate()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn [x, y] -> {String.to_integer(y), String.to_integer(x)} end)
    end)
  end

  defp make_cave(paths) do
    Enum.reduce(paths, %{}, fn path, grid ->
      [first | path] = path

      path
      |> Enum.reduce({grid, first}, fn point, {grid, prev} ->
        grid = draw_line(grid, prev, point)

        {grid, point}
      end)
      |> elem(0)
    end)
  end

  defp draw_line(grid, {y, from_x}, {y, to_x}) do
    Enum.reduce(from_x..to_x, grid, fn x, grid -> put_into_grid(grid, {y, x}, "#") end)
  end

  defp draw_line(grid, {from_y, x}, {to_y, x}) do
    Enum.reduce(from_y..to_y, grid, fn y, grid -> put_into_grid(grid, {y, x}, "#") end)
  end

  defp simulate(grid) do
    floor_y =
      grid
      |> Enum.map(fn {y, _} -> y end)
      |> Enum.max()

    simulate(grid, floor_y, 0)
  end

  defp simulate(grid, floor_y, count) do
    case fall_sand(grid, floor_y, @source) do
      {:ok, grid} -> simulate(grid, floor_y, count + 1)
      :infinite -> count
    end
  end

  defp fall_sand(_grid, floor_y, {floor_y, _}), do: :infinite

  defp fall_sand(grid, floor_y, {cur_y, cur_x} = cur_pos) do
    @directions
    |> Enum.find(fn {dy, dx} ->
      grid
      |> get_in([cur_y + dy, cur_x + dx])
      |> is_nil()
    end)
    |> case do
      nil -> {:ok, put_into_grid(grid, cur_pos, "o")}
      {dy, dx} -> fall_sand(grid, floor_y, {cur_y + dy, cur_x + dx})
    end
  end

  defp put_into_grid(grid, {y, x}, value) do
    grid
    |> Map.put_new(y, %{})
    |> put_in([y, x], value)
  end
end

File.read!("input.txt")
|> tap(&Day14.part1/1)
