
## Baseline 'Current_run'

```
Host 'ice.local' with 16 'arm64' processors with 128 GB memory, running:
Darwin Kernel Version 27.0.0: Tue Aug 11 21:05:48 PDT 2026; root:xnu-13432.1.9~1/RELEASE_ARM64_T6041
```
### Instructions

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic *             |     52024 |     52036 |     52036 |     52036 |     52068 |     53674 |     54161 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs *              |     22204 |     22217 |     22217 |     22217 |     22233 |     23183 |     23183 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray *      |     54706 |     54723 |     54723 |     54723 |     54723 |     56590 |     56598 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts *             |     44201 |     44237 |     44237 |     44237 |     44237 |     45776 |     45776 |       500 |
| ExecuteDistributedTarget:handWritten generic *                          |      1419 |      1430 |      1464 |      1464 |      1464 |      1474 |      1477 |       500 |
| ExecuteDistributedTarget:handWritten noArgs *                           |      1277 |      1287 |      1287 |      1287 |      1287 |      1300 |      1301 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray *                   |      2617 |      2628 |      2628 |      2904 |      2904 |      2904 |      2908 |       500 |
| ExecuteDistributedTarget:handWritten twoInts *                          |      1518 |      1563 |      1563 |      1563 |      1563 |      1565 |      1588 |       500 |

### Time (wall clock)

| Test                                                                    |        p0 |       p25 |       p50 |       p75 |       p90 |       p99 |      p100 |   Samples |
|:------------------------------------------------------------------------|----------:|----------:|----------:|----------:|----------:|----------:|----------:|----------:|
| ExecuteDistributedTarget:executeDistributedTarget generic (ns) *        |      1939 |      2261 |      2294 |      2341 |      2365 |      2421 |      2498 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget noArgs (ns) *         |       866 |       955 |       965 |       995 |      1033 |      1060 |      1066 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget stringAndArray (ns) * |      2272 |      2329 |      2374 |      2402 |      2435 |      2501 |      2557 |       500 |
| ExecuteDistributedTarget:executeDistributedTarget twoInts (ns) *        |      1714 |      1801 |      1829 |      1858 |      1945 |      2122 |      2143 |       500 |
| ExecuteDistributedTarget:handWritten generic (ns) *                     |        66 |        68 |        70 |        71 |        71 |        73 |        76 |       500 |
| ExecuteDistributedTarget:handWritten noArgs (ns) *                      |        58 |        59 |        62 |        62 |        63 |        66 |        79 |       500 |
| ExecuteDistributedTarget:handWritten stringAndArray (ns) *              |       119 |       125 |       129 |       151 |       154 |       159 |       164 |       500 |
| ExecuteDistributedTarget:handWritten twoInts (ns) *                     |        70 |        72 |        74 |        75 |        75 |        77 |        79 |       500 |

