
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     45022 |     45056 |     45056 |     45056 |     45056 |     46268 |     46908 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     21278 |     21299 |     21299 |     21299 |     21316 |     22184 |     22189 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     45138 |     45154 |     45154 |     45154 |     45154 |     46843 |     46843 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     35793 |     35815 |     35815 |     35815 |     35815 |     37177 |     37177 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1371 |      1415 |      1415 |      1415 |      1417 |      1442 |      1442 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1246 |      1256 |      1256 |      1256 |      1256 |      1256 |      1260 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2388 |      2398 |      2398 |      2660 |      2660 |      2660 |      2660 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1465 |      1509 |      1509 |      1509 |      1509 |      1509 |      1513 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1870 |      1940 |      1953 |      1981 |      2004 |      2042 |      2098 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       793 |       863 |       867 |       875 |       885 |       906 |       946 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      1717 |      1891 |      1908 |      1924 |      1938 |      1977 |      2023 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1354 |      1469 |      1486 |      1496 |      1529 |      1580 |      1587 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        53 |        62 |        64 |        65 |        67 |        72 |        74 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        48 |        55 |        56 |        57 |        58 |        60 |        67 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |       100 |       104 |       106 |       121 |       123 |       125 |       129 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        63 |        67 |        68 |        69 |        69 |        72 |        74 |       500 |

