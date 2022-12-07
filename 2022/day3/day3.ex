defmodule Day3 do
  def part1(input) do
    input
    |> parse_input()
    |> find_dup_items()
    |> Enum.map(&calculate_type_score/1)
    |> Enum.sum()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      {first, second} = String.split_at(line, div(String.length(line), 2))

      {String.graphemes(first), String.graphemes(second)}
    end)
  end

  defp find_dup_items(rucksacks) do
    rucksacks
    |> Enum.map(&find_dup_item/1)
  end

  defp find_dup_item({first_compartment, second_compartment} = _rucksack) do
    uniq_first_compartment = Enum.uniq(first_compartment)
    uniq_second_compartment = Enum.uniq(second_compartment)
    all_types_compartments = uniq_first_compartment ++ uniq_second_compartment

    hd(all_types_compartments -- Enum.uniq(all_types_compartments))
  end

  defp calculate_type_score(type) do
    ascii = :binary.first(type)

    cond do
      ?a <= ascii and ascii <= ?z -> ascii - ?a + 1
      true -> ascii - ?A + 27
    end
  end
end

File.read!("input.txt")
|> tap(&Day3.part1/1)
