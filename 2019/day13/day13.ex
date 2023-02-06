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

defmodule Day13 do
  @amplifier :amplifier

  @empty 0
  @wall 1
  @block 2
  @paddle 3
  @ball 4

  def part1(input) do
    Amplifier.start_link(name: @amplifier, memory: parse_input(input))

    run_amplifier_for_part1()
    |> tap(fn _ -> Amplifier.exit(@amplifier) end)
    |> tap(&print/1)
    |> count_block()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    memory = input |> parse_input() |> Map.put(0, 2)
    Amplifier.start_link(name: @amplifier, memory: memory)

    run_amplifier_for_part2()
    |> tap(fn _ -> Amplifier.exit(@amplifier) end)
  end

  defp parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {val, i} -> {i, val} end)
  end

  defp run_amplifier_for_part1(grid \\ %{}) do
    with {:output, x} <- Amplifier.exec(@amplifier),
         {:output, y} <- Amplifier.exec(@amplifier),
         {:output, id} <- Amplifier.exec(@amplifier) do
      grid
      |> Map.put({x, y}, id)
      |> run_amplifier_for_part1()
    else
      :input ->
        raise "???"

      :exit ->
        grid
    end
  end

  defp run_amplifier_for_part2(grid \\ %{}, score \\ 0) do
    with {:output, x} <- Amplifier.exec(@amplifier),
         {:output, y} <- Amplifier.exec(@amplifier),
         {:output, val} <- Amplifier.exec(@amplifier) do
      case parse_operation(x, y, val) do
        {:score, cur_score} ->
          run_amplifier_for_part2(grid, cur_score)

        {:grid, {pos, id}} ->
          grid
          |> Map.put(pos, id)
          |> run_amplifier_for_part2(score)
      end
    else
      :input ->
        print(grid)
        IO.inspect(score, label: "점수")
        Process.sleep(10)

        grid
        |> tap(&cast_move_ball/1)
        |> run_amplifier_for_part2(score)

      :exit ->
        print(grid)
        IO.inspect(score, label: "Part2 - 최종 점수")
    end
  end

  defp parse_operation(-1, 0, score), do: {:score, score}
  defp parse_operation(x, y, id), do: {:grid, {{x, y}, id}}

  defp cast_move_ball(grid) do
    with {ball_x, _} <- get_cur_ball_pos(grid),
         {paddle_x, _} <- get_cur_paddle_pos(grid) do
      cond do
        ball_x < paddle_x -> -1
        ball_x > paddle_x -> 1
        true -> 0
      end
    end
    |> then(&Amplifier.push_input(@amplifier, &1))
  end

  defp get_cur_ball_pos(grid) do
    grid
    |> Enum.find(fn {_pos, id} -> id == @ball end)
    |> elem(0)
  end

  defp get_cur_paddle_pos(grid) do
    grid
    |> Enum.find(fn {_pos, id} -> id == @paddle end)
    |> elem(0)
  end

  defp print(grid) do
    IO.puts("\e[H\e[2J")

    for y <- 0..19, into: "" do
      for x <- 0..36, into: "\n" do
        case Map.get(grid, {x, y}, 0) do
          @empty -> "⬜️"
          @wall -> "⬛"
          @block -> "🟦"
          @paddle -> "🟥"
          @ball -> "🟡"
        end
      end
    end
    |> IO.puts()
  end

  defp count_block(grid) do
    Enum.count(grid, fn {_pos, value} -> value == @block end)
  end
end

File.read!("input.txt")
|> tap(&Day13.part1/1)
|> tap(&Day13.part2/1)
