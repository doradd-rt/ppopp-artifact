# Figure 9 - Core Pipelining Analysis

For the proposed core-pipelining techniques, we study the introduced overheads and how these change as a function of the number of cores in the pipeline. To reproduce the same results, this experiment need to run on our local testbed. But the same trend will show on others as well.

---

### Build

The source code is at [app/pipeline-profile](https://github.com/doradd-rt/doradd/tree/main/app/pipeline-profile) and at this [commit](https://github.com/doradd-rt/doradd/tree/310320ea237f2303230bfbf1ec0b921620f87182).

```bash
pushd doradd
git checkout main
git pull
git submodule update --init
pushd app/pipeline-profile
make
popd
popd
```

### Hello-world Example

To run the program, one should specify the core counts in the pipeline (larger than 1), and the workload type: read or write.

```bash
sudo ./doradd/app/pipeline-profile/pipeline <core_cnt> <read/write>
```

### Run

```bash
./run_fig9.sh # results will be located in pipeline_results.txt
```
