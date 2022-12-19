# Day 11: Monkey in the Middle
<https://adventofcode.com/2022/day/11>

## Part 1
강 상류로 올라가기 시작할 때, 당신은 배낭이 기억하는 것보다 훨씬 가볍다는 것을 깨닫게 됩니다. 바로 그때, 가방의 물건 중 하나가 머리 위로 날아갑니다. 원숭이가 잃어버린 물건을 [서로 던지며 놀고 있습니다](https://en.wikipedia.org/wiki/Keep_away)!

물건을 되찾으려면 원숭이가 물건을 던질 위치를 예측해야 합니다. 주의 깊게 관찰한 후, 당신이 해당 물건에 대해 얼마나 걱정하는지에 따라 원숭이가 다르게 행동한다는 것을 알게 됩니다.

당신은 각 원숭이가 현재 가지고 있는 물건, 해당 물건에 대해 당신이 얼마나 걱정하는지, 당신이 얼마나 걱정하는지에 따라 원숭이가 결정을 내리는 방법에 대한 몇 가지 메모(퍼즐 입력)를 작성했습니다. 예를 들어:  

``` text
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
```

각 원숭이는 여러 속성을 가지고 있습니다.

- `Starting items`은 원숭이가 현재 들고 있는 물건에 대한 걱정 수준을 검사할 순서대로 나열합니다.
- `Operation`은 원숭이가 물건을 검사할 때 당신의 걱정 수준이 어떻게 변하는지 보여줍니다. (`new = old * 5` Operation은 원숭이가 물건을 검사한 후의 걱정 수준이 검사 전의 걱정 수준의 5배인 것을 의미합니다.)
- `Test`는 원숭이가 당신의 걱정 수준을 사용하여 다음 물건을 던질 위치를 결정하는 방법을 보여줍니다.
  - `If true`는 `Test`가 참인 경우 물건에 어떤 일이 발생하는지 보여줍니다.
  - `If false`는 `Test`가 거짓 인 경우 물건에 어떤 일이 발생하는지 보여줍니다.

각 원숭이가 물건을 검사한 후 당신의 걱정 수준을 테스트하기 전에, 당신은 원숭이가 검사한 물건이 손상되지 않았다는 안도감에 걱정 수준을 **3으로 나누고** 가장 가까운 정수로 내림합니다.

원숭이들은 번갈아 가며 물건을 검사하고 던집니다. 한 마리의 원숭이가 차례가 되면 들고 있는 모든 물건을 한 번에 하나씩 나열된 순서대로 검사하고 던집니다. 원숭이 `0`이 먼저 시작하고, 그 다음이 원숭이 `1`, 이후 차례대로 각각의 원숭이들이 자기 차례가 되면 시작합니다. 각 원숭이들의 차례가 한 바퀴 도는 것을 **라운드**라고 합니다.

원숭이가 다른 원숭이에게 물건을 던지면, 해당 물건은 받는 원숭이의 물건 목록 맨 끝으로 이동합니다. 그러니 물건 없이 라운드를 시작한 원숭이도 자기 차례가 왔을 때 물건들을 검사하고 던질 수도 있습니다. 원숭이가 차례를 시작할 때 소지하고 있는 물건이 없으면 차례가 종료됩니다.

위의 예에서 첫 번째 라운드는 다음과 같이 진행됩니다.

``` text
Monkey 0:
  Monkey inspects an item with a worry level of 79.
    Worry level is multiplied by 19 to 1501.
    Monkey gets bored with item. Worry level is divided by 3 to 500.
    Current worry level is not divisible by 23.
    Item with worry level 500 is thrown to monkey 3.
  Monkey inspects an item with a worry level of 98.
    Worry level is multiplied by 19 to 1862.
    Monkey gets bored with item. Worry level is divided by 3 to 620.
    Current worry level is not divisible by 23.
    Item with worry level 620 is thrown to monkey 3.
Monkey 1:
  Monkey inspects an item with a worry level of 54.
    Worry level increases by 6 to 60.
    Monkey gets bored with item. Worry level is divided by 3 to 20.
    Current worry level is not divisible by 19.
    Item with worry level 20 is thrown to monkey 0.
  Monkey inspects an item with a worry level of 65.
    Worry level increases by 6 to 71.
    Monkey gets bored with item. Worry level is divided by 3 to 23.
    Current worry level is not divisible by 19.
    Item with worry level 23 is thrown to monkey 0.
  Monkey inspects an item with a worry level of 75.
    Worry level increases by 6 to 81.
    Monkey gets bored with item. Worry level is divided by 3 to 27.
    Current worry level is not divisible by 19.
    Item with worry level 27 is thrown to monkey 0.
  Monkey inspects an item with a worry level of 74.
    Worry level increases by 6 to 80.
    Monkey gets bored with item. Worry level is divided by 3 to 26.
    Current worry level is not divisible by 19.
    Item with worry level 26 is thrown to monkey 0.
Monkey 2:
  Monkey inspects an item with a worry level of 79.
    Worry level is multiplied by itself to 6241.
    Monkey gets bored with item. Worry level is divided by 3 to 2080.
    Current worry level is divisible by 13.
    Item with worry level 2080 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 60.
    Worry level is multiplied by itself to 3600.
    Monkey gets bored with item. Worry level is divided by 3 to 1200.
    Current worry level is not divisible by 13.
    Item with worry level 1200 is thrown to monkey 3.
  Monkey inspects an item with a worry level of 97.
    Worry level is multiplied by itself to 9409.
    Monkey gets bored with item. Worry level is divided by 3 to 3136.
    Current worry level is not divisible by 13.
    Item with worry level 3136 is thrown to monkey 3.
Monkey 3:
  Monkey inspects an item with a worry level of 74.
    Worry level increases by 3 to 77.
    Monkey gets bored with item. Worry level is divided by 3 to 25.
    Current worry level is not divisible by 17.
    Item with worry level 25 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 500.
    Worry level increases by 3 to 503.
    Monkey gets bored with item. Worry level is divided by 3 to 167.
    Current worry level is not divisible by 17.
    Item with worry level 167 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 620.
    Worry level increases by 3 to 623.
    Monkey gets bored with item. Worry level is divided by 3 to 207.
    Current worry level is not divisible by 17.
    Item with worry level 207 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 1200.
    Worry level increases by 3 to 1203.
    Monkey gets bored with item. Worry level is divided by 3 to 401.
    Current worry level is not divisible by 17.
    Item with worry level 401 is thrown to monkey 1.
  Monkey inspects an item with a worry level of 3136.
    Worry level increases by 3 to 3139.
    Monkey gets bored with item. Worry level is divided by 3 to 1046.
    Current worry level is not divisible by 17.
    Item with worry level 1046 is thrown to monkey 1.
```

1라운드 후 원숭이는 다음과 같은 걱정 수준을 가지고 있는 물건들을 들고 있습니다.

``` text
Monkey 0: 20, 23, 27, 26
Monkey 1: 2080, 25, 167, 207, 401, 1046
Monkey 2: 
Monkey 3: 
```

원숭이 2와 3은 라운드가 끝날 때 어떤 물건도 들고 있지 않습니다. 둘 다 라운드 동안 물건들을 검사하고 라운드가 끝나기 전에 모두 던졌습니다.

이 프로세스는 몇 라운드 더 계속됩니다. 

``` text 
After round 2, the monkeys are holding items with these worry levels:
Monkey 0: 695, 10, 71, 135, 350
Monkey 1: 43, 49, 58, 55, 362
Monkey 2: 
Monkey 3: 

After round 3, the monkeys are holding items with these worry levels:
Monkey 0: 16, 18, 21, 20, 122
Monkey 1: 1468, 22, 150, 286, 739
Monkey 2: 
Monkey 3: 

After round 4, the monkeys are holding items with these worry levels:
Monkey 0: 491, 9, 52, 97, 248, 34
Monkey 1: 39, 45, 43, 258
Monkey 2: 
Monkey 3: 

After round 5, the monkeys are holding items with these worry levels:
Monkey 0: 15, 17, 16, 88, 1037
Monkey 1: 20, 110, 205, 524, 72
Monkey 2: 
Monkey 3: 

After round 6, the monkeys are holding items with these worry levels:
Monkey 0: 8, 70, 176, 26, 34
Monkey 1: 481, 32, 36, 186, 2190
Monkey 2: 
Monkey 3: 

After round 7, the monkeys are holding items with these worry levels:
Monkey 0: 162, 12, 14, 64, 732, 17
Monkey 1: 148, 372, 55, 72
Monkey 2: 
Monkey 3: 

After round 8, the monkeys are holding items with these worry levels:
Monkey 0: 51, 126, 20, 26, 136
Monkey 1: 343, 26, 30, 1546, 36
Monkey 2: 
Monkey 3: 

After round 9, the monkeys are holding items with these worry levels:
Monkey 0: 116, 10, 12, 517, 14
Monkey 1: 108, 267, 43, 55, 288
Monkey 2: 
Monkey 3: 

After round 10, the monkeys are holding items with these worry levels:
Monkey 0: 91, 16, 20, 98
Monkey 1: 481, 245, 22, 26, 1092, 30
Monkey 2: 
Monkey 3: 

...

After round 15, the monkeys are holding items with these worry levels:
Monkey 0: 83, 44, 8, 184, 9, 20, 26, 102
Monkey 1: 110, 36
Monkey 2: 
Monkey 3: 

...

After round 20, the monkeys are holding items with these worry levels:
Monkey 0: 10, 12, 14, 26, 34
Monkey 1: 245, 93, 53, 199, 115
Monkey 2: 
Monkey 3: 
```

한 번에 모든 원숭이를 쫓는 것은 불가능합니다. 물건을 되찾고 싶다면 **가장 활동적인 원숭이 두 마리**에 집중해야 합니다. 각 원숭이가 20 라운드 동안 **물건을 검사 하는 총 횟수**를 헤아리세요.

``` text
Monkey 0 inspected items 101 times.
Monkey 1 inspected items 95 times.
Monkey 2 inspected items 7 times.
Monkey 3 inspected items 105 times.
```

이 예에서 가장 활동적인 두 원숭이는 물건을 `101`번, `105`번 검사했습니다. 이 원숭이들의 **속임수(monkey business)** 수준은 두 값을 곱하여 찾을 수 있습니다. (`10605`)

20 라운드 동안 검사한 물건의 수를 세어 추적할 원숭이를 파악합니다. 20 라운드 뒤의 추적할 원숭이들의 속임수 수준은 몇 입니까?

## Part 2
당신은 물건을 되돌려받지 못할까 걱정되기 시작합니다. 이 걱정때문에, 이제는 더 이상 원숭이의 검사가 물건을 손상시키지 않았다는 **안도감이 걱정 수준을 3으로 나누지 않게 되었습니다.**

불행하게도, 그 안도감이 당신의 걱정 수준이 **터무니없는 수준**에 도달하는 것을 막는 전부였습니다. 당신은 이제 **당신의 걱정 수준을 관리할 수 있는 다른 방법**을 찾아야 합니다.

원숭이들이 던지는 속도를 보니, 당신은 이 원숭이들이 **매우 오랫동안** 놀이를 진행할 수 있을 것 같습니다. 아마 `10000` 라운드 정도요!

이 새로운 규칙을 적용하여 10000 라운드 후의 속임수 수준을 파악해봅시다. 위와 동일한 예를 사용하겠습니다.

``` text
== After round 1 ==
Monkey 0 inspected items 2 times.
Monkey 1 inspected items 4 times.
Monkey 2 inspected items 3 times.
Monkey 3 inspected items 6 times.

== After round 20 ==
Monkey 0 inspected items 99 times.
Monkey 1 inspected items 97 times.
Monkey 2 inspected items 8 times.
Monkey 3 inspected items 103 times.

== After round 1000 ==
Monkey 0 inspected items 5204 times.
Monkey 1 inspected items 4792 times.
Monkey 2 inspected items 199 times.
Monkey 3 inspected items 5192 times.

== After round 2000 ==
Monkey 0 inspected items 10419 times.
Monkey 1 inspected items 9577 times.
Monkey 2 inspected items 392 times.
Monkey 3 inspected items 10391 times.

== After round 3000 ==
Monkey 0 inspected items 15638 times.
Monkey 1 inspected items 14358 times.
Monkey 2 inspected items 587 times.
Monkey 3 inspected items 15593 times.

== After round 4000 ==
Monkey 0 inspected items 20858 times.
Monkey 1 inspected items 19138 times.
Monkey 2 inspected items 780 times.
Monkey 3 inspected items 20797 times.

== After round 5000 ==
Monkey 0 inspected items 26075 times.
Monkey 1 inspected items 23921 times.
Monkey 2 inspected items 974 times.
Monkey 3 inspected items 26000 times.

== After round 6000 ==
Monkey 0 inspected items 31294 times.
Monkey 1 inspected items 28702 times.
Monkey 2 inspected items 1165 times.
Monkey 3 inspected items 31204 times.

== After round 7000 ==
Monkey 0 inspected items 36508 times.
Monkey 1 inspected items 33488 times.
Monkey 2 inspected items 1360 times.
Monkey 3 inspected items 36400 times.

== After round 8000 ==
Monkey 0 inspected items 41728 times.
Monkey 1 inspected items 38268 times.
Monkey 2 inspected items 1553 times.
Monkey 3 inspected items 41606 times.

== After round 9000 ==
Monkey 0 inspected items 46945 times.
Monkey 1 inspected items 43051 times.
Monkey 2 inspected items 1746 times.
Monkey 3 inspected items 46807 times.

== After round 10000 ==
Monkey 0 inspected items 52166 times.
Monkey 1 inspected items 47830 times.
Monkey 2 inspected items 1938 times.
Monkey 3 inspected items 52013 times.
```

10000 라운드 후, 가장 활동적인 두 원숭이는 물건을 52166번, 52013번 검사했습니다. 이것들을 곱하면, 속임수 수준은 이제 `2713310158`이 됩니다.

각 물건을 검사한 후 걱정 수준을 더 이상 3으로 나누지 않습니다. 당신은 이제 걱정 수준을 관리할 수 있는 다른 방법을 찾아야 합니다. 퍼즐 입력의 초기 상태에서 다시 시작하여, 10000 라운드 후의 속임수 수준은 몇 인가요?