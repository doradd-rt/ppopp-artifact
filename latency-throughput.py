import sys
import statistics

def read_data(file_path):
    latency = []
    throughput = []
    with open(file_path, 'r') as file:
        for line in file:
            count, value = line.strip().split()
            if not value.isdigit(): # fload indicates the throughput number instead of latency
                throughput.append(int(float(value)))
                continue
            latency.append((int(count), int(value)))
    final_throughput = 0
    if throughput:
        final_throughput = int(statistics.mean(throughput[1:]))  # filter the first printed out throughput
    return latency, final_throughput

def calculate_cdf(data):
    total_count = sum(count for count, _ in data)
    cdf = []
    cumulative_sum = 0
    for count, value in data:
        cumulative_sum += count
        cdf.append((value, cumulative_sum / total_count))
    return cdf

def calculate_percentiles(cdf):

    def get_percentile(cdf, percentile):
        return next(value for value, cumulative_prob in cdf if cumulative_prob >= percentile)

    # percentiles = [0.99, 0.9, 0.85, 0.8, 0.7, 0.5]
    # results = {f"p{int(percentile * 100)}": get_percentile(cdf, percentile) for percentile in percentiles}
    # return [results[f"p{int(percentile * 100)}"] for percentile in percentiles]
    return get_percentile(cdf, 0.99)

if __name__ == "__main__":
    latency_data, throughput = read_data(sys.argv[1])
    latency = 0
    if throughput == 0:
        latency = 10000000; # overloaded
    else:
        cdf = calculate_cdf(latency_data)
        latency = calculate_percentiles(cdf)
    print(latency, throughput)
