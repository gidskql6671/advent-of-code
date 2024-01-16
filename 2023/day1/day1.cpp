#include <bits/stdc++.h>
#define INF 987654321
typedef long long ll;
using namespace std;


int main() {
  ios::sync_with_stdio(false);
  cin.tie(NULL);
  cout.tie(NULL);


  ifstream infile("input.txt");

  string line;
  int result = 0;
  while (getline(infile, line)) {
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

  cout << "Part1 : " << result << endl;

  return 0;
}
