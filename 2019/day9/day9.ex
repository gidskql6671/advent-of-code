defmodule Amplifier.Executor do
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

  def exec(memory, offset, inputs, base_pos \\ 0) do
    operation = Map.get(memory, offset)
    {operator, param1_mode, param2_mode, param3_mode} = parse_operation(operation)

    case operator do
      @add ->
        new_val =
          get_value(memory, offset + 1, param1_mode, base_pos) +
            get_value(memory, offset + 2, param2_mode, base_pos)

        memory = update_memory(memory, offset + 3, new_val, param3_mode, base_pos)
        exec(memory, offset + 4, inputs, base_pos)

      @multiply ->
        new_val =
          get_value(memory, offset + 1, param1_mode, base_pos) *
            get_value(memory, offset + 2, param2_mode, base_pos)

        memory = update_memory(memory, offset + 3, new_val, param3_mode, base_pos)
        exec(memory, offset + 4, inputs, base_pos)

      @input ->
        memory = update_memory(memory, offset + 1, hd(inputs), param1_mode, base_pos)
        exec(memory, offset + 2, tl(inputs), base_pos)

      @output ->
        IO.inspect(get_value(memory, offset + 1, param1_mode, base_pos))
        exec(memory, offset + 2, inputs, base_pos)

      @jump_if_true ->
        if get_value(memory, offset + 1, param1_mode, base_pos) != 0 do
          jump_offset = get_value(memory, offset + 2, param2_mode, base_pos)
          exec(memory, jump_offset, inputs, base_pos)
        else
          exec(memory, offset + 3, inputs, base_pos)
        end

      @jump_if_false ->
        if get_value(memory, offset + 1, param1_mode, base_pos) == 0 do
          jump_offset = get_value(memory, offset + 2, param2_mode, base_pos)
          exec(memory, jump_offset, inputs, base_pos)
        else
          exec(memory, offset + 3, inputs, base_pos)
        end

      @less_than ->
        param1 = get_value(memory, offset + 1, param1_mode, base_pos)
        param2 = get_value(memory, offset + 2, param2_mode, base_pos)

        memory =
          if param1 < param2 do
            update_memory(memory, offset + 3, 1, param3_mode, base_pos)
          else
            update_memory(memory, offset + 3, 0, param3_mode, base_pos)
          end

        exec(memory, offset + 4, inputs, base_pos)

      @equals ->
        param1 = get_value(memory, offset + 1, param1_mode, base_pos)
        param2 = get_value(memory, offset + 2, param2_mode, base_pos)

        memory =
          if param1 == param2 do
            update_memory(memory, offset + 3, 1, param3_mode, base_pos)
          else
            update_memory(memory, offset + 3, 0, param3_mode, base_pos)
          end

        exec(memory, offset + 4, inputs, base_pos)

      @relative_base ->
        param1 = get_value(memory, offset + 1, param1_mode, base_pos)
        exec(memory, offset + 2, inputs, base_pos + param1)

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

defmodule Amplifier do
  use GenServer

  require Amplifier.Executor
  alias Amplifier.Executor

  # Client
  def start_link(name: name, memory: memory) do
    GenServer.start_link(__MODULE__, {name, memory}, name: name)
  end

  def push_input(name, inputs) when is_list(inputs) do
    GenServer.call(name, {:push_inputs, inputs})
  end

  def push_input(name, input) do
    GenServer.call(name, {:push_inputs, [input]})
  end

  def run(name) do
    GenServer.call(name, :run)
  end

  def exit(name) do
    GenServer.stop(name)
  end

  # Server
  def init({name, memory}) do
    {:ok, %{ets_name: setup_ets(name, memory)}}
  end

  def handle_call({:push_inputs, inputs}, _from, %{:ets_name => ets_name} = state) do
    prev_inputs = get_element_of_ets(ets_name, :inputs)
    set_element_of_ets(ets_name, :inputs, prev_inputs ++ inputs)

    {:reply, :ok, state}
  end

  def handle_call(:run, _from, %{:ets_name => ets_name} = state) do
    memory = get_element_of_ets(ets_name, :memory)
    offset = get_element_of_ets(ets_name, :offset)
    inputs = get_element_of_ets(ets_name, :inputs)

    case Executor.exec(memory, offset, inputs) do
      {:output, output, remain_inputs, updated_memory, next_offset} ->
        set_element_of_ets(ets_name, :memory, updated_memory)
        set_element_of_ets(ets_name, :inputs, remain_inputs)
        set_element_of_ets(ets_name, :offset, next_offset)

        {:reply, {:pause, output}, state}

      :exit ->
        {:reply, :exit, state}

      _ ->
        {:reply, :error, state}
    end
  end

  defp setup_ets(name, memory) do
    ets_name = String.to_atom("ets-#{name}")
    :ets.new(ets_name, [:set, :protected, :named_table])

    :ets.insert(ets_name, {:memory, memory})
    :ets.insert(ets_name, {:offset, 0})
    :ets.insert(ets_name, {:inputs, []})

    ets_name
  end

  defp get_element_of_ets(ets_name, key) do
    :ets.lookup(ets_name, key) |> Keyword.get(key)
  end

  defp set_element_of_ets(ets_name, key, value) do
    :ets.insert(ets_name, {key, value})
  end
end

defmodule Day9 do
  def part1(input) do
    name = :amplifier1
    memory = parse_input(input)

    Amplifier.start_link(name: name, memory: memory)
    Amplifier.push_input(name, 1)
    Amplifier.run(name)
    Amplifier.exit(name)
  end

  def part2(input) do
    name = :amplifier2
    memory = parse_input(input)

    Amplifier.start_link(name: name, memory: memory)
    Amplifier.push_input(name, 2)
    Amplifier.run(name)
    Amplifier.exit(name)
  end

  defp parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {val, i}, acc -> Map.put(acc, i, val) end)
  end
end

File.read!("input.txt")
|> tap(&Day9.part1/1)
|> tap(&Day9.part2/1)
