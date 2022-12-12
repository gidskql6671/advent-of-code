defmodule Amplifier.Executor do
  @add 1
  @multiply 2
  @input 3
  @output 4
  @jump_if_true 5
  @jump_if_false 6
  @less_than 7
  @equals 8
  @exit 99

  def exec(memory, offset, inputs) do
    operation = Map.get(memory, offset)
    {operator, param1_mode, param2_mode} = parse_operation(operation)

    case operator do
      @add ->
        new_val =
          get_value(memory, offset + 1, param1_mode) + get_value(memory, offset + 2, param2_mode)

        memory = update_memory(memory, offset + 3, new_val)
        exec(memory, offset + 4, inputs)

      @multiply ->
        new_val =
          get_value(memory, offset + 1, param1_mode) * get_value(memory, offset + 2, param2_mode)

        memory = update_memory(memory, offset + 3, new_val)
        exec(memory, offset + 4, inputs)

      @input when inputs == [] ->
        {
          :input,
          memory,
          offset,
          inputs
        }

      @input ->
        memory = update_memory(memory, offset + 1, hd(inputs))
        exec(memory, offset + 2, tl(inputs))

      @output ->
        {
          :output,
          get_value(memory, offset + 1, param1_mode),
          memory,
          offset + 2,
          inputs
        }

      @jump_if_true ->
        jump_offset =
          if get_value(memory, offset + 1, param1_mode) != 0 do
            get_value(memory, offset + 2, param2_mode)
          else
            offset + 3
          end

        exec(memory, jump_offset, inputs)

      @jump_if_false ->
        jump_offset =
          if get_value(memory, offset + 1, param1_mode) == 0 do
            get_value(memory, offset + 2, param2_mode)
          else
            offset + 3
          end

        exec(memory, jump_offset, inputs)

      @less_than ->
        param1 = get_value(memory, offset + 1, param1_mode)
        param2 = get_value(memory, offset + 2, param2_mode)

        memory =
          if param1 < param2 do
            update_memory(memory, offset + 3, 1)
          else
            update_memory(memory, offset + 3, 0)
          end

        exec(memory, offset + 4, inputs)

      @equals ->
        param1 = get_value(memory, offset + 1, param1_mode)
        param2 = get_value(memory, offset + 2, param2_mode)

        memory =
          if param1 == param2 do
            update_memory(memory, offset + 3, 1)
          else
            update_memory(memory, offset + 3, 0)
          end

        exec(memory, offset + 4, inputs)

      @exit ->
        :exit
    end
  end

  defp parse_operation(operation) do
    operator = rem(operation, 100)
    param1_mode = operation |> div(100) |> rem(10)
    param2_mode = operation |> div(1000) |> rem(10)

    {operator, param1_mode, param2_mode}
  end

  defp get_value(memory, offset, 0) do
    pos = Map.get(memory, offset, 0)
    Map.get(memory, pos, 0)
  end

  defp get_value(memory, offset, 1), do: Map.get(memory, offset, 0)

  defp update_memory(memory, offset, value) do
    pos = Map.get(memory, offset, 0)
    Map.put(memory, pos, value)
  end
end

defmodule Amplifier.Memory do
  def run(), do: :ets.new(__MODULE__, [:set, :public])

  def get(pid, key), do: :ets.lookup(pid, key) |> Keyword.get(key)

  def set(pid, keywords), do: :ets.insert(pid, keywords)
end

defmodule Amplifier do
  use GenServer

  alias Amplifier.Executor
  alias Amplifier.Memory

  # Client
  def start_link(memory: memory) do
    GenServer.start_link(__MODULE__, {memory})
  end

  def exec(pid), do: GenServer.call(pid, :exec)

  def push_input(pid, input), do: GenServer.cast(pid, {:push_input, input})

  def exit(pid), do: GenServer.stop(pid)

  # Server
  def init({memory}) do
    ets = Memory.run()

    Memory.set(ets,
      memory: memory,
      inputs: [],
      offset: 0
    )

    {:ok, %{ets: ets}}
  end

  def handle_call(:exec, _from, %{ets: ets} = state) do
    memory = Memory.get(ets, :memory)
    offset = Memory.get(ets, :offset)
    inputs = Memory.get(ets, :inputs)

    case Executor.exec(memory, offset, inputs) do
      {:output, output, updated_memory, next_offset, remain_inputs} ->
        Memory.set(ets,
          memory: updated_memory,
          offset: next_offset,
          inputs: remain_inputs
        )

        {:reply, {:output, output}, state}

      {:input, updated_memory, next_offset, []} ->
        Memory.set(ets,
          memory: updated_memory,
          offset: next_offset,
          inputs: []
        )

        {:reply, :input, state}

      :exit ->
        {:reply, :exit, state}
    end
  end

  def handle_cast({:push_input, input}, %{ets: ets} = state) do
    prev_inputs = Memory.get(ets, :inputs)
    Memory.set(ets, inputs: prev_inputs ++ [input])

    {:noreply, state}
  end
end

defmodule Permutation do
  def of([]), do: [[]]

  def of(list) do
    for h <- list, t <- of(list -- [h]), do: [h | t]
  end
end

defmodule Day7.Part1 do
  def run(memory) do
    [0, 1, 2, 3, 4]
    |> Permutation.of()
    |> Enum.map(&run_phase(memory, &1))
    |> Enum.max()
  end

  defp run_phase(memory, phases) do
    Enum.reduce(phases, 0, fn phase, signal ->
      {:ok, pid} = Amplifier.start_link(memory: memory)
      Amplifier.push_input(pid, phase)
      Amplifier.push_input(pid, signal)

      run_amplifier(pid)
      |> tap(fn _ -> Amplifier.exit(pid) end)
    end)
  end

  defp run_amplifier(pid) do
    case Amplifier.exec(pid) do
      :input ->
        raise "unexpected input instruction"

      {:output, output} ->
        output
    end
  end
end

defmodule Day7.Part2 do
  def run(memory) do
    [5, 6, 7, 8, 9]
    |> Permutation.of()
    |> Enum.map(&run_phase(memory, &1))
    |> Enum.max()
  end

  defp run_phase(memory, phases) do
    amplifiers = setup_amplifiers(memory, phases)

    amplifiers
    |> Stream.cycle()
    |> Enum.reduce_while(0, fn amplifier, signal ->
      Amplifier.push_input(amplifier, signal)

      case run_amplifier(amplifier) do
        :exit ->
          {:halt, signal}

        signal ->
          {:cont, signal}
      end
    end)
    |> tap(fn _ -> Enum.each(amplifiers, &Amplifier.exit/1) end)
  end

  defp setup_amplifiers(memory, phases) do
    Enum.map(phases, fn phase ->
      {:ok, pid} = Amplifier.start_link(memory: memory)
      Amplifier.push_input(pid, phase)

      pid
    end)
  end

  defp run_amplifier(pid) do
    case Amplifier.exec(pid) do
      :input ->
        raise "unexpected input instruction"

      {:output, output} ->
        output

      :exit ->
        :exit
    end
  end
end

File.read!("input.txt")
|> String.split(",", trim: true)
|> Enum.map(&String.to_integer/1)
|> Enum.with_index()
|> Enum.into(%{}, fn {val, i} -> {i, val} end)
|> tap(&(Day7.Part1.run(&1) |> IO.inspect(label: "Part 1")))
|> tap(&(Day7.Part2.run(&1) |> IO.inspect(label: "Part 2")))
