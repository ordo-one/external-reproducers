
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     33146 |     33161 |     33161 |     33161 |     33161 |     33980 |     34642 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |      3646 |      3658 |      3658 |      3785 |      3795 |      4235 |      4240 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |      8698 |      8708 |      8708 |      8708 |      9404 |      9769 |      9769 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |      7935 |      7946 |      7946 |      7946 |      8413 |      8778 |      8778 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1405 |      1415 |      1415 |      1415 |      1415 |      1415 |      1415 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1456 |      1456 |      1457 |      1468 |      1477 |      1483 |      1491 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2388 |      2398 |      2402 |      2660 |      2660 |      2675 |      2676 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1545 |      1579 |      1579 |      1580 |      1582 |      1592 |      1593 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1408 |      1435 |      1442 |      1451 |      1467 |      1504 |      1518 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       129 |       157 |       160 |       163 |       168 |       182 |       187 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |       337 |       347 |       350 |       354 |       388 |       404 |       430 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |       266 |       310 |       314 |       320 |       339 |       355 |       359 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        60 |        63 |        64 |        65 |        65 |        68 |        72 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        60 |        63 |        64 |        65 |        66 |        68 |        85 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |        92 |       106 |       108 |       124 |       126 |       133 |       134 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        62 |        70 |        71 |        71 |        73 |        73 |        76 |       500 |

