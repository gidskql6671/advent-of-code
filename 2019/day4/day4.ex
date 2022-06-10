defmodule Day4.Part1 do
  def run(from, to) do
    from..to
    |> Enum.filter(fn val -> monotone_increasing?(val) and adjacent_same?(val) end)
    |> Enum.count()
  end

  defp monotone_increasing?(number) when is_number(number),
    do: monotone_increasing?("#{number}")

  defp monotone_increasing?(number) do
    number
    |> String.graphemes()
    |> Enum.reduce_while(-1, fn
      val, prev when prev > val -> {:halt, false}
      val, _prev -> {:cont, val}
    end)
    |> case do
      false -> false
      _ -> true
    end
  end

  defp adjacent_same?(number) when is_number(number),
    do: adjacent_same?("#{number}")

  defp adjacent_same?(number) do
    number
    |> String.graphemes()
    |> Enum.reduce_while(-1, fn
      val, val -> {:halt, true}
      val, _prev -> {:cont, val}
    end)
    |> case do
      true -> true
      _ -> false
    end
  end
end

[from, to] =
  File.read!("input.txt")
  |> String.split("-", trim: true)
  |> Enum.map(&String.to_integer/1)

Day4.Part1.run(from, to) |> IO.inspect()
