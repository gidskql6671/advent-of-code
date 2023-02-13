defmodule Day16 do
  @base_pattern [0, 1, 0, -1]

  def part1(input) do
    input
    |> parse_input()
    |> simulate()
    |> Enum.take(8)
    |> Enum.join()
    |> IO.inspect(label: "part1")
  end

  # NOTE 인풋 길이 650 -> 10,000을 곱하면 6,500,000
  # 단순히 100번 단계를 돌려버리면 시간이 굉장히 오래 걸림. 다른 알고리즘을 찾아야 함.
  # 핵심 아이디어
  # 적용되는 패턴의 특성상, 해당 요소 이전의 인풋 요소 값들은 모두 무시됨.
  # 인풋의 길이가 4라고 치면
  # - 첫번째 원소의 패턴은 [1, 0, -1, 0]
  # - 두번째 원소의 패턴은 [0, 1, 1, 0]
  # - 세번째 원소의 패턴은 [0, 0, 1, 1]
  # - 네번째 원소의 패턴은 [0, 0, 0, 1]
  # 위 예시에서 보이듯, 자기 요소 이전의 인풋 요소 값들은 모두 0이 곱해져 사라진다.
  # 또한, 입력 리스트의 절반 위치를 넘기는 요소부터는 자기를 포함한 이후 요소 값들을 더하는 연산이다.
  # 그러면 단순히 리스트를 뒤집어서 거꾸로 누적합을 더해가며 계산하면, 절반 위치를 넘기는 요소부터는 계산이 바로 된다.
  # ex) 마지막 원소는 자신의 값 (A)
  #     마지막에서 두번째 원소는 자신의 값 + A (B)
  #     마지막에서 세번째 원소는 자신의 값 + B
  # 다행히도 퍼즐 입력의 오프셋은 입력 리스트의 절반 길이를 넘기니, 이것을 이용할 수 있다.
  def part2(input) do
    input
    |> parse_input()
    |> simulate_with_prefix_sum()
    |> Enum.join()
    |> IO.inspect(label: "part1")
  end

  defp parse_input(input) do
    input
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end

  defp simulate(input), do: do_simulate(input, length(input), 0)

  defp do_simulate(input, _, 100), do: input

  defp do_simulate(input, input_length, phase) do
    1..input_length
    |> Enum.map(fn pos ->
      pattern = make_pattern(input_length, pos)

      input
      |> apply_pattern(pattern)
      |> abs()
      |> rem(10)
    end)
    |> do_simulate(input_length, phase + 1)
  end

  defp make_pattern(length, dup_count) do
    @base_pattern
    |> Enum.flat_map(&List.duplicate(&1, dup_count))
    |> Stream.cycle()
    |> Enum.take(length + 1)
    |> tl()
  end

  defp apply_pattern(list1, list2) do
    Enum.zip(list1, list2)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

  defp simulate_with_prefix_sum(input) do
    skip_count = input |> Enum.take(7) |> Enum.join() |> String.to_integer()

    input
    |> Stream.cycle()
    |> Enum.take(Enum.count(input) * 10_000)
    |> Enum.drop(skip_count)
    |> Enum.reverse()
    |> do_simulate_with_prefix_sum(0)
    |> Enum.reverse()
    |> Enum.take(8)
  end

  defp do_simulate_with_prefix_sum(input, 100), do: input

  defp do_simulate_with_prefix_sum(input, phase) do
    input
    |> Enum.scan(0, fn ele, prev -> rem(ele + prev, 10) end)
    |> do_simulate_with_prefix_sum(phase + 1)
  end
end

File.read!("input.txt")
|> tap(&Day16.part1/1)
|> tap(&Day16.part2/1)
