# Performance

Host:

* MacBook Pro (13-inch, 2017, Four Thunderbolt 3 Ports)
* 3.1 GHz Intel Core i5
* 8 GB 2133 MHz LPDDR3

## Comparison with Trailblazer

`Flows::Railway` does not support tracks and routes, so it's reasonable to compare with `Flows::Operation` only.

`WITH_OP=1 WITH_TB=1 bin/benchmark` results:

```
--------------------------------------------------
- task: A + B, one step implementation
--------------------------------------------------
Warming up --------------------------------------
Flows::Operation (build once)
                        25.356k i/100ms
Flows::Operation (build each time)
                         9.168k i/100ms
Trailblazer::Operation
                         5.016k i/100ms
Calculating -------------------------------------
Flows::Operation (build once)
                        277.460k (± 1.2%) i/s -      1.395M in   5.027011s
Flows::Operation (build each time)
                         95.740k (± 2.7%) i/s -    485.904k in   5.079226s
Trailblazer::Operation
                         52.975k (± 1.8%) i/s -    265.848k in   5.020109s

Comparison:
Flows::Operation (build once):   277459.5 i/s
Flows::Operation (build each time):    95739.6 i/s - 2.90x  slower
Trailblazer::Operation:    52974.6 i/s - 5.24x  slower


--------------------------------------------------
- task: ten steps returns successful result
--------------------------------------------------
Warming up --------------------------------------
Flows::Operation (build once)
                         3.767k i/100ms
Flows::Operation (build each time)
                         1.507k i/100ms
Trailblazer::Operation
                         1.078k i/100ms
Calculating -------------------------------------
Flows::Operation (build once)
                         37.983k (± 2.9%) i/s -    192.117k in   5.062658s
Flows::Operation (build each time)
                         14.991k (± 4.2%) i/s -     75.350k in   5.035443s
Trailblazer::Operation
                         10.897k (± 2.8%) i/s -     54.978k in   5.049665s

Comparison:
Flows::Operation (build once):    37982.8 i/s
Flows::Operation (build each time):    14990.6 i/s - 2.53x  slower
Trailblazer::Operation:    10896.9 i/s - 3.49x  slower
```

## Comparison with Dry::Transaction

`Dry::Transaction` does not support tracks and branching so it's reasonable to compare with `Flows::Railway` only.

`WITH_RW=1 WITH_DRY=1 bin/benchmark` results:

```
--------------------------------------------------
- task: A + B, one step implementation
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                        29.324k i/100ms
Flows::Railway (build each time)
                        11.159k i/100ms
Dry::Transaction (build once)
                        21.480k i/100ms
Dry::Transaction (build each time)
                         2.268k i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                        321.837k (± 1.3%) i/s -      1.613M in   5.012156s
Flows::Railway (build each time)
                        115.743k (± 2.6%) i/s -    580.268k in   5.016961s
Dry::Transaction (build once)
                        231.712k (± 1.7%) i/s -      1.160M in   5.007401s
Dry::Transaction (build each time)
                         23.093k (± 2.5%) i/s -    115.668k in   5.012311s

Comparison:
Flows::Railway (build once):   321837.4 i/s
Dry::Transaction (build once):   231712.5 i/s - 1.39x  slower
Flows::Railway (build each time):   115743.1 i/s - 2.78x  slower
Dry::Transaction (build each time):    23093.2 i/s - 13.94x  slower


--------------------------------------------------
- task: ten steps returns successful result
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                         5.607k i/100ms
Flows::Railway (build each time)
                         2.014k i/100ms
Dry::Transaction (build once)
                         2.918k i/100ms
Dry::Transaction (build each time)
                       275.000  i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                         57.765k (± 1.4%) i/s -    291.564k in   5.048484s
Flows::Railway (build each time)
                         20.413k (± 1.2%) i/s -    102.714k in   5.032467s
Dry::Transaction (build once)
                         29.597k (± 1.5%) i/s -    148.818k in   5.029422s
Dry::Transaction (build each time)
                          2.753k (± 2.0%) i/s -     14.025k in   5.096279s

Comparison:
Flows::Railway (build once):    57765.2 i/s
Dry::Transaction (build once):    29596.6 i/s - 1.95x  slower
Flows::Railway (build each time):    20413.0 i/s - 2.83x  slower
Dry::Transaction (build each time):     2753.2 i/s - 20.98x  slower
```

## Railway vs Operation

`Flows::Railway` is created to improve performance in situations when you don't need tracks, branching and shape control (`Flows::Operation` has this features). So, it should be faster than `Flows::Operation`.

`WITH_OP=1 WITH_RW=1 bin/benchmark` results:

```
--------------------------------------------------
- task: A + B, one step implementation
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                        29.440k i/100ms
Flows::Railway (build each time)
                        11.236k i/100ms
Flows::Operation (build once)
                        25.584k i/100ms
Flows::Operation (build each time)
                         9.161k i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                        315.648k (± 8.1%) i/s -      1.590M in   5.078736s
Flows::Railway (build each time)
                        117.747k (± 3.5%) i/s -    595.508k in   5.064191s
Flows::Operation (build once)
                        266.888k (±12.3%) i/s -      1.279M in   5.090531s
Flows::Operation (build each time)
                         91.424k (±11.0%) i/s -    458.050k in   5.097449s

Comparison:
Flows::Railway (build once):   315647.6 i/s
Flows::Operation (build once):   266888.4 i/s - same-ish: difference falls within error
Flows::Railway (build each time):   117747.2 i/s - 2.68x  slower
Flows::Operation (build each time):    91423.7 i/s - 3.45x  slower


--------------------------------------------------
- task: ten steps returns successful result
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                         5.619k i/100ms
Flows::Railway (build each time)
                         2.009k i/100ms
Flows::Operation (build once)
                         3.650k i/100ms
Flows::Operation (build each time)
                         1.472k i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                         58.454k (± 2.8%) i/s -    292.188k in   5.002833s
Flows::Railway (build each time)
                         20.310k (± 2.4%) i/s -    102.459k in   5.047579s
Flows::Operation (build once)
                         38.556k (± 2.5%) i/s -    193.450k in   5.020871s
Flows::Operation (build each time)
                         15.222k (± 2.8%) i/s -     76.544k in   5.032272s

Comparison:
Flows::Railway (build once):    58453.8 i/s
Flows::Operation (build once):    38556.5 i/s - 1.52x  slower
Flows::Railway (build each time):    20310.3 i/s - 2.88x  slower
Flows::Operation (build each time):    15221.9 i/s - 3.84x  slower
```

## Comparison with Plan Old Ruby Object

Of course, `flows` cannot be faster than naive implementation without any library usage. But it's nice to know how big infrastructure cost you pay.

`WITH_RW=1 WITH_PORO=1 bin/benchmark` results:

```
--------------------------------------------------
- task: A + B, one step implementation
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                        29.276k i/100ms
Flows::Railway (build each time)
                        11.115k i/100ms
                PORO   309.108k i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                        320.587k (± 3.5%) i/s -      1.610M in   5.029314s
Flows::Railway (build each time)
                        118.108k (± 3.0%) i/s -    600.210k in   5.086844s
                PORO      9.998M (± 2.1%) i/s -     50.075M in   5.010848s

Comparison:
                PORO:  9998276.0 i/s
Flows::Railway (build once):   320586.8 i/s - 31.19x  slower
Flows::Railway (build each time):   118108.5 i/s - 84.65x  slower


--------------------------------------------------
- task: ten steps returns successful result
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                         5.671k i/100ms
Flows::Railway (build each time)
                         2.024k i/100ms
                PORO   233.375k i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                         58.428k (± 1.6%) i/s -    294.892k in   5.048387s
Flows::Railway (build each time)
                         20.388k (± 3.9%) i/s -    103.224k in   5.070844s
                PORO      4.937M (± 0.6%) i/s -     24.738M in   5.010488s

Comparison:
                PORO:  4937372.3 i/s
Flows::Railway (build once):    58428.4 i/s - 84.50x  slower
Flows::Railway (build each time):    20387.7 i/s - 242.17x  slower
```

## All without PORO

`WITH_ALL=1 bin/benchmark` results:

```
--------------------------------------------------
- task: A + B, one step implementation
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                        29.351k i/100ms
Flows::Railway (build each time)
                        11.044k i/100ms
Flows::Operation (build once)
                        25.475k i/100ms
Flows::Operation (build each time)
                         8.989k i/100ms
Dry::Transaction (build once)
                        21.082k i/100ms
Dry::Transaction (build each time)
                         2.272k i/100ms
Trailblazer::Operation
                         4.962k i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                        299.326k (±15.6%) i/s -      1.409M in   5.012398s
Flows::Railway (build each time)
                        116.186k (± 3.1%) i/s -    585.332k in   5.042902s
Flows::Operation (build once)
                        276.980k (± 3.1%) i/s -      1.401M in   5.064018s
Flows::Operation (build each time)
                         94.536k (± 2.6%) i/s -    476.417k in   5.042967s
Dry::Transaction (build once)
                        229.750k (± 1.6%) i/s -      1.160M in   5.048211s
Dry::Transaction (build each time)
                         23.381k (± 1.9%) i/s -    118.144k in   5.054920s
Trailblazer::Operation
                         50.936k (± 4.4%) i/s -    258.024k in   5.075897s

Comparison:
Flows::Railway (build once):   299325.9 i/s
Flows::Operation (build once):   276979.8 i/s - same-ish: difference falls within error
Dry::Transaction (build once):   229749.5 i/s - 1.30x  slower
Flows::Railway (build each time):   116185.6 i/s - 2.58x  slower
Flows::Operation (build each time):    94536.3 i/s - 3.17x  slower
Trailblazer::Operation:    50936.0 i/s - 5.88x  slower
Dry::Transaction (build each time):    23380.8 i/s - 12.80x  slower


--------------------------------------------------
- task: ten steps returns successful result
--------------------------------------------------
Warming up --------------------------------------
Flows::Railway (build once)
                         5.734k i/100ms
Flows::Railway (build each time)
                         2.064k i/100ms
Flows::Operation (build once)
                         3.801k i/100ms
Flows::Operation (build each time)
                         1.502k i/100ms
Dry::Transaction (build once)
                         2.837k i/100ms
Dry::Transaction (build each time)
                       274.000  i/100ms
Trailblazer::Operation
                         1.079k i/100ms
Calculating -------------------------------------
Flows::Railway (build once)
                         58.541k (± 1.6%) i/s -    298.168k in   5.094712s
Flows::Railway (build each time)
                         20.626k (± 3.0%) i/s -    103.200k in   5.008021s
Flows::Operation (build once)
                         38.906k (± 2.7%) i/s -    197.652k in   5.084184s
Flows::Operation (build each time)
                         14.351k (±12.2%) i/s -     70.594k in   5.011606s
Dry::Transaction (build once)
                         29.588k (± 1.8%) i/s -    150.361k in   5.083603s
Dry::Transaction (build each time)
                          2.765k (± 1.8%) i/s -     13.974k in   5.054977s
Trailblazer::Operation
                         10.861k (± 2.1%) i/s -     55.029k in   5.069204s

Comparison:
Flows::Railway (build once):    58541.4 i/s
Flows::Operation (build once):    38906.4 i/s - 1.50x  slower
Dry::Transaction (build once):    29587.8 i/s - 1.98x  slower
Flows::Railway (build each time):    20626.0 i/s - 2.84x  slower
Flows::Operation (build each time):    14351.1 i/s - 4.08x  slower
Trailblazer::Operation:    10860.9 i/s - 5.39x  slower
Dry::Transaction (build each time):     2765.3 i/s - 21.17x  slower
```
