#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <climits>
#include <vector>
#include <limits>
#include <numeric>

#define ll long long

using namespace std;

/* The objective is to minimize |2S - total_sum|, where S the sum of the sequence and total_sum the sum of all array elements
Essentially, we want to find a subsequence, such that sum S is as close as possible to total_sum/2
*/

ll fairseq(const vector<ll>& arr) {
	ll total_sum = accumulate(arr.begin(), arr.end(), 0LL); //calculate total sum of the elements of the array
	ll s = 0;
	ll best = numeric_limits<ll>::max();

	int i = 0;
	int j = 0;
	while (j < arr.size() && i < arr.size()) {
		s += arr[j++];
		ll current_diff = abs(2 * s - total_sum);
		if (current_diff < best)
			best = current_diff;

		while (i < j && (2 * s - total_sum >= 0)) {
			s -= arr[i++];
			current_diff = abs(2 * s - total_sum);
			if (current_diff < best)
				best = current_diff;
		}
		if (best == 0)
			break;
	}

	return best;
}

int main (int argc, char **argv) {
	if (argc != 2)
		printf("Usage: %s <input_file>\n", argv[0]);

	FILE *f = fopen(argv[1], "r");
    if (f == NULL) {
        printf("Error opening file\n");
        return 1;
    }
    ll N;
    fscanf(f, "%lld", &N);

	vector<ll> sequence(N);

	for (int i = 0; i < N; ++i)
		fscanf(f, "%lld", &sequence[i]);
	
	ll result = fairseq(sequence);

	printf("The minimum sum of a subsequence, such that it satisfies the task, is: %lld\n", result);

}

