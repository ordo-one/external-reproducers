
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     42804 |     42828 |     42828 |     42828 |     42828 |     43745 |     44386 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     20353 |     20365 |     20365 |     20365 |     20382 |     21103 |     21121 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     44036 |     44073 |     44073 |     44073 |     44073 |     45433 |     45433 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     34644 |     34669 |     34669 |     34669 |     34669 |     35717 |     35730 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1381 |      1415 |      1415 |      1415 |      1415 |      1415 |      1419 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1222 |      1256 |      1256 |      1256 |      1256 |      1256 |      1256 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2388 |      2398 |      2660 |      2660 |      2660 |      2660 |      2663 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1465 |      1476 |      1509 |      1509 |      1509 |      1509 |      1513 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1619 |      1640 |      1653 |      1664 |      1676 |      1822 |      1850 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       725 |       737 |       740 |       744 |       752 |       782 |       800 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      1632 |      1668 |      1676 |      1707 |      1735 |      1906 |      1955 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1278 |      1294 |      1306 |      1320 |      1341 |      1470 |      1487 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        55 |        64 |        64 |        64 |        64 |        68 |        74 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        53 |        58 |        59 |        60 |        60 |        63 |        67 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |        98 |       104 |       117 |       119 |       121 |       124 |       137 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        61 |        68 |        70 |        70 |        70 |        74 |        79 |       500 |

