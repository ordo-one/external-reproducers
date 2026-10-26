
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     44422 |     44433 |     44433 |     44433 |     44433 |     45646 |     46299 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     21278 |     21299 |     21299 |     21299 |     21299 |     22184 |     22193 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     45910 |     45941 |     45941 |     45941 |     45941 |     47612 |     47612 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     35553 |     35586 |     35586 |     35586 |     35586 |     36962 |     37249 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1381 |      1415 |      1415 |      1415 |      1415 |      1415 |      1418 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1212 |      1246 |      1256 |      1256 |      1256 |      1256 |      1271 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2598 |      2609 |      2609 |      2871 |      2871 |      2871 |      2871 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1465 |      1509 |      1509 |      1509 |      1509 |      1509 |      1513 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1674 |      1696 |      1706 |      1720 |      1741 |      1785 |      1908 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       765 |       785 |       791 |       797 |       806 |       883 |       916 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      1691 |      1718 |      1736 |      1754 |      1768 |      1942 |      1960 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1312 |      1331 |      1337 |      1347 |      1370 |      1492 |      1510 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        62 |        65 |        65 |        66 |        66 |        69 |        73 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        51 |        58 |        59 |        59 |        60 |        64 |        68 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |       102 |       111 |       112 |       127 |       128 |       140 |       148 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        64 |        70 |        70 |        70 |        71 |        76 |        85 |       500 |

