#include <cstdio>
#include <algorithm>

#define MAXN 42000000
#define ll long long
/* Recursive solution:
 * cost[n] = max over i (i * max(n - i, cost[n - i]))
 * cost[0] = 0
 * */

int main () {
	ll n;
	scanf("%lld", &n);

	ll cost[MAXN] = {0};
	for (ll i = 0; i <= n; ++i)
		for (ll j = 1; j < i; ++j)
			cost[i] = std::max(cost[i], std::max(j * (i - j), j * cost[i - j]));

	printf("Cost is: %lld\n", cost[n]);
}
