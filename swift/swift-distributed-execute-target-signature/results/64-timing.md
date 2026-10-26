
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     52024 |     52036 |     52036 |     52036 |     52068 |     53641 |     54152 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     22204 |     22217 |     22217 |     22217 |     22217 |     23183 |     23183 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     54532 |     54559 |     54559 |     54559 |     54559 |     56490 |     56490 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     44201 |     44237 |     44237 |     44237 |     44237 |     45776 |     45776 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1419 |      1455 |      1464 |      1464 |      1464 |      1464 |      1466 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1277 |      1287 |      1287 |      1287 |      1287 |      1287 |      1287 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2617 |      2628 |      2632 |      2904 |      2904 |      2904 |      2906 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1518 |      1563 |      1563 |      1563 |      1563 |      1563 |      1566 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      2003 |      2028 |      2040 |      2053 |      2077 |      2290 |      2398 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       877 |       903 |       911 |       922 |       940 |      1027 |      1033 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      1986 |      2059 |      2120 |      2183 |      2226 |      2458 |      2492 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1631 |      1678 |      1711 |      1808 |      1863 |      2000 |      2031 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        67 |        70 |        70 |        71 |        72 |        74 |        82 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        56 |        63 |        63 |        64 |        64 |        66 |        70 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |       112 |       117 |       132 |       142 |       145 |       148 |       156 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        65 |        73 |        74 |        74 |        75 |        80 |        83 |       500 |

