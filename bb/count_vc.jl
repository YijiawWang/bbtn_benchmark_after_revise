using CSV, DataFrames

# 0: deg1+dominance+fold2, 2:unconfined+twin+funnel+desk, 3:packing, 4:LP
function count_vc(n, i, reduction_label::Int)

    # problem_path = joinpath(dirname(@__DIR__), "bb/edges", "ksg_n$(n)_$(i).txt")
    problem_path = joinpath(dirname(@__DIR__), "bb/edges", "additional_ksg_n$(n)_$(i).txt")

    vc_binary = joinpath(homedir(), "repos", "vertex_cover", "bin")
    temp_dir = joinpath(homedir(), "temp/vc/"); 
    mkpath(temp_dir)

    vc_output_filepath = joinpath(temp_dir, "ksg_n$(n)_$(i).log")
    vc_out = read(`java -cp $vc_binary Main -r $reduction_label -l 0 $problem_path "2>&1 |" tee $vc_output_filepath`, String) |> x -> split(x, "\n")[1] |> split |> x -> x[3] |> x -> parse(Int, x) + 1

    return vc_out
end

function count_all(n)
    csv_file = joinpath(dirname(@__DIR__), "data/count_vc", "additional_ksg_n$(n)_count_vc.csv")
    @info "Writing to $csv_file"
    # CSV.write(csv_file, DataFrame(id = Int[], count = Int[], time = Float64[]))
    counts = zeros(Int, 50)
    times = zeros(Float64, 50)
    Threads.@threads for i in 1:50
        # count_pack = count_vc(n, i, 3)
        # @info "ksg_n$(n)_$(i), count_pack = $count_pack"
        start_time = time()
        count_lp = count_vc(n, i, 4)
        times[i] = time() - start_time
        @info "ksg_n$(n)_$(i), count_lp = $count_lp, time = $(times[i])"
        counts[i] = count_lp
    end
    CSV.write(csv_file, DataFrame(id = 1:50, count = counts, time = times))
    @info "Done"
end


function main()
    for n in [30, 35, 40, 45, 50]
        count_all(n)
    end
end

main()