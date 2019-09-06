# Performance

TODO: add comments abount benchmark purpose. Which goals we want to achieve when working on performance.

## Benchmark Results

Host:

* MacBook Pro (13-inch, 2017, Four Thunderbolt 3 Ports)
* 3.1 GHz Intel Core i5
* 8 GB 2133 MHz LPDDR3

`bin/benchmark` results:

```text
--------------------------------------------------
- task: A + B, one step implementation
--------------------------------------------------
Warming up --------------------------------------
Flows::Operation (build each time)
                         9.147k i/100ms
Flows::Operation (build once)
                        25.738k i/100ms
Dry::Transaction (build each time)
                         2.294k i/100ms
Dry::Transaction (build once)
                        21.836k i/100ms
Trailblazer::Operation
                         5.057k i/100ms
Calculating -------------------------------------
Flows::Operation (build each time)
                         96.095k (± 2.3%) i/s -    484.791k in   5.047684s
Flows::Operation (build once)
                        281.248k (± 1.7%) i/s -      1.416M in   5.034728s
Dry::Transaction (build each time)
                         23.683k (± 1.7%) i/s -    119.288k in   5.038506s
Dry::Transaction (build once)
                        237.379k (± 3.3%) i/s -      1.201M in   5.066073s
Trailblazer::Operation
                         52.676k (± 1.5%) i/s -    268.021k in   5.089306s

Comparison:
Flows::Operation (build once):   281248.4 i/s
Dry::Transaction (build once):   237378.7 i/s - 1.18x  slower
Flows::Operation (build each time):    96094.9 i/s - 2.93x  slower
Trailblazer::Operation:    52676.3 i/s - 5.34x  slower
Dry::Transaction (build each time):    23682.9 i/s - 11.88x  slower


--------------------------------------------------
- task: ten steps returns successful result
--------------------------------------------------
Warming up --------------------------------------
Flows::Operation (build each time)
                         1.496k i/100ms
Flows::Operation (build once)
                         3.847k i/100ms
Dry::Transaction (build each time)
                       274.000  i/100ms
Dry::Transaction (build once)
                         2.992k i/100ms
Trailblazer::Operation
                         1.082k i/100ms
Calculating -------------------------------------
Flows::Operation (build each time)
                         15.013k (± 3.8%) i/s -     76.296k in   5.089734s
Flows::Operation (build once)
                         39.239k (± 1.6%) i/s -    196.197k in   5.001538s
Dry::Transaction (build each time)
                          2.743k (± 3.7%) i/s -     13.700k in   5.002847s
Dry::Transaction (build once)
                         30.441k (± 1.8%) i/s -    152.592k in   5.014565s
Trailblazer::Operation
                         11.022k (± 1.4%) i/s -     55.182k in   5.007543s

Comparison:
Flows::Operation (build once):    39238.6 i/s
Dry::Transaction (build once):    30440.5 i/s - 1.29x  slower
Flows::Operation (build each time):    15012.7 i/s - 2.61x  slower
Trailblazer::Operation:    11022.1 i/s - 3.56x  slower
Dry::Transaction (build each time):     2743.0 i/s - 14.30x  slower
```
