# Figure 8 - Performance Breakdown

For the proposed core-pipelining techniques, we study the introduced overheads and how these change as a function of the number of cores in the pipeline. To reproduce the same results, this experiment need to run on our local testbed. But the same trend will show on others as well.

This experiment evaluates the four different variant of DORADD

- v0: No optimization
- v1: Prefetch
- v2: 2-core dispatcher
- v3: 3-core dispatcher

---

## Hello-world Example

The source code is at [perf-profile](https://github.com/doradd-rt/doradd/tree/perf-profile) branch. We provide a setup script to generating the input log, setup the corresponding parameters in the source code, and build. It is used as 

```bash
./fig8_setup.sh <variant> <keyspace> <key-per-txn>
```

For instance, to setup for figure 8 (a) with 10M keyspace and in No optimization (`v0`),  you should first 

```bash
./fig8_setup.sh v0 1M 10
```

Then you can run this certain workload via

```bash
./run_perf_breakdown.sh v0 1M 10
```

> Note: remember to run setup script first for each workload type before running the experiments
>

## Run

```bash
./run_fig8.sh
```

The results are located in `fig8-results/`.
To see the results for figure 8(a), you can use 
```
for file in *10.txt; do echo "===== $file ====="; cat "$file"; echo ""; done
```
and for figure 8 (b), use
```
for file in *10M*.txt; do echo "===== $file ====="; cat "$file"; echo ""; done
```
