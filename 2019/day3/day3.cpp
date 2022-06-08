#include <bits/stdc++.h>
#define INF 987654321
typedef long long ll;

using namespace std;

int dx[] = {1, 0, -1, 0};
int dy[] = {0, 1, 0, -1};

vector<string> split(string str, char delimiter);
vector<vector<string>> getInput();
void markLine(map<pair<int, int>, pair<int, int>> &grid, vector<string> line, int identifier);
int getDirection(string oper);

int main() {
  ios::sync_with_stdio(false);
  cin.tie(NULL);
  cout.tie(NULL);

  vector<vector<string>> lines = getInput();

  map<pair<int, int>, pair<int, int>> grid;
  for (int i = 0; i < lines.size(); i++) {
    markLine(grid, lines[i], i);
  }

  int minDir = INF;
  int minStep = INF;
  for (auto iter : grid) {
    int identifier = iter.second.first;

    if (identifier == -1) {
      int y = iter.first.first;
      int x = iter.first.second;
      int step = iter.second.second;

      minDir = min(minDir, abs(y) + abs(x));
      minStep = min(minStep, step);
    }
  }

  cout << minDir << endl << minStep << endl;

  return 0;
}

vector<string> split(string str, char delimiter) {
  vector<string> result;
  stringstream ss(str);
  string temp;

  while (getline(ss, temp, delimiter)) {
    result.push_back(temp);
  }

  return result;
}

vector<vector<string>> getInput() {
  vector<vector<string>> result;
	ifstream file("input.txt");
	if( file.is_open() ){
		string line;

		while(getline(file, line)){
      result.push_back(split(line, ','));
		}

		file.close();
	}

  return result;
}

void markLine(map<pair<int, int>, pair<int, int>> &grid, vector<string> line, int identifier) {
  int y = 0, x = 0;
  int total_length = 0;

  for (int i = 0; i < line.size(); i++) {
    string oper = line[i].substr(0, 1);
    int length = stoi(line[i].substr(1));
    int direction = getDirection(oper);

    for (int j = 1; j <= length; j++) {
      int ny = y + dy[direction] * j;
      int nx = x + dx[direction] * j;
      total_length++;

      auto iter = grid.find({ny, nx});
      if (iter == grid.end()) {
        grid.insert({{ny, nx}, {identifier, total_length}});
      } else {
        int prevIdentifier = iter->second.first;

        if (prevIdentifier > -1 && prevIdentifier != identifier) {
          int prevStep = iter->second.second;

          grid[{ny, nx}] = {-1, prevStep + total_length};
        }
      }
    }

    y += dy[direction] * length;
    x += dx[direction] * length;
  }
}

int getDirection(string oper) {
    if (oper == "R") {
      return 0;
    } else if (oper == "L") {
      return 2;
    } else if (oper == "U") {
      return 1;
    } else {
      return 3;
    }
}