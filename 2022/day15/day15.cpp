#include <bits/stdc++.h>
#define INF 987654321
typedef long long ll;

using namespace std;

vector<pair<int, int>> sensors;
vector<pair<int, int>> beacons;

int manhattanDistance(pair<int, int> a, pair<int, int> b);
pair<int, int> findBeaconExclusionZone(pair<int, int> source, int distance);

int main() {
  ios::sync_with_stdio(false);
  cin.tie(NULL);
  cout.tie(NULL);


  regex re("Sensor at x=(-?\\d+), y=(-?\\d+): closest beacon is at x=(-?\\d+), y=(-?\\d+)");
  ifstream file("input.txt");

  if (!file.is_open()) {
    return 0;
  }

  string line;
  while(getline(file, line)) {
    smatch match;
    if (regex_match(line, match, re)) {
      int sx = stoi(match[1].str());
      int sy = stoi(match[2].str());
      int bx = stoi(match[3].str());
      int by = stoi(match[4].str());

      sensors.push_back({sy, sx});
      beacons.push_back({by, bx});
    }
  }
  file.close();

  for(int i = 0; i < sensors.size(); i++) {
    pair<int, int> sensor = sensors[i];
    pair<int, int> beacon = beacons[i];
    int distance = manhattanDistance(sensor, beacon);

    pair<int, int> result = findBeaconExclusionZone(sensor, distance + 1);

    if (result.first >= 0 && result.second >= 0) {
      cout << result.first << " " << result.second << endl;
      cout << result.second * 4000000LL + result.first << endl;

      return 0;
    }
  }

  return 0;
}

int manhattanDistance(pair<int, int> a, pair<int, int> b) {
  return abs(a.first - b.first) + abs(a.second - b.second);
}

pair<int, int> findBeaconExclusionZone(pair<int, int> source, int distance) {
  int source_y = source.first;
  int source_x = source.second;

  for (int i = -distance; i <= distance; i++) {
    int y = source_y + i;
    int xDiff = distance - abs(i);

    for (int j = -1; j <= 1; j += 2) {
      int x = source_x + (xDiff * j);

      if (y < 0 or 4000000 < y or x < 0 or 4000000 < x) {
        continue;
      }

      bool isBeaconExclusionZone = true;
      for (int k = 0; k < sensors.size(); k++) {
        if (manhattanDistance(sensors[k], {y, x}) <= manhattanDistance(sensors[k], beacons[k])) {
          isBeaconExclusionZone = false;
          break;
        }
      }
      if (isBeaconExclusionZone) {
        return {y, x};
      }
    }
  }

  return {-1, -1};
}