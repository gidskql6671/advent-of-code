#include <bits/stdc++.h>
#define INF 987654321
typedef long long ll;
using namespace std;


int part1(vector<string> &input) {
  int result = 0;
  for(string line : input) {
    int num = 0;

    for(int i = 0; i < line.length(); i++) {
      if ('0' <= line[i] and line[i] <= '9') {
        num = 10 * (line[i] - '0');
        break;
      }
    }

    for(int i = line.length() - 1; i >= 0; i--) {
      if ('0' <= line[i] and line[i] <= '9') {
        num += line[i] - '0';
        break;
      }
    }

    result += num;
  }

  return result;
}

int part2(vector<string> input) {
  string digits[] = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

  int result = 0;
  for(string line : input) {
    int num = 0;

    for(int i = 0; i < line.length(); i++) {
      if ('0' <= line[i] and line[i] <= '9') {
        num = 10 * (line[i] - '0');
        break;
      }

      bool isNumber = false;
      for(int j = 0; j < 9; j++) {
        string digit = digits[j];
        bool isSame = true;
        for(int k = 0; k < digit.length() and i + k < line.length(); k++) {
          if (digit[k] != line[i + k]) {
            isSame = false;
            break;
          }
        }

        if (isSame) {
          isNumber = true;
          num = 10 * (j + 1);
          break;
        }
      }

      if (isNumber) {
        break;
      }
    }

    for(int i = line.length() - 1; i >= 0; i--) {
      if ('0' <= line[i] and line[i] <= '9') {
        num += line[i] - '0';
        break;
      }

      bool isNumber = false;
      for(int j = 0; j < 9; j++) {
        string digit = digits[j];
        bool isSame = true;
        if (i - (digit.length() - 1) < 0) {
          break;
        }

        for(int k = 0; k < digit.length(); k++) {
          if (digit[k] != line[i - digit.length() + 1 + k]) {
            isSame = false;
            break;
          }
        }

        if (isSame) {
          isNumber = true;
          num += j + 1;
          break;
        }
      }

      if (isNumber) {
        break;
      }
    }

    result += num;
  }

  return result;
}

int main() {
  ios::sync_with_stdio(false);
  cin.tie(NULL);
  cout.tie(NULL);


  ifstream infile("input.txt");
  vector<string> input;

  string line;
  while (getline(infile, line)) {
    input.push_back(line);
  }

  cout << "Part1 : " << part1(input) << endl;
  cout << "Part1 : " << part2(input) << endl;

  return 0;
}
