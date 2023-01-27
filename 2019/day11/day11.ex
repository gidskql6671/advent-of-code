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

defmodule Robot do
  use GenServer

  @direction [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]

  # API
  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def rotate(pid, rotate_dir) do
    GenServer.cast(pid, {:rotate, rotate_dir})
  end

  def go_forward(pid) do
    GenServer.cast(pid, :go)
  end

  def print(pid, color) do
    GenServer.cast(pid, {:print, color})
  end

  def get_color_of_cur_panel(pid) do
    GenServer.call(pid, :get_color_of_cur_pos)
  end

  # Server
  def init(_) do
    {:ok, {{0, 0}, 0}}
  end

  def handle_cast({:rotate, 0}, {pos, cur_dir}),
    do: {:noreply, {pos, rem(cur_dir + 4 - 1, 4)}}

  def handle_cast({:rotate, 1}, {pos, cur_dir}),
    do: {:noreply, {pos, rem(cur_dir + 1, 4)}}

  def handle_cast(:go, {{y, x}, dir}) do
    {move_y, move_x} = Enum.at(@direction, dir)
    new_state = {{y + move_y, x + move_x}, dir}

    {:noreply, new_state}
  end

  def handle_cast({:print, color}, {{y, x}, _dir} = state) do
    :ets.insert(:grid, {{y, x}, color})

    {:noreply, state}
  end

  def handle_call(:get_color_of_cur_pos, _from, {pos, _dir} = state),
    do: {:reply, get_color_of_panel(pos), state}

  defp get_color_of_panel(pos) do
    case :ets.lookup(:grid, pos) do
      [] ->
        0

      arr ->
        arr |> hd() |> elem(1)
    end
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

  def run(name) do
    GenServer.call(name, :run)
  end

  def exit(name) do
    GenServer.stop(name)
  end

  # Server
  def init({name, memory}) do
    block = %Block{memory: memory}

    {:ok, %{ets_name: Memory.run(name, block)}, {:continue, :set_robot}}
  end

  def handle_continue(:set_robot, state) do
    {:ok, pid} = Robot.start_link()

    {:noreply, Map.put(state, :robot, pid)}
  end

  def handle_call(:run, _from, %{:ets_name => ets_name, :robot => robot} = state) do
    block = Memory.get(ets_name)

    excute(block, robot)

    {:reply, :exit, state}
  end

  defp excute(%Block{} = block, robot) do
    with {:input, %Block{inputs: []} = block} <- Executor.exec(block),
         color = Robot.get_color_of_cur_panel(robot),
         block = Map.put(block, :inputs, [color]),
         {:output, block, print_color} <- Executor.exec(block),
         Robot.print(robot, print_color),
         {:output, block, rotate_dir} <- Executor.exec(block) do
      Robot.rotate(robot, rotate_dir)
      Robot.go_forward(robot)

      excute(block, robot)
    end
  end
end

defmodule Day11 do
  def part1(input) do
    input = parse_input(input)
    name = :amplifier

    :ets.new(:grid, [:set, :public, :named_table])
    Amplifier.start_link(name: name, memory: input)
    Amplifier.run(name)
    Amplifier.exit(name)

    :grid
    |> :ets.match({{:_, :_}, :_})
    |> Enum.count()
    |> IO.inspect(label: "part1")

    :ets.delete(:grid)
  end

  def part2(input) do
    input = parse_input(input)
    name = :amplifier

    :ets.new(:grid, [:set, :public, :named_table])
    :ets.insert(:grid, {{0, 0}, 1})
    Amplifier.start_link(name: name, memory: input)
    Amplifier.run(name)
    Amplifier.exit(name)

    grid =
      :grid
      |> :ets.match({:"$1", :"$2"})
      |> Enum.into(%{}, fn [pos, color] -> {pos, color} end)

    :ets.delete(:grid)

    {{min_y, _}, {max_y, _}} =
      grid
      |> Map.keys()
      |> Enum.min_max_by(fn {y, _x} -> y end)

    {{_, min_x}, {_, max_x}} =
      grid
      |> Map.keys()
      |> Enum.min_max_by(fn {_y, x} -> x end)

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        case Map.get(grid, {y, x}, 0) do
          0 -> "⬜️"
          1 -> "⬛"
          2 -> "🟦"
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {val, i} -> {i, val} end)
  end
end

File.read!("input.txt")
|> tap(&Day11.part1/1)
|> tap(&Day11.part2/1)
