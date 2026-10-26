
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     44323 |     44335 |     44335 |     44335 |     44368 |     45548 |     46212 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     21281 |     21299 |     21299 |     21299 |     21299 |     22184 |     22189 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     45301 |     45318 |     45318 |     45318 |     45318 |     47002 |     47002 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     35556 |     35586 |     35586 |     35586 |     35586 |     36940 |     36940 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1371 |      1415 |      1415 |      1415 |      1415 |      1415 |      1431 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1212 |      1256 |      1256 |      1256 |      1256 |      1256 |      1259 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2388 |      2398 |      2398 |      2660 |      2660 |      2660 |      2664 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1475 |      1509 |      1509 |      1509 |      1509 |      1509 |      1522 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1842 |      1872 |      1894 |      1913 |      1928 |      1965 |      2001 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       841 |       869 |       875 |       885 |       901 |       927 |       933 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      1759 |      1884 |      1906 |      1930 |      1956 |      2001 |      2039 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1447 |      1464 |      1489 |      1505 |      1514 |      1544 |      1576 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        58 |        63 |        64 |        68 |        69 |        71 |        73 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        52 |        56 |        56 |        57 |        58 |        62 |        85 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |        99 |       104 |       105 |       121 |       123 |       126 |       127 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        62 |        66 |        68 |        69 |        69 |        71 |        72 |       500 |

