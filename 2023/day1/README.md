# Day 1: 트레뷰셋?! (Trebuchet?!)
<https://adventofcode.com/2023/day/1>

## Part 1
전 세계적인 눈 생산에 뭔가 문제가 있어서, 당신이 살펴보기로 선택되었습니다. 엘프들은 당신에게 지도를 주면서, 문제가 있을 것 같은 상위 50개 지역에 별을 사용해 표시해두었습니다.

당신은 눈 생산 작업을 복구하려면 12월 25일까지 **별 50개**를 모두 확인해야 한다는 것을 충분히 알고 계실 정도로 이 일을 오래 해오셨습니다.

퍼즐을 풀어서 별을 모으세요. Advent 달력에는 매일 두 개의 퍼즐이 나옵니다; 첫 번째 퍼즐을 완성하면 두 번째 퍼즐이 풀립니다. 각각의 퍼즐은 **하나의 별**을 줍니다. 행운을 빌어요!

당신이 그들에게 "왜 그냥 [기상관측기](https://adventofcode.com/2015/day/1)를 사용할 수 없는지" 물어보고 ("충분히 강력하지 않다"), "나를 어디로 보내고 있는지" ("하늘"), "왜 내 지도가 대부분 비어있는 것처럼 보이는지" 물어보았을 때 ("정말 많은 질문을 한다"), "잠깐만요, 방금 하늘이라고 하셨나요?" ("물론, 눈이 어디서 온다고 생각하나요"), 엘프들이 이미 당신을 트레뷰셋에 싣고 있다는 것을 깨달았습니다 ("가만히 있어 주세요, 우리는 당신을 묶어야 합니다.").

당신이 마지막 조정을 할 때, 당신은 측정표(당신의 퍼즐 입력)가 자신의 예술 솜씨를 뽐내고 싶어 흥분한 매우 어린 엘프에 의해 수정되었다는 것을 알게 됩니다. 덕분에, 엘프들은 그 문서의 값들을 읽는 데 어려움을 겪고 있어요.

새롭게 개선된 측정표는 텍스트의 행으로 구성되어 있는데, 각 행에는 엘프들이 원래대로 복구해야 할 특정한 **측정 값**이 들어 있었습니다. 각 행에서 측정 값은 **첫 번째 자리**와 **마지막 자리**를 차례로 결합하여 하나의 **두 자리 숫자**를 만듬으로써 알 수 있습니다.

예시:

``` text
1 abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
```

이 예제에서 네 줄의 측정 값은 `12`, `38`, `15`, `77`입니다. 이것들을 더하면 `142`가 나옵니다.

당신에게 주어진 전체 측정표를 검토해 보세요. 모든 측정 값의 합은 얼마입니까?

## Part 2
당신의 계산은 정확하지 않습니다. 숫자들 중 일부는 실제 문자로 철자가 쓰여져 있는 것 같습니다: `one`, `two`, `three`, `four`, `five`, `six`, `seven`, `eight`, 그리고 `nine`도 유효한 "숫자"로 계산됩니다.

이 새로운 정보를 사용하여, 당신은 이제 각 라인에서 진짜 **첫 번째 자리**와 **마지막 자리**를 찾아낼 필요가 있습니다. 예를 들어

``` text
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

이 예시에서 측정 값은 `29`, `83`, `13`, `24`, `42`, `14`, 그리고 `76` 입니다. 그리고 이들을 모두 더하면, `281`이 만들어집니다.

모든 측정 값의 합은 얼마입니까?