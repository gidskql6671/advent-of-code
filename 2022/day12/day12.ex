defmodule Day12 do
  import Kernel, except: [get_in: 2]

  @directions [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]

  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    input
    |> parse_input()
    |> simulate([?S, ?a])
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&:binary.first/1)
      |> Enum.with_index()
      |> Enum.into(%{}, fn {v, index} -> {index, v} end)
    end)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {v, index} -> {index, v} end)
  end

  defp simulate(grid, start_values \\ [?S]) do
    start_positions = find_positions_by_values(grid, start_values)
    end_position = find_position_by_value(grid, ?E)

    grid =
      grid
      |> put_in(Tuple.to_list(find_position_by_value(grid, ?S)), ?a)
      |> put_in(Tuple.to_list(end_position), ?z)

    start_positions
    |> Enum.map(fn start_position ->
      visited = Enum.into(grid, %{}, fn {i, _} -> {i, %{}} end)

      queue = :queue.new() |> push({start_position, 0})

      bfs(grid, end_position, visited, queue)
    end)
    |> Enum.min()
  end

  defp find_position_by_value(grid, value) do
    Enum.reduce_while(grid, {0, 0}, fn {i, row}, _ ->
      row
      |> Enum.find(fn {_j, ele} -> ele == value end)
      |> case do
        nil -> {:cont, {0, 0}}
        {j, _ele} -> {:halt, {i, j}}
      end
    end)
  end

  defp find_positions_by_values(grid, values) do
    Enum.reduce(grid, [], fn {i, row}, result ->
      Enum.reduce(row, result, fn {j, ele}, result ->
        if Enum.any?(values, &(&1 == ele)), do: [{i, j} | result], else: result
      end)
    end)
  end

  defp bfs(grid, {end_y, end_x} = end_pos, visited, queue) do
    case pop(queue) do
      {_queue, :empty} ->
        999_999

      {_queue, {{^end_y, ^end_x}, step}} ->
        step

      {queue, {cur_pos, step}} ->
        {queue, visited} =
          grid
          |> find_possible_next_destinations(cur_pos, visited)
          |> update_next_destinations(queue, visited, step)

        bfs(grid, end_pos, visited, queue)
    end
  end

  defp find_possible_next_destinations(grid, {cur_y, cur_x}, visited) do
    cur_height = get_in(grid, Tuple.to_list({cur_y, cur_x}))

    @directions
    |> Enum.filter(fn {dy, dx} ->
      next_y = cur_y + dy
      next_x = cur_x + dx
      next_height = get_in(grid, [next_y, next_x], 999)

      cond do
        get_in(visited, [next_y, next_x], false) -> false
        next_height > cur_height + 1 -> false
        true -> true
      end
    end)
    |> Enum.map(fn {dy, dx} -> {cur_y + dy, cur_x + dx} end)
  end

  defp update_next_destinations([], queue, visited, _step), do: {queue, visited}

  defp update_next_destinations([next_destination | remain], queue, visited, step) do
    update_next_destinations(
      remain,
      push(queue, {next_destination, step + 1}),
      put_in(visited, Tuple.to_list(next_destination), true),
      step
    )
  end

  defp push(queue, val), do: :queue.in(val, queue)

  defp pop(queue) do
    case :queue.out(queue) do
      {{:value, val}, queue} ->
        {queue, val}

      {:empty, queue} ->
        {queue, :empty}
    end
  end

  defp get_in(data, keys, default \\ nil) do
    case Kernel.get_in(data, keys) do
      nil -> default
      result -> result
    end
  end
end

File.read!("input.txt")
|> tap(&Day12.part1/1)
|> tap(&Day12.part2/1)
