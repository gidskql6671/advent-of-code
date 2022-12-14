# Day 10: 브라운관 (Cathode-Ray Tube)
<https://adventofcode.com/2022/day/10>

## Part 1
당신은 밧줄을 피하고, 강에 뛰어들고, 해안으로 수영합니다.

엘프들은 강 상류에서 다시 만나자고 소리쳤지만, 강물이 너무 시끄러워 그들이 말하는 것을 정확히 알 수 없었습니다. 그들은 다리를 건너고 시야에서 사라집니다.

이와 같은 상황을 고려했기에 엘프들은 휴대용 장치의 통신 시스템의 작동을 고치는 것을 우선시했던 것이었습니다. 당신은 장치를 가방에서 꺼냈지만, 화면의 큰 균열에서 천천히 빠져나가는 물의 양을 볼 때 화면을 바로 사용하기는 힘들 것 같습니다.

대신, 당신은 장치의 비디오 시스템을 대체하도록 설계할 수 있습니다! 정밀한 **클럭 회로**에 의해 구동되는 일종의 [브라운관](https://en.wikipedia.org/wiki/Cathode-ray_tube) 화면과 간단한 CPU의 한 종류인 것 같습니다. 클럭 회로는 일정한 속도로 신호(tick)를 보내는데, 각 신호를 **사이클**이라고 합니다 .

CPU에서 보내는 신호를 파악해봅시다. CPU는 값 `1`로 시작하는 단일 레지스터 `x`가 있습니다. CPU는 두 가지 명령어만 지원합니다.

- `addx V`는 완료하는 데 **2 사이클**이 걸립니다 . 2 사이클 **후에**, `X` 레지스터의 값은 `V`만큼 증가합니다. (`V`는 음수가 될 수 있습니다.)
- `noop`은 완료하는 데 **1 사이클**이 걸립니다. 다른 효과는 없습니다.

CPU는 프로그램(퍼즐 입력)의 명령들을 사용하여, 화면에 무엇을 그릴지 알려줍니다.

다음과 같은 작은 프로그램을 같이 봅시다.

``` text
noop
addx 3
addx -5
```

이 프로그램의 실행은 다음과 같이 진행됩니다.

- 첫 번째 사이클이 시작되면, `noop` 명령어가 실행을 시작합니다. 첫 번째 사이클 동안, `X`는 `1`입니다. 첫 번째 사이클 후에, `noop` 명령어는 아무 작업도 하지 않고 실행을 완료합니다.
- 두 번째 사이클이 시작되면, `addx 3` 명령어가 실행을 시작합니다. 두 번째 사이클 동안, `X`는 여전히 `1`입니다.
- 세 번째 사이클 동안, X는 여전히 `1`입니다. 세 번째 사이클 후에, `addx 3` 명령어는 `X`를 `4`로 설정하며 실행을 완료합니다.
- 네 번째 사이클이 시작되면, `addx -5` 명령어가 실행을 시작합니다. 네 번째 사이클 동안, `X`는 여전히 `4`입니다.
- 다섯 번째 사이클 동안, `X`는 여전히 `4`입니다. 다섯 번째 사이클 후, `addx -5` 명령어는 `X`를 `-1`로 설정하며 실행을 완료합니다.

실행 전반에 걸쳐 레지스터 `X`의 값을 살펴봄으로써 무언가를 배울 수 있을 것 같습니다. 지금은 20번째 사이클과 그 ​​이후 40사이클마다(즉, 20번째, 60번째, 100번째, 140번째, 180번째 및 220번째 사이클 마다) **신호 강도**(레지스터 `X`의 값과 사이클 번호를 곱한 값)를 계산해봅시다.

예를 들어 다음과 같은 더 큰 프로그램을 사용해봅시다.

``` text
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
```

구해야하는 신호 강도는 다음과 같이 계산할 수 있습니다.

- 20번째 사이클 동안, 레지스터 `X`의 값 `21`이므로 신호 강도는 20 * 21 = **420**입니다. (20번째 사이클은 두 번째 `addx -1`이 실행될 때이기에, 레지스터 `X`의 값은 시작 값 `1`에서부터 해당 지점까지 다른 모든 `addx`의 값을 더한 값입니다. 1 + 15 - 11 + 6 - 3 + 5 - 1 - 8 + 13 + 4 = 21)
- 60번째 사이클 동안, 레지스터 `X`의 값은 `19`이므로 신호 강도는 60 * 19 = **1140**입니다.
- 100번째 사이클 동안, 레지스터 `X`의 값은 `18`이므로 신호 강도는 100 * 18 = 1800입니다.
- 140번째 사이클 동안, 레지스터 `X`의 값은 `21`이므로 신호 강도는 140 * 21 = 2940입니다.
- 180번째 사이클 동안, 레지스터 `X`의 값은 `16`이므로 신호 강도는 180 * 16 = 2880입니다.
- 220번째 사이클 동안, 레지스터 `X`의 값은 `18`이므로 신호 강도는 220 * 18 = 3960입니다.

이 신호 강도들의 합은 `13140`입니다.

20번째, 60번째, 100번째, 140번째, 180번째 및 220번째 사이클 동안의 신호 강도를 찾습니다. 이 여섯 가지 신호 강도의 합은 얼마입니까?
