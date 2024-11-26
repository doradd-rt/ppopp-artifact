# Figure 9 - Core Pipelining Analysis

For the proposed core-pipelining techniques, we study the introduced overheads and how these change as a function of the number of cores in the pipeline. To reproduce the same results, this experiment need to run on our local testbed. But the same trend will show on others as well.

---

### Build

The source code is at [app/pipeline-profile](https://github.com/doradd-rt/doradd/tree/main/app/pipeline-profile).

```bash
cd doradd/src/bench/pipeline-profile
make
```

### Run

To run the program, one should specify the core counts in the pipeline (larger than 1), and the workload type: read or write.

```bash
sudo ./pipeline <core_cnt> <read/write>
```
