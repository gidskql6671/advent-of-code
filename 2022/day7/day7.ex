defmodule Day7 do
  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> find_directories_size_less_than(100_000)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
  end

  defp simulate(terminal, storage \\ %{"/" => %{}}, cur_dir \\ ["/"])
  defp simulate([], storage, _cur_dir), do: storage

  defp simulate(terminal, storage, cur_dir) do
    [line | remain] = terminal

    case line do
      "$ cd " <> dir ->
        simulate(remain, storage, change_dir(cur_dir, dir))

      "$ ls" ->
        {ls_result, remain} =
          Enum.split_while(remain, fn
            "$ " <> _ -> false
            _ -> true
          end)

        storage = Enum.reduce(ls_result, storage, &apply_log_to_storage(&1, &2, cur_dir))

        simulate(remain, storage, cur_dir)
    end
  end

  defp change_dir(_cur_dir, "/"), do: ["/"]
  defp change_dir(cur_dir, ".."), do: Enum.drop(cur_dir, -1)
  defp change_dir(cur_dir, dir), do: cur_dir ++ [dir]

  defp apply_log_to_storage(log, storage, cur_dir) do
    log
    |> String.split(" ")
    |> case do
      ["dir", dir_name] ->
        put_in(storage, cur_dir ++ [dir_name], %{})

      [size, file_name] ->
        put_in(storage, cur_dir ++ [file_name], String.to_integer(size))
    end
  end

  defp find_directories_size_less_than(storage, size) do
    storage
    |> calculate_directory_size()
    |> elem(0)
    |> Enum.filter(fn {_k, v} -> v <= size end)
  end

  defp calculate_directory_size(storage, cur_dir \\ ["/"]) do
    cur_directory = get_in(storage, cur_dir)
    cur_directory_name = cur_dir |> Enum.take(-1) |> hd()

    %{directories: directories, files: files} =
      Enum.reduce(cur_directory, %{directories: [], files: []}, fn entity, acc ->
        {key, val} = entity

        case val do
          %{} -> Map.update!(acc, :directories, &[key | &1])
          _ -> Map.update!(acc, :files, &[val | &1])
        end
      end)

    {result, directories_size} =
      directories
      |> Enum.map(&calculate_directory_size(storage, cur_dir ++ [&1]))
      |> Enum.reduce({[], 0}, fn {sub_result, sub_size}, {result, size_sum} ->
        {result ++ sub_result, size_sum + sub_size}
      end)

    total_size = directories_size + Enum.sum(files)

    {[{cur_directory_name, total_size} | result], total_size}
  end
end

File.read!("input.txt")
|> tap(&Day7.part1/1)
