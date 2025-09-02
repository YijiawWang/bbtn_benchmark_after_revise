using CSV, DataFrames

function collect_rksg_runtime(n)
    dir = @__DIR__
    df = joinpath(dir, "../data/runtime/ksg_n$(n)_runtime_all.csv")
    CSV.write(df, DataFrame(name = String[], scip_runtime = Float64[], sc = Float64[], ds_nslice = Float64[], ds_tc = Float64[], ds_slice_runtime = Float64[], ds_contract_runtime = Float64[], tnbb_nbranch = Float64[], tnbb_tc = Float64[], tnbb_branch_runtime = Float64[], tnbb_contract_runtime = Float64[]))

    for i in 1:10
        df_scip = joinpath(dir, "../data/runtime/ksg_n$(n)_scip.csv")
        df_ds_branch = joinpath(dir, "../data/runtime/ksg_n$(n)_sc31_ds_branch.csv")
        df_ds_contract = joinpath(dir, "../data/runtime/ksg_n$(n)_slice31_ds_contract.csv")
        df_tnbb_branch = joinpath(dir, "../data/runtime/ksg_n$(n)_sc31_tnbb_branch.csv")
        df_tnbb_contract = joinpath(dir, "../data/runtime/ksg_n$(n)_sc31_tnbb_contract.csv")

        df_scip = CSV.read(df_scip, DataFrame)
        df_ds_branch = CSV.read(df_ds_branch, DataFrame)
        df_ds_contract = CSV.read(df_ds_contract, DataFrame)
        df_tnbb_branch = CSV.read(df_tnbb_branch, DataFrame)
        df_tnbb_contract = CSV.read(df_tnbb_contract, DataFrame)

        scip_runtime = df_scip[df_scip.name .== i, :runtime][1]
        sc = df_ds_branch[df_ds_branch.name .== i, :original_sc][1]
        ds_nslice = df_ds_branch[df_ds_branch.name .== i, :nslice][1]
        ds_tc = df_ds_branch[df_ds_branch.name .== i, :total_tc][1]
        ds_slice_runtime = df_ds_branch[df_ds_branch.name .== i, :runtime][1]
        ds_contract_runtime = df_ds_contract[df_ds_contract.name .== i, :runtime][1]
        tnbb_nbranch = df_tnbb_branch[df_tnbb_branch.name .== i, :num_branch][1]
        tnbb_tc = df_tnbb_branch[df_tnbb_branch.name .== i, :total_tc][1]
        tnbb_branch_runtime = df_tnbb_branch[df_tnbb_branch.name .== i, :runtime][1]
        tnbb_contract_runtime = df_tnbb_contract[df_tnbb_contract.name .== i, :runtime][1]

        CSV.write(df, DataFrame(name = i, scip_runtime = scip_runtime, sc = sc, ds_nslice = ds_nslice, ds_tc = ds_tc, ds_slice_runtime = ds_slice_runtime, ds_contract_runtime = ds_contract_runtime, tnbb_nbranch = tnbb_nbranch, tnbb_tc = tnbb_tc, tnbb_branch_runtime = tnbb_branch_runtime, tnbb_contract_runtime = tnbb_contract_runtime), append = true)
    end
end

collect_rksg_runtime(70)