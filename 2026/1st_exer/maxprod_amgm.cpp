#include <algorithm>
#include <cstddef>
#include <cmath>
#include <cstdio>
#include <vector>

#define ll long long

const int BIG_BASE = 1000000000;
const int BIG_DIGITS = 9;
const int FFT_BASE = 10000;
const int FFT_DIGITS = 4;
const int SMALL_LIMIT = 500;
// Recompute exact roots every few FFT steps.
// Balance tradeoff between accumulated floating-point error and time spent on trig functions
// (especially for large FFT sizes where the roots are used more times).
// A huge cache would be faster but more memory-intensive, thus needing a higher memory limit.
const int ROOT_REFRESH = 256;
const double PI = std::acos(-1.0);
const ll POW10[] = {1LL, 10LL, 100LL, 1000LL, 10000LL, 100000LL, 1000000LL, 10000000LL, 100000000LL, 1000000000LL};

// static_cast helper to avoid warnings
inline std::size_t to_size(int x) {
	return static_cast<std::size_t>(x);
}

// Precompute 4-digit strings for faster output.
char digit4[10000][4];
bool digit4_ready = false;

void init_digit4() {
	if (digit4_ready) {
		return;
	}

	for (int i = 0; i < 10000; ++i) {
		int x = i;
		for (int j = 3; j >= 0; --j) {
			digit4[to_size(i)][to_size(j)] = static_cast<char>('0' + x % 10);
			x /= 10;
		}
	}
	digit4_ready = true;
}

// Small custom complex struct
struct cpx {
	double x, y;

	cpx(double real = 0.0, double imag = 0.0) : x(real), y(imag) {}

	cpx& operator/=(double value) {
		x /= value;
		y /= value;
		return *this;
	}
};

// FFT bigint multiplication adapted from indy256/codelibrary:
// https://github.com/indy256/codelibrary/blob/main/cpp/numeric/bigint.cpp
// https://github.com/indy256/codelibrary/blob/main/cpp/numeric/fft.h
void fft(std::vector<cpx>& a, bool inverse) {
	int n = static_cast<int>(a.size());

	// Bit-reversal permutation before the iterative FFT.
	for (int i = 1, j = 0; i < n; ++i) {
		int bit = n >> 1;
		while (j >= bit) {
			j -= bit;
			bit >>= 1;
		}
		j += bit;
		if (i < j) {
			std::swap(a[to_size(i)], a[to_size(j)]);
		}
	}

	// Roots are generated on the fly to keep peak memory low. The periodic refresh
	// avoids accumulated floating-point error from multiplying roots repeatedly.
	for (int len = 1; len < n; len <<= 1) {
		double angle = (inverse ? -PI : PI) / len;
		double root_x = std::cos(angle);
		double root_y = std::sin(angle);

		for (int i = 0; i < n; i += 2 * len) {
			double w_x = 1.0;
			double w_y = 0.0;
			for (int j = 0; j < len; ++j) {
				if ((j & (ROOT_REFRESH - 1)) == 0) {
					double cur = angle * j;
					w_x = std::cos(cur);
					w_y = std::sin(cur);
				}
				cpx& left = a[to_size(i + j)];
				cpx& right = a[to_size(i + j + len)];
				double vx = right.x * w_x - right.y * w_y;
				double vy = right.x * w_y + right.y * w_x;
				double ux = left.x;
				double uy = left.y;
				left.x = ux + vx;
				left.y = uy + vy;
				right.x = ux - vx;
				right.y = uy - vy;

				double next_x = w_x * root_x - w_y * root_y;
				w_y = w_x * root_y + w_y * root_x;
				w_x = next_x;
			}
		}
	}

	if (inverse) {
		for (cpx& x : a) {
			x /= n;
		}
	}
}

std::vector<int> change_base(const std::vector<int>& a, int old_digits, int new_digits) {
	int n = static_cast<int>(a.size());
	std::vector<int> res;
	res.reserve(to_size((n * old_digits + new_digits - 1) / new_digits + 1));
	ll cur = 0;
	int digits = 0;
	for (int x : a) {
		cur += x * POW10[digits];
		digits += old_digits;
		while (digits >= new_digits) {
			res.push_back(static_cast<int>(cur % POW10[new_digits]));
			cur /= POW10[new_digits];
			digits -= new_digits;
		}
	}
	res.push_back(static_cast<int>(cur));
	while (!res.empty() && res.back() == 0) {
		res.pop_back();
	}
	return res;
}

// Squares one bigint using a packed FFT. The input is in base 10^4 and is
// consumed to keep peak memory low. The result is returned directly in base 10^9.
std::vector<int> fft_square(std::vector<int>& digits) {
	int n = static_cast<int>(digits.size());
	int need = 2 * n;
	int fft_size = 1;
	while (fft_size < need) {
		fft_size <<= 1;
	}

	std::vector<cpx> fa(to_size(fft_size));
	for (int i = 0; i < n; ++i) {
		fa[to_size(i)] = cpx(digits[to_size(i)], digits[to_size(i)]);
	}
	// The small-base digits are no longer needed once they are copied into the FFT buffer.
	std::vector<int>().swap(digits);

	fft(fa, false);

	// Packed squaring trick from the cited FFT bigint implementation: one FFT is
	// enough because both real and imaginary parts contain the same number.
	for (int i = 0; i < fft_size; ++i) {
		int j = (fft_size - i) & (fft_size - 1);
		if (i > j) {
			continue;
		}
		cpx x = fa[to_size(i)];
		cpx y = fa[to_size(j)];
		double real = 0.5 * (x.x * x.y + y.x * y.y);
		double imag = -0.25 * (x.x * x.x - x.y * x.y - y.x * y.x + y.y * y.y);
		fa[to_size(i)] = cpx(real, imag);
		if (i != j) {
			fa[to_size(j)] = cpx(real, -imag);
		}
	}
	fft(fa, true);

	std::vector<int> res;
	res.reserve(to_size((need * FFT_DIGITS + BIG_DIGITS - 1) / BIG_DIGITS + 2));
	ll carry = 0;

	ll cur_big = 0;
	int cur_digits = 0;
	auto add_digit = [&](int digit) {
		cur_big += static_cast<ll>(digit) * POW10[cur_digits];
		cur_digits += FFT_DIGITS;
		while (cur_digits >= BIG_DIGITS) {
			res.push_back(static_cast<int>(cur_big % BIG_BASE));
			cur_big /= BIG_BASE;
			cur_digits -= BIG_DIGITS;
		}
	};

	// Normalize base-10^4 carries and immediately pack digits into base 10^9.
	for (int i = 0; i < need; ++i) {
		ll cur = static_cast<ll>(fa[to_size(i)].x + 0.5) + carry;
		add_digit(static_cast<int>(cur % FFT_BASE));
		carry = cur / FFT_BASE;
	}
	while (carry > 0) {
		add_digit(static_cast<int>(carry % FFT_BASE));
		carry /= FFT_BASE;
	}
	// cur_big has fewer than BIG_DIGITS decimal digits here, because add_digit()
	// flushes every complete base-10^9 block immediately.
	res.push_back(static_cast<int>(cur_big));
	while (!res.empty() && res.back() == 0) {
		res.pop_back();
	}
	return res;
}

/* Only the operations needed here: multiply by a small int, square, and print. */
class BigInt {
public:
	explicit BigInt(int value = 0) {
		z.push_back(value);
		trim();
	}

	void mul_small(int k) {
		ll carry = 0;
		for (int& x : z) {
			ll cur = static_cast<ll>(x) * k + carry;
			x = static_cast<int>(cur % BIG_BASE);
			carry = cur / BIG_BASE;
		}
		while (carry > 0) {
			z.push_back(static_cast<int>(carry % BIG_BASE));
			carry /= BIG_BASE;
		}
		trim();
	}

	void square() {
		if (static_cast<int>(z.size()) < SMALL_LIMIT) {
			simple_square();
		} else {
			std::vector<int> small = change_base(z, BIG_DIGITS, FFT_DIGITS);
			// Free the old base-10^9 storage before allocating the large FFT buffer.
			std::vector<int>().swap(z);
			z = fft_square(small);
			if (z.empty()) {
				// Defensive only; this program never squares zero.
				z.push_back(0);
			}
		}
	}

	void print() const {
		// Manual buffered output avoids one printf call per 9 digits. A 4-digit
		// table makes each full block cheaper than dividing once per decimal digit.
		init_digit4();
		const int OUT_BUF = 1 << 16;
		char out[OUT_BUF];
		int pos = 0;

		auto flush = [&]() {
			if (pos > 0) {
				(void)std::fwrite(out, 1, to_size(pos), stdout);
				pos = 0;
			}
		};

		auto put_char = [&](char c) {
			if (pos == OUT_BUF) {
				flush();
			}
			out[pos++] = c;
		};

		int first = z.empty() ? 0 : z.back();
		char tmp[10];
		int len = 0;
		if (first == 0) {
			tmp[len++] = '0';
		} else {
			while (first > 0) {
				tmp[len++] = static_cast<char>('0' + first % 10);
				first /= 10;
			}
		}
		for (int i = len - 1; i >= 0; --i) {
			put_char(tmp[i]);
		}

		for (int i = static_cast<int>(z.size()) - 2; i >= 0; --i) {
			if (pos + BIG_DIGITS > OUT_BUF) {
				flush();
			}
			int x = z[to_size(i)];
			int first_digit = x / 100000000;
			x -= first_digit * 100000000;
			int mid = x / 10000;
			int low = x - mid * 10000;

			out[pos] = static_cast<char>('0' + first_digit);
			const char* mid_digits = digit4[to_size(mid)];
			out[pos + 1] = mid_digits[0];
			out[pos + 2] = mid_digits[1];
			out[pos + 3] = mid_digits[2];
			out[pos + 4] = mid_digits[3];
			const char* low_digits = digit4[to_size(low)];
			out[pos + 5] = low_digits[0];
			out[pos + 6] = low_digits[1];
			out[pos + 7] = low_digits[2];
			out[pos + 8] = low_digits[3];
			pos += BIG_DIGITS;
		}
		put_char('\n');
		flush();
	}

private:
	std::vector<int> z;

	void trim() {
		while (z.size() > 1 && z.back() == 0) {
			z.pop_back();
		}
	}

	void simple_square() {
		int n = static_cast<int>(z.size());
		std::vector<__int128> sums(to_size(2 * n), 0);

		// Accumulate each coefficient once, then do a single carry pass.
		for (int i = 0; i < n; ++i) {
			__int128 x = z[to_size(i)];
			sums[to_size(i + i)] += x * x;
			for (int j = i + 1; j < n; ++j) {
				sums[to_size(i + j)] += 2 * x * z[to_size(j)];
			}
		}

		std::vector<int> res(to_size(2 * n + 1), 0);
		__int128 carry = 0;
		for (int i = 0; i < 2 * n; ++i) {
			__int128 cur = sums[to_size(i)] + carry;
			res[to_size(i)] = static_cast<int>(cur % BIG_BASE);
			carry = cur / BIG_BASE;
		}
		int pos = 2 * n;
		while (carry > 0) {
			res[to_size(pos++)] = static_cast<int>(carry % BIG_BASE);
			carry /= BIG_BASE;
		}
		res.resize(to_size(pos));

		z = res;
		trim();
	}
};

// Binary exponentiation: compute 3^k with repeated squaring.
BigInt pow3(ll k) {
	if (k == 0) {
		return BigInt(1);
	}

	int highest_bit = 0;
	for (ll x = k; x > 1; x >>= 1) {
		++highest_bit;
	}

	BigInt ans(1);
	for (int bit = highest_bit; bit >= 0; --bit) {
		ans.square();
		if ((k >> bit) & 1LL) {
			ans.mul_small(3);
		}
	}
	return ans;
}

BigInt max_product(ll n) {
	if (n == 2) {
		return BigInt(1);
	}
	if (n == 3) {
		return BigInt(2);
	}

	/* 
	 * By AM-GM inequality, if the number of parts is fixed, the product is maximized when
	 * the parts are as equal as possible. After forcing equality, the problem is,
	 * for real parts, equivalent to maximizing x^(n/x), which has global maximum
	 * at x = e, so with integer parts we only need numbers close to e: 2s
	 * and 3s. Since 3 > 2*1 and 2*2 > 3*1, we use as many 3s as possible and
	 * replace a leftover 1 by 2+2.
	 * */

	ll cnt3 = n / 3;
	int last = 1;

	if (n % 3 == 1) {
		--cnt3;
		last = 4;
	} else if (n % 3 == 2) {
		last = 2;
	}

	BigInt ans = pow3(cnt3);
	if (last != 1) {
		ans.mul_small(last);
	}
	return ans;
}

int main(int argc, char* argv[]) {
	ll n = 0;

	if (argc > 1) {
		std::FILE* fp = std::fopen(argv[1], "r");
		if (fp == nullptr) {
			return 1;
		}
		if (std::fscanf(fp, "%lld", &n) != 1) {
			std::fclose(fp);
			return 1;
		}
		std::fclose(fp);
	} else if (std::scanf("%lld", &n) != 1) {
		return 1;
	}

	max_product(n).print();
	return 0;
}
