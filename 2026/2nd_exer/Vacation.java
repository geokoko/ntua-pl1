import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Arrays;

public class Vacation {
	static InputStream in;
	static byte[] buffer = new byte[1 << 16];
	static int pos = 0, len = 0;

	static int read() throws Exception {
		if (pos == len) {
			len = in.read(buffer);
			pos = 0;
			if (len <= 0) return -1;
		}
		return buffer[pos++];
	}

	static int nextInt() throws Exception {
		int c = read();
		while (c <= ' ' && c != -1) c = read();

		int value = 0;
		while (c > ' ') {
			value = 10 * value + c - '0';
			c = read();
		}
		return value;
	}

	public static void main(String[] args) throws Exception {
		in = new BufferedInputStream(args.length > 0 ? new FileInputStream(args[0]) : System.in);

		int n = nextInt();
		int size = 2 * n + 1;
		int offset = n;

		long[] freq = new long[size];
		int[] firstPos = new int[size];
		long[] firstCostPrefix = new long[size];
		Arrays.fill(firstPos, -1);

		int balance = 0;
		long sumCost = 0L;
		long total = 0L;
		int bestLength = 0;
		long bestCost = Long.MAX_VALUE;

		freq[offset] = 1L;
		firstPos[offset] = 0;

		for (int day = 1; day <= n; day++) {
			int mountain = nextInt();
			int sea = nextInt();

			int value;
			int price;
			if (mountain < sea) {
				value = 1;
				price = mountain;
			} else if (mountain > sea) {
				value = -1;
				price = sea;
			} else if (day % 2 == 1) {
				value = 1;
				price = mountain;
			} else {
				value = -1;
				price = sea;
			}

			balance += value;
			sumCost += price;

			int idx = balance + offset;
			total += freq[idx];

			if (firstPos[idx] == -1) {
				firstPos[idx] = day;
				firstCostPrefix[idx] = sumCost;
			} else {
				int length = day - firstPos[idx];
				long cost = sumCost - firstCostPrefix[idx];

				if (length > bestLength) {
					bestLength = length;
					bestCost = cost;
				} else if (length == bestLength && length > 0 && cost < bestCost) {
					bestCost = cost;
				}
			}

			freq[idx]++;
		}

		if (total == 0L) {
			System.out.println("0 0 0");
		} else {
			System.out.println(total + " " + bestLength + " " + bestCost);
		}
	}
}
