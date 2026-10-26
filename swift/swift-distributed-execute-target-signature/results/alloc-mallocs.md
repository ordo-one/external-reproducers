
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Malloc (total)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |         8 |         8 |         8 |         8 |         8 |         8 |         8 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |         3 |         3 |         3 |         3 |         3 |         3 |         3 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |         6 |         6 |         6 |         6 |         6 |         6 |         6 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |         6 |         6 |         6 |         6 |         6 |         6 |         6 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |         0 |         0 |         0 |         0 |         0 |         0 |         0 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |         0 |         0 |         0 |         0 |         0 |         0 |         0 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |         0 |         0 |         0 |         0 |         0 |         0 |         0 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |         0 |         0 |         0 |         0 |         0 |         0 |         0 |       500 |

