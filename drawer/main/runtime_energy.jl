include("../settings.jl")

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (800, 500), fontsize = 20)

    # y-axis baseline 10^{-1}s so very fast bars (e.g. BBTN, RKSG N=60) remain visible.
    y_baseline = -1

    ax = Axis(fig[1, 1],
        ylabel = L"\text{Runtime (s)}",
        xticks = (1:5, ["RKSG\nN=60", "RKSG\nN=70", "RKSG\nN=80", "MKSG\nStructured", "MKSG\nRandom"]),
        yticks = (y_baseline:7, [L"10^{-1}", L"10^0", L"10^1", L"10^2", L"10^3",
                                 L"10^4", L"10^5", L"10^6", L"10^7"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 16, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df = CSV.read("../../data/main/runtime/mis/summary_all_methods.csv", DataFrame)

    graphs        = ["ksg60", "ksg70", "ksg80", "fact_structured", "fact_random"]
    methods       = ["BBTN", "TN_with_Slicing", "SCIP", "CPLEX"]
    method_labels = Dict("BBTN" => "BBTN", "TN_with_Slicing" => "TN with Slicing",
                         "SCIP" => "SCIP", "CPLEX" => "CPLEX")
    method_color_list = [method_colors[m] for m in methods]

    cat        = Int[]
    bar_grp    = Int[]
    mean_times = Float64[]
    min_times  = Float64[]
    max_times  = Float64[]
    for (gi, g) in enumerate(graphs)
        for (mi, m) in enumerate(methods)
            row = df[(df.graph .== g) .& (df.method .== m), :]
            if nrow(row) == 0
                continue
            end
            push!(cat, gi)
            push!(bar_grp, mi)
            push!(mean_times, row.runtime_median[1])
            push!(min_times,  row.runtime_min[1])
            push!(max_times,  row.runtime_max[1])
        end
    end

    # Cap extreme values so the bar plot remains readable.
    max_time = 1e7
    mean_times = map(x -> x > max_time ? max_time : x, mean_times)
    min_times  = map(x -> x > max_time ? max_time : x, min_times)
    max_times  = map(x -> x > max_time ? max_time : x, max_times)

    barplot!(ax, cat, log10.(mean_times), dodge = bar_grp,
             color = method_color_list[bar_grp], strokecolor = :black, strokewidth = 1,
             fillto = y_baseline)

    dodge_width = 0.8
    bar_width = dodge_width / length(methods)
    for i in 1:length(cat)
        x_pos = cat[i] + (bar_grp[i] - (length(methods) + 1) / 2) * bar_width
        y_min = log10(min_times[i])
        y_max = log10(max_times[i])

        lines!(ax, [x_pos, x_pos], [y_min, y_max], color = :black, linewidth = 1)
        cap_width = 0.04
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_min, y_min], color = :black, linewidth = 1)
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_max, y_max], color = :black, linewidth = 1)
    end

    ylims!(ax, y_baseline, 7)

    one_hour = log10(3600)
    one_day  = log10(24 * 3600)
    one_week = log10(7 * 24 * 3600)

    hlines!(ax, [one_hour], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [one_day],  color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [one_week], color = :black, linestyle = :dash, linewidth = 1)

    text!(ax, 0.05, one_hour, text = L"$1$ hour", fontsize = 22, color = :black)
    text!(ax, 0.05, one_day,  text = L"$1$ day",  fontsize = 22, color = :black)
    text!(ax, 0.05, one_week, text = L"$1$ week", fontsize = 22, color = :black)

    xlims!(ax, 0, 6)

    legend_dict = Dict{String, Any}()
    for m in methods
        legend_dict[method_labels[m]] = PolyElement(polycolor = method_colors[m])
    end
    labels_order = [method_labels[m] for m in methods]
    legend_items = [legend_dict[l] for l in labels_order]
    Legend(fig[0, 1], legend_items, labels_order,
           labelsize = 20, orientation = :horizontal,
           nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/runtime_energy.pdf", fig)
    fig
end
