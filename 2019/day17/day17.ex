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

defmodule Day17 do
  @amplifier :amplifier
  @dir [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
  @scaffold ?#
  @blank ?.

  def part1(input) do
    Amplifier.start_link(name: @amplifier, memory: parse_input(input))

    run_amplifier()
    |> tap(fn _ -> Amplifier.exit(@amplifier) end)
    # |> print()
    |> get_alignment_parameters()
    |> Enum.sum()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {val, i} -> {i, val} end)
  end

  defp run_amplifier(grid \\ %{}, {y, x} = pos \\ {0, 0}) do
    case Amplifier.exec(@amplifier) do
      {:output, ?\n} ->
        run_amplifier(grid, {y + 1, 0})

      {:output, value} ->
        grid
        |> Map.put(pos, value)
        |> run_amplifier({y, x + 1})

      :exit ->
        grid
    end
  end

  defp print(grid) do
    {{min_y, min_x}, {max_y, max_x}} = min_max_pos(grid)

    for i <- min_y..max_y, into: <<>> do
      line = for j <- min_x..max_x, do: Map.get(grid, {i, j})

      (line ++ ['\n'])
      |> List.to_string()
    end
    |> IO.puts()
  end

  defp get_alignment_parameters(grid) do
    {{min_y, min_x}, _} = min_max_pos(grid)

    grid
    |> Map.keys()
    |> Enum.filter(&intersection?(grid, &1))
    |> Enum.map(fn {y, x} -> (y - min_y) * (x - min_x) end)
  end

  defp intersection?(grid, {y, x} = pos) do
    if Map.get(grid, pos) == @scaffold do
      Enum.all?(@dir, fn {dy, dx} -> Map.get(grid, {y + dy, x + dx}) == @scaffold end)
    else
      false
    end
  end

  defp min_max_pos(grid) do
    {{min_y, _}, {max_y, _}} = grid |> Map.keys() |> Enum.min_max_by(fn {y, _x} -> y end)
    {{_, min_x}, {_, max_x}} = grid |> Map.keys() |> Enum.min_max_by(fn {_y, x} -> x end)

    {{min_y, min_x}, {max_y, max_x}}
  end
end

File.read!("input.txt")
|> tap(&Day17.part1/1)
