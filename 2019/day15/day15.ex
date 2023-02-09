defmodule Amplifier.Block do
  defstruct memory: %{}, inputs: [], offset: 0, base_pos: 0

  @type t :: %__MODULE__{
          memory: map(),
          inputs: list(),
          offset: non_neg_integer(),
          base_pos: integer()
        }

  @spec update(t(), keyword()) :: t()
  def update(block, attrs) do
    fields = __MODULE__.__struct__() |> Map.keys() |> Enum.reject(&(&1 == :__struct__))

    attrs
    |> Enum.filter(fn {k, _} -> k in fields end)
    |> Enum.reduce(block, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end
end

defmodule Amplifier.Executor do
  alias Amplifier.Block

  @add 1
  @multiply 2
  @input 3
  @output 4
  @jump_if_true 5
  @jump_if_false 6
  @less_than 7
  @equals 8
  @relative_base 9
  @exit 99

  def exec(%Block{memory: memory, offset: offset, inputs: inputs, base_pos: base_pos} = block) do
    operation = Map.get(memory, offset)
    {operator, param1_mode, param2_mode, param3_mode} = parse_operation(operation)

    case operator do
      @add ->
        new_val =
          get_value(memory, offset + 1, param1_mode, base_pos) +
            get_value(memory, offset + 2, param2_mode, base_pos)

        memory = update_memory(memory, offset + 3, new_val, param3_mode, base_pos)

        block
        |> Block.update(memory: memory, offset: offset + 4)
        |> exec()

      @multiply ->
        new_val =
          get_value(memory, offset + 1, param1_mode, base_pos) *
            get_value(memory, offset + 2, param2_mode, base_pos)

        memory = update_memory(memory, offset + 3, new_val, param3_mode, base_pos)

        block
        |> Block.update(memory: memory, offset: offset + 4)
        |> exec()

      @input when inputs == [] ->
        {:input, block}

      @input ->
        memory = update_memory(memory, offset + 1, hd(inputs), param1_mode, base_pos)

        block
        |> Block.update(memory: memory, offset: offset + 2, inputs: tl(inputs))
        |> exec()

      @output ->
        {
          :output,
          Block.update(block, offset: offset + 2),
          get_value(memory, offset + 1, param1_mode, base_pos)
        }

      @jump_if_true ->
        next_offset =
          if get_value(memory, offset + 1, param1_mode, base_pos) != 0,
            do: get_value(memory, offset + 2, param2_mode, base_pos),
            else: offset + 3

        block
        |> Block.update(offset: next_offset)
        |> exec()

      @jump_if_false ->
        next_offset =
          if get_value(memory, offset + 1, param1_mode, base_pos) == 0,
            do: get_value(memory, offset + 2, param2_mode, base_pos),
            else: offset + 3

        block
        |> Block.update(offset: next_offset)
        |> exec()

      @less_than ->
        param1 = get_value(memory, offset + 1, param1_mode, base_pos)
        param2 = get_value(memory, offset + 2, param2_mode, base_pos)

        memory =
          if param1 < param2 do
            update_memory(memory, offset + 3, 1, param3_mode, base_pos)
          else
            update_memory(memory, offset + 3, 0, param3_mode, base_pos)
          end

        block
        |> Block.update(memory: memory, offset: offset + 4)
        |> exec()

      @equals ->
        param1 = get_value(memory, offset + 1, param1_mode, base_pos)
        param2 = get_value(memory, offset + 2, param2_mode, base_pos)

        memory =
          if param1 == param2 do
            update_memory(memory, offset + 3, 1, param3_mode, base_pos)
          else
            update_memory(memory, offset + 3, 0, param3_mode, base_pos)
          end

        block
        |> Block.update(memory: memory, offset: offset + 4)
        |> exec()

      @relative_base ->
        param1 = get_value(memory, offset + 1, param1_mode, base_pos)

        block
        |> Block.update(offset: offset + 2, base_pos: base_pos + param1)
        |> exec()

      @exit ->
        :exit
    end
  end

  defp parse_operation(operation) do
    operator = rem(operation, 100)
    param1_mode = operation |> div(100) |> rem(10)
    param2_mode = operation |> div(1000) |> rem(10)
    param3_mode = operation |> div(10000)

    {operator, param1_mode, param2_mode, param3_mode}
  end

  defp get_value(memory, offset, 0, _base_pos) do
    pos = Map.get(memory, offset, 0)
    Map.get(memory, pos, 0)
  end

  defp get_value(memory, offset, 1, _base_pos), do: Map.get(memory, offset, 0)

  defp get_value(memory, offset, 2, base_pos) do
    pos = Map.get(memory, offset, 0)
    Map.get(memory, base_pos + pos, 0)
  end

  defp update_memory(memory, offset, value, 0, _base_pos) do
    pos = Map.get(memory, offset, 0)
    Map.put(memory, pos, value)
  end

  defp update_memory(memory, offset, value, 2, base_pos) do
    pos = Map.get(memory, offset, 0)
    Map.put(memory, base_pos + pos, value)
  end
end

defmodule Amplifier.Memory do
  alias Amplifier.Block

  def run(name, %Block{} = block) do
    setup_ets(name, block)
  end

  def get(ets_name) do
    :ets.lookup(ets_name, :block) |> Keyword.get(:block)
  end

  def set(ets_name, %Block{} = block) do
    :ets.insert(ets_name, {:block, block})
  end

  defp setup_ets(name, %Block{} = block) do
    ets_name = String.to_atom("ets-#{name}")
    :ets.new(ets_name, [:set, :public, :named_table])

    :ets.insert(ets_name, {:block, block})

    ets_name
  end
end

defmodule Amplifier do
  use GenServer

  alias Amplifier.Executor
  alias Amplifier.Memory
  alias Amplifier.Block

  # Client
  def start_link(name: name, memory: memory) do
    GenServer.start_link(__MODULE__, {name, memory}, name: name)
  end

  def exec(name) do
    GenServer.call(name, :exec)
  end

  def push_input(name, input) do
    GenServer.cast(name, {:push_input, input})
  end

  def exit(name) do
    GenServer.stop(name)
  end

  # Server
  def init({name, memory}) do
    block = %Block{memory: memory}

    {:ok, %{ets_name: Memory.run(name, block)}}
  end

  def handle_call(:exec, _from, %{:ets_name => ets_name} = state) do
    ets_name
    |> Memory.get()
    |> Executor.exec()
    |> case do
      {:output, block, output} ->
        Memory.set(ets_name, block)

        {:reply, {:output, output}, state}

      {:input, block} ->
        Memory.set(ets_name, block)

        {:reply, :input, state}

      :exit ->
        {:reply, :exit, state}
    end
  end

  def handle_cast({:push_input, input}, %{:ets_name => ets_name} = state) do
    ets_name
    |> Memory.get()
    |> Map.update(:inputs, [input], &(&1 ++ [input]))
    |> then(&Memory.set(ets_name, &1))

    {:noreply, state}
  end
end

defmodule Day15 do
  @amplifier :amplifier
  @dir [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def part1(input) do
    Amplifier.start_link(name: @amplifier, memory: parse_input(input))
    queue = :queue.new()
    queue = :queue.in({{0, 0}, 0}, queue)

    run_amplifier()
    |> inspect_grid()
    |> bfs(%{{0, 0} => true}, queue)
    |> tap(fn _ -> Amplifier.exit(@amplifier) end)
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {val, i} -> {i, val} end)
  end

  defp run_amplifier(grid \\ %{}, back_tracking \\ [], {y, x} = pos \\ {0, 0}) do
    with :input <- Amplifier.exec(@amplifier),
         {input, back_tracking} <- find_next_input(grid, back_tracking, pos) do
      Amplifier.push_input(@amplifier, input)

      {dy, dx} = Enum.at(@dir, input - 1)

      {grid, back_tracking, npos} =
        Amplifier.exec(@amplifier)
        |> elem(1)
        |> process_output(grid, back_tracking, pos, {y + dy, x + dx})

      run_amplifier(grid, back_tracking, npos)
    else
      :not_found -> grid
    end
  end

  defp find_next_input(grid, back_tracking, {y, x}) do
    @dir
    |> Enum.with_index(1)
    |> Enum.find(fn {{dy, dx}, _} -> not Map.has_key?(grid, {y + dy, x + dx}) end)
    |> case do
      {_, input} ->
        back_tracking_input = get_back_tracking_input(input)

        {input, [back_tracking_input | back_tracking]}

      nil ->
        case back_tracking do
          [] -> :not_found
          [input | back_tracking] -> {input, back_tracking}
        end
    end
  end

  defp get_back_tracking_input(1), do: 2
  defp get_back_tracking_input(2), do: 1
  defp get_back_tracking_input(3), do: 4
  defp get_back_tracking_input(4), do: 3

  defp process_output(0, grid, back_tracking, pos, npos) do
    grid = Map.put(grid, npos, "#")
    back_tracking = tl(back_tracking)

    {grid, back_tracking, pos}
  end

  defp process_output(1, grid, back_tracking, _pos, npos) do
    grid = Map.put(grid, npos, ".")

    {grid, back_tracking, npos}
  end

  defp process_output(2, grid, back_tracking, _pos, npos) do
    grid = Map.put(grid, npos, "O")

    {grid, back_tracking, npos}
  end

  defp inspect_grid(grid) do
    {{{min_y, _}, _}, {{max_y, _}, _}} = Enum.min_max_by(grid, fn {{y, _x}, _val} -> y end)
    {{{_, min_x}, _}, {{_, max_x}, _}} = Enum.min_max_by(grid, fn {{_y, x}, _val} -> x end)

    for y <- min_y..max_y, into: "" do
      for x <- min_x..max_x, into: "\n" do
        grid
        |> Map.get({y, x}, "#")
        |> case do
          "." -> "⬜️"
          "#" -> "⬛"
          "O" -> "🟦"
        end
        |> then(fn val -> if y == 0 and x == 0, do: "🟡", else: val end)
      end
    end
    |> IO.puts()

    grid
  end

  defp bfs(grid, visited, queue) do
    {{:value, {pos, distance}}, queue} = :queue.out(queue)

    if end?(grid, pos) do
      distance
    else
      {visited, queue} = update_bfs_info(grid, visited, queue, {pos, distance})

      bfs(grid, visited, queue)
    end
  end

  defp end?(grid, pos), do: Map.get(grid, pos) == "O"

  defp update_bfs_info(grid, visited, queue, {{y, x}, distance}) do
    @dir
    |> Enum.reduce({visited, queue}, fn {dy, dx}, {visited, queue} ->
      {ny, nx} = npos = {y + dy, x + dx}

      with false <- Map.has_key?(visited, npos),
           true <- move_possible?(grid, npos) do
        visited = Map.put(visited, npos, true)
        queue = :queue.in({npos, distance + 1}, queue)

        {visited, queue}
      else
        _ -> {visited, queue}
      end
    end)
  end

  defp move_possible?(grid, pos) do
    case Map.get(grid, pos) do
      "." -> true
      "O" -> true
      _ -> false
    end
  end
end

File.read!("input.txt")
|> tap(&Day15.part1/1)
