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
    |> Enum.count(&(&1 == digit))
  end
end

defmodule Day8.Part2 do
  def run(encoded_image, height, width) do
    encoded_image
    |> decode_image(height, width)
    |> render_image(height, width)
    |> list_to_string()
  end

  defp decode_image(encoded_image, height, width) do
    encoded_image
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(height * width)
    |> Enum.map(&Enum.chunk_every(&1, width))
  end

  defp render_image(layers, height, width) do
    for row <- 0..(height - 1) do
      for col <- 0..(width - 1) do
        layers
        |> Enum.map(fn layer -> layer |> Enum.at(row) |> Enum.at(col) end)
        |> Enum.find(&(&1 < 2))
      end
    end
  end

  defp list_to_string(list) do
    Enum.reduce(list, "", fn row, result ->
      line =
        Enum.reduce(row, "", fn ele, acc ->
          if ele == 0, do: acc <> "□", else: acc <> "■"
        end)

      result <> "\n" <> line
    end)
  end
end

File.read!("input.txt")
|> tap(&(Day8.Part1.run(&1, 6, 25) |> IO.inspect(label: "Part 1")))
|> tap(&(Day8.Part2.run(&1, 6, 25) |> IO.puts()))
