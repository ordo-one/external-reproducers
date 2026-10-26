
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     43104 |     43123 |     43123 |     43123 |     43123 |     44040 |     44686 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     20353 |     20365 |     20365 |     20382 |     20382 |     21103 |     21111 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     43765 |     43778 |     43811 |     43811 |     43811 |     45154 |     45178 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     34284 |     34308 |     34308 |     34308 |     34308 |     35357 |     35367 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1405 |      1415 |      1415 |      1415 |      1415 |      1415 |      1441 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1282 |      1326 |      1326 |      1326 |      1326 |      1326 |      1326 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2388 |      2398 |      2433 |      2660 |      2660 |      2660 |      2664 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1675 |      1686 |      1719 |      1719 |      1719 |      1733 |      1738 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1749 |      1867 |      1889 |      1911 |      1936 |      2025 |      2060 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       823 |       843 |       852 |       864 |       882 |       900 |       917 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      1833 |      1880 |      1890 |      1928 |      1943 |      1953 |      1963 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1286 |      1433 |      1452 |      1466 |      1486 |      1508 |      1570 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        60 |        63 |        64 |        65 |        66 |        68 |        72 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        53 |        57 |        58 |        59 |        59 |        60 |        63 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |       101 |       105 |       108 |       122 |       124 |       126 |       128 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        69 |        74 |        76 |        77 |        77 |        80 |        84 |       500 |

