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

## Part 2
레지스터 `X`가 [스프라이트](https://en.wikipedia.org/wiki/Sprite_(computer_graphics))의 수평 위치를 제어하는 ​​것 같습니다. 구체적으로, 스프라이트의 너비는 3픽셀이고, 레지스터 `X`는 해당 스프라이트 **가운데**의 가로 위치를 설정합니다. (이 시스템에는 "수직 위치"와 같은 것이 없습니다. 스프라이트의 수평 위치가 CRT가 현재 그리는 위치에 픽셀을 배치하면, 해당 픽셀들이 그려집니다.)

CRT의 픽셀 수는 너비 40, 높이 6입니다. 이 CRT 화면은 왼쪽에서 오른쪽으로 픽셀의 맨 위 행을 그린 다음, 그 아래 행을 차례대로 그립니다. 각 행의 맨 왼쪽 픽셀은 좌표 `0`에 있고, 각 행의 맨 오른쪽 픽셀은 좌표 `39`에 있습니다.

CPU와 마찬가지로, CRT는 클럭 회로에 밀접하게 연결되어 있습니다. CRT는 **각 주기 동안 단일 픽셀**을 그립니다. 화면에 그려지는 픽셀을 `#`로 나타내면, 각 행의 첫 번째 픽셀과 마지막 픽셀이 그려지는 주기는 다음과 같습니다.

``` text
사이클   1 -> ######################################## <- 사이클  40
사이클  41 -> ######################################## <- 사이클  80
사이클  81 -> ######################################## <- 사이클 120
사이클 121 -> ######################################## <- 사이클 160
사이클 161 -> ######################################## <- 사이클 200
사이클 201 -> ######################################## <- 사이클 240
```

따라서 CPU 명령어들과 CRT 그리기 작업들의 타이밍을 신중하게 계산하여, 각 픽셀이 그려지는 순간 스프라이트가 표시되는지 여부를 결정할 수 있어야 합니다. 스프라이트의 3개 픽셀 중 하나가 현재 그려지는 픽셀이 되도록 스프라이트를 배치하면, 화면에 흰색 픽셀(`#`)이 생성됩니다. 그렇지 않으면 화면의 픽셀이 어두워 집니다.(`.`)

위의 더 큰 예시에서 처음 몇 픽셀은 다음과 같이 그려집니다.

``` text
Sprite position: ###.....................................

Start cycle   1: begin executing addx 15
During cycle  1: CRT draws pixel in position 0
Current CRT row: #

During cycle  2: CRT draws pixel in position 1
Current CRT row: ##
End of cycle  2: finish executing addx 15 (Register X is now 16)
Sprite position: ...............###......................

Start cycle   3: begin executing addx -11
During cycle  3: CRT draws pixel in position 2
Current CRT row: ##.

During cycle  4: CRT draws pixel in position 3
Current CRT row: ##..
End of cycle  4: finish executing addx -11 (Register X is now 5)
Sprite position: ....###.................................

Start cycle   5: begin executing addx 6
During cycle  5: CRT draws pixel in position 4
Current CRT row: ##..#

During cycle  6: CRT draws pixel in position 5
Current CRT row: ##..##
End of cycle  6: finish executing addx 6 (Register X is now 11)
Sprite position: ..........###...........................

Start cycle   7: begin executing addx -3
During cycle  7: CRT draws pixel in position 6
Current CRT row: ##..##.

During cycle  8: CRT draws pixel in position 7
Current CRT row: ##..##..
End of cycle  8: finish executing addx -3 (Register X is now 8)
Sprite position: .......###..............................

Start cycle   9: begin executing addx 5
During cycle  9: CRT draws pixel in position 8
Current CRT row: ##..##..#

During cycle 10: CRT draws pixel in position 9
Current CRT row: ##..##..##
End of cycle 10: finish executing addx 5 (Register X is now 13)
Sprite position: ............###.........................

Start cycle  11: begin executing addx -1
During cycle 11: CRT draws pixel in position 10
Current CRT row: ##..##..##.

During cycle 12: CRT draws pixel in position 11
Current CRT row: ##..##..##..
End of cycle 12: finish executing addx -1 (Register X is now 12)
Sprite position: ...........###..........................

Start cycle  13: begin executing addx -8
During cycle 13: CRT draws pixel in position 12
Current CRT row: ##..##..##..#

During cycle 14: CRT draws pixel in position 13
Current CRT row: ##..##..##..##
End of cycle 14: finish executing addx -8 (Register X is now 4)
Sprite position: ...###..................................

Start cycle  15: begin executing addx 13
During cycle 15: CRT draws pixel in position 14
Current CRT row: ##..##..##..##.

During cycle 16: CRT draws pixel in position 15
Current CRT row: ##..##..##..##..
End of cycle 16: finish executing addx 13 (Register X is now 17)
Sprite position: ................###.....................

Start cycle  17: begin executing addx 4
During cycle 17: CRT draws pixel in position 16
Current CRT row: ##..##..##..##..#

During cycle 18: CRT draws pixel in position 17
Current CRT row: ##..##..##..##..##
End of cycle 18: finish executing addx 4 (Register X is now 21)
Sprite position: ....................###.................

Start cycle  19: begin executing noop
During cycle 19: CRT draws pixel in position 18
Current CRT row: ##..##..##..##..##.
End of cycle 19: finish executing noop

Start cycle  20: begin executing addx -1
During cycle 20: CRT draws pixel in position 19
Current CRT row: ##..##..##..##..##..

During cycle 21: CRT draws pixel in position 20
Current CRT row: ##..##..##..##..##..#
End of cycle 21: finish executing addx -1 (Register X is now 20)
Sprite position: ...................###..................
```

프로그램이 완료될 때까지 실행하면 CRT가 다음 이미지를 생성합니다.

##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######.....

프로그램에서 제공하는 이미지를 렌더링합니다. CRT에 나타나는 8개의 대문자는 무엇입니까?