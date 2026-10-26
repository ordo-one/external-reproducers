
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     33076 |     33096 |     33096 |     33096 |     33096 |     33915 |     34572 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |      3646 |      3658 |      3658 |      3795 |      3795 |      4165 |      4165 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |      8658 |      8675 |      8675 |      8675 |      9363 |      9729 |      9729 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |      7935 |      7946 |      7946 |      7946 |      8413 |      8778 |      8778 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1371 |      1415 |      1415 |      1415 |      1415 |      1415 |      1415 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1246 |      1246 |      1256 |      1256 |      1256 |      1256 |      1258 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2388 |      2398 |      2398 |      2660 |      2660 |      2660 |      2663 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1535 |      1545 |      1579 |      1579 |      1579 |      1580 |      1582 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1264 |      1275 |      1284 |      1299 |      1316 |      1426 |      1501 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       141 |       147 |       150 |       155 |       157 |       168 |       171 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |       315 |       324 |       325 |       347 |       385 |       417 |       426 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |       282 |       291 |       295 |       301 |       324 |       342 |       357 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        62 |        66 |        67 |        67 |        67 |        70 |        72 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        49 |        59 |        59 |        59 |        60 |        60 |        67 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |        98 |       106 |       109 |       120 |       122 |       123 |       135 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        68 |        72 |        73 |        75 |        75 |        80 |        84 |       500 |

