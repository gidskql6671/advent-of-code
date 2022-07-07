defmodule Day8.Part1 do
  def run(encoded_image, height, width) do
    layer =
      encoded_image
      |> decode(height, width)
      |> find_layer_contain_fewest_0()

    count_digit(layer, 1) * count_digit(layer, 2)
  end

  defp decode(encoded_image, height, width) do
    encoded_image
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(height * width)
    |> Enum.map(&Enum.chunk_every(&1, width))
  end

  defp find_layer_contain_fewest_0(layers) do
    layers
    |> Enum.map(&count_digit(&1, 0))
    |> Enum.zip(layers)
    |> Enum.min_by(fn {count, _} -> count end)
    |> elem(1)
  end

  defp count_digit(layer, digit) do
    layer
    |> Enum.flat_map(& &1)
    |> Enum.count(& &1 == digit)
  end
end


File.read!("input.txt")
|> tap(&(Day8.Part1.run(&1, 6, 25) |> IO.inspect(label: "Part 1")))
