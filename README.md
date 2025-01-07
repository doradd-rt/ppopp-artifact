# PPoPP-Artifact

This repository contains the artifact for our PPoPP’25 paper: **DORADD: Deterministic Parallel Execution in the Era of Microsecond-Scale Computing**. It includes the source code, detailed instructions, and scripts necessary for reproducing the experiments presented in the paper.

The code has been tested primarily on Ubuntu 22.04. To fully reproduce the results, two testbeds are required:

## Testbeds

### 1. **Single-Node Experiments (Figures 5, 8, and 9)**

- These experiments should be run on a local testbed equipped with an Intel Xeon Gold 5318N CPU (24 cores) and 128G DRAM.
- For PPoPP AE reviewers:
    - Please provide your SSH public key so we can grant you access to the testbed server.

### 2. **Multi-Node Experiments (Figures 6 and 7)**

- These experiments are designed to run on **CloudLab** using **three** **d6515 nodes**.
- We provide a [CloudLab experiment profile](https://github.com/doradd-rt/doradd-cloudlab-profile) to facilitate the setup of the machines. You can follow this [guide](https://github.com/doradd-rt/ppopp-artifact/blob/main/doradd-cloudlab-instructions.pdf) to setup on cloudlab.
- Please **reserve these nodes in advance**, as they may not always be available.

## Experiments Summary

Estimated time to run all experiments: 5h ~ 6h. It will take 1h human time. We suggest using tmux to track the experiment progress.


| **Experiments** | **Instructions** | **Testbed** | **Human time** | **Machine time** |
| --- | --- | --- | --- | --- |
| 1. DORADD v.s. Caracal | [Figure-5.md](https://github.com/doradd-rt/ppopp-artifact/blob/main/Figure-5.md) | Local | 5 min | 2h |
| 2. DORADD v.s. Non-deterministic Systems | [Figure-6.md](https://github.com/doradd-rt/ppopp-artifact/blob/main/Figure-6.md) | Cloudlab | 10 min | 2h |
| 3. Primary-backup Replication | [Figure-7.md](https://github.com/doradd-rt/ppopp-artifact/blob/main/Figure-7.md) | Cloudlab | 10 min | 20 min |
| 4. Perf Analysis | [Figure-8.md](https://github.com/doradd-rt/ppopp-artifact/blob/main/Figure-8.md) | Local | 5 min | 30 min |
| 5. Pipeline Analysis | [Figure-9.md](https://github.com/doradd-rt/ppopp-artifact/blob/main/Figure-9.md) | Local | 5 min | 5 min |
