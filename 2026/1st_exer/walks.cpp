#include <array>
#include <cstddef>
#include <cstdio>
#include <cstdint>
#include <queue>
#include <vector>

static const std::uint32_t BIG_BASE = 1000000000U;

struct BigInt {
	std::vector<std::uint32_t> d;
};

static BigInt make_bigint(std::uint32_t value) {
	BigInt x;
	if (value != 0U) {
		x.d.push_back(value);
	}
	return x;
}

static bool bigint_is_zero(const BigInt &x) {
	return x.d.empty();
}

static void bigint_clear(BigInt &x) {
	x.d.clear();
}

static void bigint_add(BigInt &x, const BigInt &other) {
	if (other.d.empty()) {
		return;
	}

	if (x.d.empty()) {
		x.d.assign(other.d.begin(), other.d.end());
		return;
	}

	if (x.d.size() < other.d.size()) {
		x.d.resize(other.d.size(), 0U);
	}

	std::uint64_t carry = 0U;
	std::size_t i = 0U;
	while (i < other.d.size()) {
		const std::uint64_t cur =
			static_cast<std::uint64_t>(x.d[i]) + other.d[i] + carry;
		if (cur >= BIG_BASE) {
			x.d[i] = static_cast<std::uint32_t>(cur - BIG_BASE);
			carry = 1U;
		} else {
			x.d[i] = static_cast<std::uint32_t>(cur);
			carry = 0U;
		}
		++i;
	}

	while (carry != 0U && i < x.d.size()) {
		const std::uint64_t cur = static_cast<std::uint64_t>(x.d[i]) + carry;
		if (cur >= BIG_BASE) {
			x.d[i] = static_cast<std::uint32_t>(cur - BIG_BASE);
			carry = 1U;
		} else {
			x.d[i] = static_cast<std::uint32_t>(cur);
			carry = 0U;
		}
		++i;
	}

	if (carry != 0U) {
		x.d.push_back(1U);
	}
}

static void bigint_print(const BigInt &x, FILE *out) {
	if (x.d.empty()) {
		std::fputc('0', out);
		return;
	}

	std::fprintf(out, "%u", x.d.back());
	for (std::size_t i = x.d.size() - 1U; i > 0U; --i) {
		std::uint32_t value = x.d[i - 1U];
		char block[9];
		for (int pos = 8; pos >= 0; --pos) {
			block[pos] = static_cast<char>('0' + value % 10U);
			value /= 10U;
		}
		std::fwrite(block, 1U, 9U, out);
	}
}

struct Input {
	int rows = 0;
	int cols = 0;
	long long steps = 0;
	int start_row = 0;
	int start_col = 0;
	int target_row = 0;
	int target_col = 0;
	std::vector<unsigned char> blocked;
};

static int cell_id(int row, int col, int cols) {
	return row * cols + col;
}

static bool read_input(FILE *in, Input &data) {
	long long steps = 0LL;
	if (std::fscanf(
		in,
		"%d %d %lld %d %d %d %d",
		&data.rows,
		&data.cols,
		&steps,
		&data.start_row,
		&data.start_col,
		&data.target_row,
		&data.target_col
	) != 7) {
		return false;
	}

	data.steps = steps;
	--data.start_row;
	--data.start_col;
	--data.target_row;
	--data.target_col;

	const int total = data.rows * data.cols;
	data.blocked.assign(static_cast<std::size_t>(total), 0U);

	int obstacle_count = 0;
	if (std::fscanf(in, "%d", &obstacle_count) != 1) {
		return false;
	}

	for (int i = 0; i < obstacle_count; ++i) {
		int row = 0;
		int col = 0;
		if (std::fscanf(in, "%d %d", &row, &col) != 2) {
			return false;
		}
		--row;
		--col;
		data.blocked[static_cast<std::size_t>(cell_id(row, col, data.cols))] = 1U;
	}

	return true;
}

static std::vector<std::array<int, 4>> build_neighbors(
	const Input &data,
	const std::vector<int> &cell_to_node,
	const std::vector<int> &node_to_cell,
	std::vector<int> &degree
) {
	const int delta_row[4] = {-1, 1, 0, 0};
	const int delta_col[4] = {0, 0, -1, 1};
	std::vector<std::array<int, 4>> neighbors(node_to_cell.size());
	degree.assign(node_to_cell.size(), 0);

	for (std::size_t node = 0U; node < node_to_cell.size(); ++node) {
		const int cell = node_to_cell[node];
		const int row = cell / data.cols;
		const int col = cell % data.cols;

		for (int dir = 0; dir < 4; ++dir) {
			const int next_row = row + delta_row[dir];
			const int next_col = col + delta_col[dir];
			if (next_row < 0 || next_row >= data.rows || next_col < 0 || next_col >= data.cols) {
				continue;
			}

			const int next_cell = cell_id(next_row, next_col, data.cols);
			const int next_node = cell_to_node[static_cast<std::size_t>(next_cell)];
			if (next_node != -1) {
				const int pos = degree[node];
				neighbors[node][static_cast<std::size_t>(pos)] = next_node;
				degree[node] = pos + 1;
			}
		}
	}

	return neighbors;
}

static std::vector<int> bfs_distances(
	int source,
	const std::vector<std::array<int, 4>> &neighbors,
	const std::vector<int> &degree
) {
	std::vector<int> dist(neighbors.size(), -1);
	std::queue<int> q;
	dist[static_cast<std::size_t>(source)] = 0;
	q.push(source);

	while (!q.empty()) {
		const int node = q.front();
		q.pop();

		for (int i = 0; i < degree[static_cast<std::size_t>(node)]; ++i) {
			const int next = neighbors[static_cast<std::size_t>(node)][static_cast<std::size_t>(i)];
			if (dist[static_cast<std::size_t>(next)] == -1) {
				dist[static_cast<std::size_t>(next)] = dist[static_cast<std::size_t>(node)] + 1;
				q.push(next);
			}
		}
	}

	return dist;
}

static BigInt count_walks(
	int start,
	int target,
	int steps,
	const std::vector<std::array<int, 4>> &neighbors,
	const std::vector<int> &degree,
	const std::vector<int> &dist_to_target
) {
	std::vector<BigInt> current(neighbors.size());
	std::vector<BigInt> next(neighbors.size());
	std::vector<int> active;
	std::vector<int> next_active;
	active.reserve(neighbors.size());
	next_active.reserve(neighbors.size());

	current[static_cast<std::size_t>(start)] = make_bigint(1U);
	active.push_back(start);

	for (int step = 0; step < steps && !active.empty(); ++step) {
		const int remaining_after_move = steps - step - 1;
		next_active.clear();

		for (const int node : active) {
			const BigInt &ways = current[static_cast<std::size_t>(node)];
			for (int i = 0; i < degree[static_cast<std::size_t>(node)]; ++i) {
				const int to = neighbors[static_cast<std::size_t>(node)][static_cast<std::size_t>(i)];
				const int target_dist = dist_to_target[static_cast<std::size_t>(to)];
				if (target_dist < 0 ||
					target_dist > remaining_after_move ||
					((remaining_after_move - target_dist) & 1) != 0) {
					continue;
				}

				BigInt &slot = next[static_cast<std::size_t>(to)];
				if (bigint_is_zero(slot)) {
					next_active.push_back(to);
				}
				bigint_add(slot, ways);
			}
		}

		for (const int node : active) {
			bigint_clear(current[static_cast<std::size_t>(node)]);
		}

		for (const int node : next_active) {
			current[static_cast<std::size_t>(node)].d.swap(next[static_cast<std::size_t>(node)].d);
		}
		active.swap(next_active);
	}

	return current[static_cast<std::size_t>(target)];
}

static void solve(FILE *in) {
	Input data;
	if (!read_input(in, data)) {
		return;
	}

	const int total = data.rows * data.cols;
	const int start_cell = cell_id(data.start_row, data.start_col, data.cols);
	const int target_cell = cell_id(data.target_row, data.target_col, data.cols);

	if (data.blocked[static_cast<std::size_t>(start_cell)] != 0U ||
		data.blocked[static_cast<std::size_t>(target_cell)] != 0U) {
		std::puts("0");
		return;
	}

	std::vector<int> cell_to_node(static_cast<std::size_t>(total), -1);
	std::vector<int> node_to_cell;
	node_to_cell.reserve(static_cast<std::size_t>(total));

	for (int cell = 0; cell < total; ++cell) {
		if (data.blocked[static_cast<std::size_t>(cell)] == 0U) {
			cell_to_node[static_cast<std::size_t>(cell)] = static_cast<int>(node_to_cell.size());
			node_to_cell.push_back(cell);
		}
	}

	const int start = cell_to_node[static_cast<std::size_t>(start_cell)];
	const int target = cell_to_node[static_cast<std::size_t>(target_cell)];

	std::vector<int> degree;
	const std::vector<std::array<int, 4>> neighbors =
		build_neighbors(data, cell_to_node, node_to_cell, degree);
	const std::vector<int> dist_to_target = bfs_distances(target, neighbors, degree);
	const int dist = dist_to_target[static_cast<std::size_t>(start)];

	if (dist < 0 || static_cast<long long>(dist) > data.steps ||
		((data.steps - static_cast<long long>(dist)) & 1LL) != 0LL) {
		std::puts("0");
		return;
	}

	BigInt answer = count_walks(
		start, target, static_cast<int>(data.steps), neighbors, degree, dist_to_target
	);
	bigint_print(answer, stdout);
	std::fputc('\n', stdout);
}

int main(int argc, char **argv) {
	if (argc == 2) {
		FILE *in = std::fopen(argv[1], "rb");
		if (in == nullptr) {
			return 1;
		}
		solve(in);
		std::fclose(in);
	} else {
		solve(stdin);
	}

	return 0;
}
