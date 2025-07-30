using Graphs, GraphIO
using JuMP, SCIP
using CSV, DataFrames

function ip_mis(g::AbstractGraph; optimizer=SCIP.Optimizer, verbose::Bool=false)
    model = Model(optimizer)
    !verbose && set_silent(model)
    n = nv(g)
    @variable(model, 0 <= x[i = 1:n] <= 1, Int)
    @objective(model, Max, sum(x))
    for e in edges(g)
        @constraint(model, x[src(e)] + x[dst(e)] <= 1)
    end
    optimize!(model)
    @assert is_solved_and_feasible(model)
    return Int(round(sum(value.(x))))
end

function scip_kernelized_runtime(n)
    dir = @__DIR__
    df = joinpath(dir, "../data/runtime/ksg_n70_kernelized_scip.csv") # try the kernelized graphs first
    CSV.write(df, DataFrame(name = String[], runtime = Float64[]))

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/kernelized_tn_ksg_n$(n).dot"))

    for i in 1:10
        g = graphs["$i"]
        t = @elapsed ip_mis(g, verbose = true)
        @show i, t
        CSV.write(df, DataFrame(name = i, runtime = t), append = true)
    end
end

function scip_runtime(n)
    dir = @__DIR__
    df = joinpath(dir, "../data/runtime/ksg_n70_scip.csv") # unkernelized graphs
    CSV.write(df, DataFrame(name = String[], runtime = Float64[]))

    graphs = loadgraphs(joinpath(dir, "../graphs/random_ksg/ksg_n$(n).dot"))

    for i in [2, 3, 4, 5, 7, 9, 10]
        g = graphs["$i"]
        t = @elapsed ip_mis(g, verbose = true)
        @show i, t
        CSV.write(df, DataFrame(name = i, runtime = t), append = true)
    end
end

scip_runtime(70)