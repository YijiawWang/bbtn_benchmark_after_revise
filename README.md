# tnbb_benchmark
Benchmark results of tensor network branch and bound

## Paper figure model and data mapping

The data used to draw these figures is loaded by
`drawer/grouping_subgraphs.jl`.

### Fig. 2

- Upper panel models: `models/spin_glass_models/2dgrid`
- Upper panel data: `data/spin_glass_counting/lattice_J+-1_h_05.csv`
- Bottom panel models:
  - `models/spin_glass_models/3dgrid`
  - `models/spin_glass_models/rrg`
  - `models/mis_graphs/n60ksg_for_counting`
- Bottom panel data: `data/ground_state_counting/tc_ground_counting.csv`

### Fig. 3

- Upper panel models: `models/mis_graphs/random_ksg`
- Upper panel data:
  - `data/complexity/random_ksg/original_ksg_n{50,60,70,80,90,100}.csv`
  - `data/complexity/random_ksg/slice32_rksg_n{50,60,70,80,90,100}.csv`
  - `data/complexity/random_ksg/tnbb_ksg_n{50,60,70,80,90,100}.csv`
- Bottom panel models:
  - `models/mis_graphs/random_ksg`
  - `models/mis_graphs/fact_map_ksg`
- Bottom panel data:
  - `data/runtime/ksg_n60_runtime_all.csv`
  - `data/runtime/ksg_n70_runtime_all.csv`
  - `data/runtime/ksg_n80_runtime_all.csv`
  - `data/runtime/fact_k16_tnbb_ds_scip.csv`
