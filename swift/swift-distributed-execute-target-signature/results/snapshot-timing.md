
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     44523 |     44564 |     44564 |     44564 |     44564 |     45744 |     46409 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     21281 |     21299 |     21299 |     21299 |     21299 |     22184 |     22189 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     45421 |     45449 |     45449 |     45449 |     45449 |     47120 |     47125 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     35916 |     35946 |     35946 |     35946 |     35946 |     37303 |     37303 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1371 |      1415 |      1415 |      1415 |      1415 |      1415 |      1423 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1282 |      1326 |      1326 |      1326 |      1326 |      1326 |      1336 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2388 |      2398 |      2398 |      2660 |      2660 |      2660 |      2664 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1465 |      1509 |      1509 |      1509 |      1509 |      1509 |      1513 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1678 |      1698 |      1709 |      1723 |      1761 |      1910 |      1928 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       769 |       779 |       785 |       793 |       829 |       879 |       887 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      1686 |      1707 |      1714 |      1727 |      1750 |      1804 |      1973 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1326 |      1346 |      1362 |      1380 |      1398 |      1514 |      1558 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        56 |        63 |        63 |        64 |        65 |        67 |        88 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        49 |        59 |        59 |        60 |        60 |        65 |        67 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |       100 |       106 |       108 |       119 |       121 |       128 |       143 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        63 |        68 |        68 |        70 |        70 |        72 |        78 |       500 |

