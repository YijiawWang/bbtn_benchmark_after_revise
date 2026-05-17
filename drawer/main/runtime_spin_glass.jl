include("../settings.jl")

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (900, 500), fontsize = 20)

    L_values = [10, 20, 30, 40, 50, 60]

    # The top spine itself marks the time limit; label it directly above the spine.
    limit_color = "#8B0000"

    ax = Axis(fig[1, 1],
        xlabel = L"L", ylabel = L"\text{Runtime (s)}",
        xticks = (1:length(L_values), [LaTeXString("L=$L") for L in L_values]),
        yticks = (0:5, [L"10^0", L"10^1", L"10^2", L"10^3", L"10^4", L"10^5"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 18, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
        title = L"\text{time limit} = 1\text{ week}",
        titlecolor = limit_color, titlefont = :bold,
        titlesize = 20, titlealign = :left, titlegap = 4,
    )

    df = CSV.read("../../data/main/runtime/spin_glass/all_method_summary.csv", DataFrame)

    # 文件中的 method 名称小写 -> 对应 method_colors 中的 key
    methods             = ["bbtn", "slicing", "cplex"]
    method_color_keys   = Dict("bbtn" => "BBTN", "slicing" => "TN_with_Slicing", "cplex" => "CPLEX")
    method_legend_label = Dict("bbtn" => "BBTN", "slicing" => "TN with Slicing", "cplex" => "CPLEX")
    method_color_list   = [method_colors[method_color_keys[m]] for m in methods]

    cat        = Int[]
    bar_grp    = Int[]
    mean_times = Float64[]
    min_times  = Float64[]
    max_times  = Float64[]
    for (gi, L) in enumerate(L_values)
        for (mi, m) in enumerate(methods)
            row = df[(df.L .== L) .& (df.method .== m), :]
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

    # Cap at 1 week — anything that takes longer than 1 week is treated as "out of budget".
    max_time = 7 * 24 * 3600.0  # 1 week in seconds
    mean_times = map(x -> x > max_time ? max_time : x, mean_times)
    min_times  = map(x -> x > max_time ? max_time : x, min_times)
    max_times  = map(x -> x > max_time ? max_time : x, max_times)

    barplot!(ax, cat, log10.(mean_times), dodge = bar_grp,
             color = method_color_list[bar_grp], strokecolor = :black, strokewidth = 1)

    dodge_width = 0.8
    bar_width = dodge_width / length(methods)
    for i in 1:length(cat)
        x_pos = cat[i] + (bar_grp[i] - (length(methods) + 1) / 2) * bar_width
        y_min = log10(min_times[i])
        y_max = log10(max_times[i])

        lines!(ax, [x_pos, x_pos], [y_min, y_max], color = :black, linewidth = 1)
        cap_width = 0.05
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_min, y_min], color = :black, linewidth = 1)
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_max, y_max], color = :black, linewidth = 1)
    end

    # The top axis spine itself is the 1-week time limit — anything beyond is out of budget.
    ylims!(ax, 0, log10(max_time))

    one_hour = log10(3600)
    one_day  = log10(24 * 3600)
    one_week = log10(7 * 24 * 3600)

    hlines!(ax, [one_hour], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [one_day],  color = :black, linestyle = :dash, linewidth = 1)

    text!(ax, 0.05, one_hour, text = L"$1$ hour", fontsize = 22, color = :black)
    text!(ax, 0.05, one_day,  text = L"$1$ day",  fontsize = 22, color = :black)


    xlims!(ax, 0, length(L_values) + 1)

    legend_dict = Dict{String, Any}()
    for m in methods
        legend_dict[method_legend_label[m]] = PolyElement(polycolor = method_colors[method_color_keys[m]])
    end
    labels_order = [method_legend_label[m] for m in methods]
    legend_items = [legend_dict[l] for l in labels_order]
    Legend(fig[0, 1], legend_items, labels_order,
           labelsize = 20, orientation = :horizontal,
           nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/runtime_spin_glass.pdf", fig)
    fig
end
