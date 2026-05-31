import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.InputStream;

public class Lights {
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

	static void press(int[] rows, int n, int r, int c) {
		int bit = 1 << c;
		rows[r] ^= bit;
		if (c > 0) {
			rows[r] ^= 1 << (c - 1);
		}
		if (c + 1 < n) {
			rows[r] ^= 1 << (c + 1);
		}
		if (r > 0) {
			rows[r - 1] ^= bit;
		}
		if (r + 1 < n) {
			rows[r + 1] ^= bit;
		}
	}

	public static void main(String[] args) throws Exception {
		in = new BufferedInputStream(args.length > 0 ? new FileInputStream(args[0]) : System.in);

		int n = nextInt();
		int[] start = new int[n];
		for (int r = 0; r < n; r++) {
			for (int c = 0; c < n; c++) {
				if (nextInt() == 1) start[r] |= 1 << c;
			}
		}

		int best = Integer.MAX_VALUE;
		for (int firstRow = 0; firstRow < (1 << n); firstRow++) {
			int[] rows = start.clone();
			int presses = 0;

			for (int c = 0; c < n; c++) {
				if ((firstRow & (1 << c)) != 0) {
					press(rows, n, 0, c);
					presses++;
				}
			}

			for (int r = 1; r < n; r++) {
				int above = rows[r - 1];
				for (int c = 0; c < n; c++) {
					if ((above & (1 << c)) != 0) {
						press(rows, n, r, c);
						presses++;
					}
				}
			}

			if (rows[n - 1] == 0 && presses < best) best = presses;
		}

		if (best == Integer.MAX_VALUE) {
			System.out.println("IMPOSSIBLE");
		} else {
			System.out.println(best);
		}
	}
}
