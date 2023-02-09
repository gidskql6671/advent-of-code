# Day 14: 우주 화학양론 (Space Stoichiometry)
<https://adventofcode.com/2019/day/14>

## Part 1
토성의 고리에 도착할 때 쯤, 배의 **연료 부족** 표시등이 켜졌습니다. 가지고 있는 연료는 없지만, 토성의 고리에는 원재료(raw material)들이 충분히 많이 있습니다. 우리 배의 **나노공장**은 일련의 공정을 통해 원재료를 연료로 만들 수 있습니다.

당신은 나노공장에 이 공정과 관련된 **반응들**의 목록(퍼즐 입력)을 작성하도록 요청했습니다. 모든 반응은 일정량의 **화학물질들**을 투입하면, **한 종류의 화학물질** 일정량을 생산합니다. `ORE`를 제외한 모든 **화학 물질**들은 정확히 한가지 반응에 의해서 생성됩니다. 유일한 예외인 `ORE`는 전체 공정에 투입되는 원재료이며, 반응에 의해서 생성되지 않습니다.

당신은 `FUEL` 한 개를 만들기 위해 얼마나 많은 양의 `ORE`가 필요한지 알아내야 합니다.

목록에 적힌 각 반응에는 필요한 입력 화학물질의 양과 생성되는 출력 화학물질의 양이 적혀있습니다. 반응은 부분적으로 실행될 수 없기에, 우리는 화학물질량의 정수 배수만 사용할 수 있습니다. (단, 쓰고 남은 화학물질이 생기는 것은 괜찮습니다.) 예를 들어, 반응 `1A, 2B, 3C => 2D`는 정확히 `A` 1개, `B` 2개, `C` 3개를 소비함으로써 정확히 2개의 `D`가 생긴다는 것을 의미합니다. 예를 들어, `A` 5개, `B` 10개, `C` 15개를 소비하여, 10개의 `D`를 만들 수 있다.

나노공장이 다음과 같은 반응 목록을 만든다고 가정합시다.

``` text
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL
```

앞에서 2개의 반응은 오직 `ORE`만 입력으로 사용합니다. 이것은 화학물질 `A`를 원하는 만큼 생산할 수 있다는 것을 의미합니다. (매번 `ORE` 10개를 소모해서, `A` 10개를 만든다.) 마찬가지로 화학물질 `B`도 당신이 원하는 만큼 생산할 수 있습니다. (매번 `ORE` 1개를 소모해서, `B` 1개를 만든다.). 이 예시에서 1개의 `FUEL`을 만들기 위해 총 **31**개의 `ORE`가 필요합니다. `ORE` 1개는 `B` 1개를 만들기 위해 필요합니다. 또, 30개의 `ORE`는 `B`를 `C`로, `C`를 `D`로, `D`를 `E`로, 마지막으로 `E`를 `FUEL`로 변환하는 반응에 필요한 28개의 `A`(버려지는 2개의 여분 `A`와 함께)를 만들기 위해 필요합니다. 28개가 아닌 30개의 `A`를 만드는 이유는 `A`를 만드는 반응의 단위가 10씩 증가하기 때문입니다.

이번에는 다음과 같은 반응 목록을 가진다고 가정해봅시다.

``` text
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL
```

위 반응들의 목록은 1개의 `FUEL`을 만들기 위해 165개의 `ORE`가 필요합니다.

- `ORE` 45개를 사용해서, `A` 10개를 만듬
- `ORE` 64개를 사용해서, `B` 24개를 만듬
- `ORE` 56개를 사용해서, `C` 40개를 만듬
- `A` 6개, `B` 8개를 사용해서, `AB` 2개를 만듬
- `B` 15개, `C` 21개를 사용해서, `BC` 3개를 만듬
- `C` 16개, `A` 4개를 사용해서, `CA` 4개를 만듬
- `AB` 2개, `BC` 3개, `CA` 4개를 사용해서, `FUEL` 1개를 만듬

더 큰 예시를 봅시다.

- 1개의 `FUEL`을 만들기 위해 **13312**개의 `ORE`가 필요합니다.

``` text
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
```

- 1개의 `FUEL`을 만들기 위해 **180697**개의 `ORE`가 필요합니다.

``` text
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF
```

- 1개의 `FUEL`을 만들기 위해 **2210736**개의 `ORE`가 필요합니다.

``` text
171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX
```

퍼즐 입력으로 반응 목록이 주어졌을 때, 정확히 1개의 FUEL를 생성하는데 필요한 ORE의 최소 개수는 얼마입니까?

## Part 2
한동안 `ORE`를 수집하니 1조(**1,000,000,000,000**)개의 `ORE`를 모을 수 있었습니다.

1조개의 `ORE`를 가진 채로 위 예시를 다시 봅시다.

- `FUEL` 1개당 13312개의 `ORE`가 필요했던 예시에서는 82892753개의 `FUEL`를 생산할 수 있습니다.
- `FUEL` 1개당 180697개의 `ORE`가 필요했던 예시에서는 5586022개의 `FUEL`를 생산할 수 있습니다.
- `FUEL` 1개당 2210736개의 `ORE`가 필요했던 예시에서는 460664개의 `FUEL`를 생산할 수 있습니다.

1조개의 광석이 주어질 때, 생산할 수 있는 `FUEL`는 최대 몇개입니까?