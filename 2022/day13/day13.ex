defmodule Day13 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.chunk_every(2)
    |> find_right_order_pair_index()
    |> Enum.sum()
    |> IO.inspect(label: "part1")
  end

  def part2(input) do
    divider_packets = [[[2]], [[6]]]

    input
    |> parse_input()
    |> Enum.concat(divider_packets)
    |> Enum.sort(&right_order?/2)
    |> calculate_decoder_key(divider_packets)
    |> IO.inspect(label: "part2")
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
  end

  defp parse_packet(packet) do
    packet
    |> String.graphemes()
    |> Enum.map(fn ele -> if ele in ["[", "]", ","], do: ele, else: String.to_integer(ele) end)
    |> Enum.reduce({[], nil}, fn ele, {result, cur} ->
      case ele do
        "," ->
          result = if cur == nil, do: result, else: put_nested_list(result, cur)

          {result, nil}

        "[" ->
          result = put_nested_list(result, [])

          {result, nil}

        "]" ->
          result =
            if cur == nil do
              put_nested_list(result, nil)
            else
              result |> put_nested_list(cur) |> put_nested_list(nil)
            end

          {result, nil}

        num ->
          cur = if cur == nil, do: num, else: cur * 10 + num

          {result, cur}
      end
    end)
    |> elem(0)
    |> remove_nil()
    |> hd()
    |> reverse_nested_list()
  end

  defp put_nested_list([], cur), do: [cur]

  defp put_nested_list(list, cur) do
    [ele | remain] = list

    cond do
      is_list(ele) and not ended_list?(ele) -> [put_nested_list(ele, cur) | remain]
      is_list(ele) -> [cur | list]
      true -> [cur | list]
    end
  end

  defp ended_list?([nil | _]), do: true
  defp ended_list?(_list), do: false

  defp remove_nil(list) do
    list
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&if is_list(&1), do: remove_nil(&1), else: &1)
  end

  defp reverse_nested_list(list) do
    list
    |> Enum.reverse()
    |> Enum.map(&if is_list(&1), do: reverse_nested_list(&1), else: &1)
  end

  defp find_right_order_pair_index(pairs) do
    pairs
    |> Enum.with_index(1)
    |> Enum.filter(fn {[left, right], _index} -> right_order?(left, right) end)
    |> Enum.map(&elem(&1, 1))
  end

  defp right_order?([], []), do: :cont
  defp right_order?([], _right), do: true
  defp right_order?(_left, []), do: false

  defp right_order?(left, right) do
    [l_val | l_remain] = left
    [r_val | r_remain] = right

    cond do
      is_integer(l_val) and is_integer(r_val) ->
        if l_val == r_val,
          do: right_order?(l_remain, r_remain),
          else: l_val < r_val

      is_integer(l_val) ->
        case right_order?([l_val], r_val) do
          :cont -> right_order?(l_remain, r_remain)
          result -> result
        end

      is_integer(r_val) ->
        case right_order?(l_val, [r_val]) do
          :cont -> right_order?(l_remain, r_remain)
          result -> result
        end

      true ->
        case right_order?(l_val, r_val) do
          :cont -> right_order?(l_remain, r_remain)
          result -> result
        end
    end
  end

  defp calculate_decoder_key(packets, divider_packets) do
    packets
    |> Enum.with_index(1)
    |> Enum.filter(fn {packet, _index} -> Enum.any?(divider_packets, &(&1 == packet)) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.product()
  end
end

File.read!("input.txt")
|> tap(&Day13.part1/1)
|> tap(&Day13.part2/1)
