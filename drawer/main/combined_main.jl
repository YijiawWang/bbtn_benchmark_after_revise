include("../settings.jl")

# Combined figure:
#   Row 1: (a) tc_counting_scailing, (b) tc_counting_multi_types, (c) tc_energy_scailing
#   Row 2: (d) runtime_spin_glass,   (e) runtime_energy

# --------------------------- subplot builders ---------------------------

function build_tc_counting_scailing!(parent)
    t = 15

    xtick_positions = collect(5:5:70)
    xtick_labels = [x in [10, 20, 30, 35, 40, 45, 50, 55, 60, 65, 70] ? LaTeXString("$x") : "" for x in xtick_positions]
    ax = Axis(parent[1, 1],
        xlabel = L"N", ylabel = L"t.c.\text{(Flops)}",
        xticks = (xtick_positions, xtick_labels),
        yticks = (0:5:40, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$",
                           L"$10^{20}$", L"$10^{25}$", L"$10^{30}$", L"$10^{35}$", L"$10^{40}$"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df_spin = CSV.read("../../data/main/complexity/spin_glass_counting/lattice_J+-1_h_05.csv",
                       DataFrame, missingstring=["-", ""])

    n_vals = Int[]
    total_tc_mean_vals = Float64[]
    total_tc_slicing_mean_vals = Float64[]
    for i in 1:nrow(df_spin)
        tc_mean_val = df_spin.total_tc_mean[i]
        tc_slicing_val = df_spin.total_tc_slicing_mean[i]
        if !ismissing(tc_mean_val) && !ismissing(tc_slicing_val) &&
           !isnan(tc_mean_val) && !isnan(tc_slicing_val) &&
           isfinite(tc_mean_val) && isfinite(tc_slicing_val) &&
           tc_mean_val > 0 && tc_slicing_val > 0
            transformed_mean = log10(2^tc_mean_val)
            transformed_slicing = log10(2^tc_slicing_val)
            if isfinite(transformed_mean) && isfinite(transformed_slicing)
                push!(n_vals, df_spin.n[i])
                push!(total_tc_mean_vals, transformed_mean)
                push!(total_tc_slicing_mean_vals, transformed_slicing)
            end
        end
    end

    for i in 1:length(n_vals)
        if n_vals[i] <= 30
            total_tc_mean_vals[i] = total_tc_slicing_mean_vals[i]
        end
    end

    pure_tn_tc_vals = Float64[]
    n_pure_tn_vals = Int[]
    for i in 1:nrow(df_spin)
        val = df_spin.pure_tn_tc[i]
        if !ismissing(val) && !isnan(val) && isfinite(val) && val > 0
            transformed_val = log10(2^val)
            if isfinite(transformed_val)
                push!(n_pure_tn_vals, df_spin.n[i])
                push!(pure_tn_tc_vals, transformed_val)
            end
        end
    end

    model_power(x, p) = p[1] .* exp.(p[2] .* log.(max.(x, 0.1))) .+ p[3]
    @. model_tn(x, p) = p[1] * x + p[2]

    fit_slicing = nothing
    n_vals_slicing = length(n_vals) > 6 ? n_vals[7:end] : Int[]
    total_tc_slicing_mean_vals_slicing = length(total_tc_slicing_mean_vals) > 6 ? total_tc_slicing_mean_vals[7:end] : Float64[]
    if length(n_vals_slicing) >= 3
        weights_slicing = ones(length(n_vals_slicing))
        max_n_slicing = maximum(n_vals_slicing)
        max_idx_slicing = findfirst(==(max_n_slicing), n_vals_slicing)
        if max_idx_slicing !== nothing
            weights_slicing[max_idx_slicing] = 5.0
        end
        fit_slicing = curve_fit(model_power, n_vals_slicing, total_tc_slicing_mean_vals_slicing,
                                weights_slicing, [1.0, 1.0, 1.0])
    end

    fit_tn = nothing
    if length(n_pure_tn_vals) >= 2
        valid_indices = [i for i in 1:length(pure_tn_tc_vals) if isfinite(pure_tn_tc_vals[i]) && isfinite(n_pure_tn_vals[i])]
        if length(valid_indices) >= 2
            n_pure_tn_vals_filtered = n_pure_tn_vals[valid_indices]
            pure_tn_tc_vals_filtered = pure_tn_tc_vals[valid_indices]
            fit_tn = curve_fit(model_tn, n_pure_tn_vals_filtered, pure_tn_tc_vals_filtered, [1.0, 1.0])
        end
    end

    n_vals_tc_plot = length(n_vals) > 6 ? n_vals[7:end] : Int[]
    total_tc_mean_vals_plot = length(total_tc_mean_vals) > 6 ? total_tc_mean_vals[7:end] : Float64[]
    sc_tc = scatter!(ax, n_vals_tc_plot, total_tc_mean_vals_plot,
                     markersize = t * 1.0, marker = markerstyle[2],
                     color = method_colors["BBTN"], strokewidth = 1.0, strokecolor = :black,
                     label = "BBTN")

    if length(n_vals_slicing) > 0 && fit_slicing !== nothing
        x_min = 35
        x_max = maximum(n_vals_slicing) + 4.5
        xs = range(x_min, x_max, length = 100)
        lines!(ax, xs, model_power(xs, fit_slicing.param),
               color = method_colors["TN_with_Slicing"], linestyle = :solid, linewidth = 2)
    end

    sc_tc_slicing = scatter!(ax, n_vals_slicing, total_tc_slicing_mean_vals_slicing,
                             markersize = t * 1.0, marker = markerstyle[3],
                             color = method_colors["TN_with_Slicing"], strokewidth = 1.0, strokecolor = :black,
                             label = "TN with Slicing")

    if length(n_pure_tn_vals) > 0 && fit_tn !== nothing
        x_min_tn = 20
        x_max_tn = maximum(n_pure_tn_vals) + 4.5
        xs_tn = range(x_min_tn, x_max_tn, length = 100)
        lines!(ax, xs_tn, model_tn(xs_tn, fit_tn.param),
               color = method_colors["TN"], linestyle = :dash, linewidth = 2)
    end

    sc_pure_tn_main = nothing
    if length(n_pure_tn_vals) > 0
        n_pure_tn_main = Int[]
        pure_tn_tc_main = Float64[]
        for i in 1:length(n_pure_tn_vals)
            if n_pure_tn_vals[i] > 20
                push!(n_pure_tn_main, n_pure_tn_vals[i])
                push!(pure_tn_tc_main, pure_tn_tc_vals[i])
            end
        end
        if length(n_pure_tn_main) > 0
            sc_pure_tn_main = scatter!(ax,
                n_pure_tn_main, pure_tn_tc_main,
                markersize = t * 1.0, marker = :utriangle,
                color = method_colors["TN"], strokewidth = 1.0, strokecolor = :black)
        end
    end

    if length(n_vals_slicing) > 0
        n_start = minimum(n_vals_slicing) - 4.5
        n_end = maximum(n_vals_slicing) + 4.5
    else
        n_start = 0
        n_end = 100
    end
    xlims!(ax, n_start, n_end)
    ylims!(ax, 10, 40)

    hlines!(ax, tc_min - log10(2), color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, n_start + 1, tc_min - log10(2), text = L"$1$ min", color = :black, fontsize = 22)
    hlines!(ax, [tc_month - log10(2)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, n_start + 1, tc_month - log10(2), text = L"$1$ month", color = :black, fontsize = 22)
    hlines!(ax, [tc_1000000_years - log10(2)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, n_start + 1, tc_1000000_years - log10(2), text = L"$10^6$ years", color = :black, fontsize = 22)

    legend_dict = Dict{String, Any}()
    legend_dict["BBTN"] = sc_tc
    legend_dict["TN with Slicing"] = sc_tc_slicing
    if sc_pure_tn_main !== nothing
        legend_dict["TN"] = sc_pure_tn_main
    end
    labels_order = ["BBTN", "TN with Slicing", "TN"]
    legend_items  = [legend_dict[l] for l in labels_order if haskey(legend_dict, l)]
    legend_labels = [l for l in labels_order if haskey(legend_dict, l)]
    Legend(parent[0, 1], legend_items, legend_labels,
           orientation = :horizontal, labelsize = 18,
           nbanks = 1, tellwidth = false, halign = :center)
    return ax
end

function build_tc_counting_multi_types!(parent)
    ax = Axis(parent[1, 1],
        ylabel = L"t.c.\text{(Flops)}",
        xticks = (1:4, ["Spin Glass\nRRG", "Spin Glass\n3D Grid", "MIS\nRKSG", "MWIS\nRKSG"]),
        yticks = (0:5:35, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$",
                           L"$10^{20}$", L"$10^{25}$", L"$10^{30}$", L"$10^{35}$"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 16, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df_ground = CSV.read("../../data/main/complexity/ground_state_counting/tc_ground_counting.csv", DataFrame)

    total_tc_vals             = log10.(2 .^ df_ground.total_tc_mean)
    total_tc_slicing_vals     = log10.(2 .^ df_ground.total_tc_slicing_mean)
    total_tc_max_vals         = log10.(2 .^ df_ground.total_tc_max)
    total_tc_min_vals         = log10.(2 .^ df_ground.total_tc_min)
    total_tc_slicing_max_vals = log10.(2 .^ df_ground.total_tc_slicing_max)
    total_tc_slicing_min_vals = log10.(2 .^ df_ground.total_tc_slicing_min)

    cat = [1, 1, 2, 2, 3, 3, 4, 4]
    bar_grp = [1, 2, 1, 2, 1, 2, 1, 2]
    mean_times = Float64[]
    min_times  = Float64[]
    max_times  = Float64[]
    for i in 1:4
        push!(mean_times, total_tc_vals[i])
        push!(mean_times, total_tc_slicing_vals[i])
        push!(min_times,  total_tc_min_vals[i])
        push!(min_times,  total_tc_slicing_min_vals[i])
        push!(max_times,  total_tc_max_vals[i])
        push!(max_times,  total_tc_slicing_max_vals[i])
    end

    bar_colors = [method_colors["BBTN"], method_colors["TN_with_Slicing"]]

    barplot!(ax, cat, mean_times, dodge = bar_grp,
             color = bar_colors[bar_grp], strokecolor = :black, strokewidth = 1)

    dodge_width = 0.8
    bar_width = dodge_width / 2
    for i in 1:length(cat)
        x_pos = cat[i] + (bar_grp[i] - 1.5) * bar_width
        y_min = min_times[i]
        y_max = max_times[i]

        lines!(ax, [x_pos, x_pos], [y_min, y_max], color = :black, linewidth = 1)
        cap_width = 0.05
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_min, y_min], color = :black, linewidth = 1)
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_max, y_max], color = :black, linewidth = 1)
    end

    ylims!(ax, 0, 35)

    hlines!(ax, [tc_min - log10(2)],            color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [tc_month - log10(2)],          color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [tc_1000000_years - log10(2)],  color = :black, linestyle = :dash, linewidth = 1)

    text!(ax, 0.05, tc_min - log10(2),            text = L"$1$ min",       fontsize = 22, color = :black)
    text!(ax, 0.05, tc_month - log10(2),          text = L"$1$ month",     fontsize = 22, color = :black)
    text!(ax, 0.05, tc_1000000_years - log10(2),  text = L"$10^6$ years",  fontsize = 22, color = :black)

    xlims!(ax, 0, 5)

    legend_dict = Dict{String, Any}()
    legend_dict["BBTN"]            = PolyElement(polycolor = bar_colors[1])
    legend_dict["TN with Slicing"] = PolyElement(polycolor = bar_colors[2])
    labels_order = ["BBTN", "TN with Slicing"]
    legend_items = [legend_dict[l] for l in labels_order]
    Legend(parent[0, 1], legend_items, labels_order,
           orientation = :horizontal, labelsize = 18,
           nbanks = 1, tellwidth = false, halign = :center)
    return ax
end

function build_tc_energy_scailing!(parent)
    t = 15

    ax = Axis(parent[1, 1],
        xlabel = L"N", ylabel = L"t.c. \text{ (Flops)}",
        xticks = (30:10:100, [L"30", L"40", L"50", L"60", L"70", L"80", L"90", L"100"]),
        yticks = (0:5:35, [L"10^0", L"10^{5}", L"10^{10}", L"10^{15}",
                           L"10^{20}", L"10^{25}", L"10^{30}", L"10^{35}"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    n_tn   = [50:10:100...]
    n_ds   = [50:10:100...]
    n_tnbb = [50:10:100...]

    df_tn   = [CSV.read("../../data/main/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ds   = [CSV.read("../../data/main/complexity/random_ksg/slice32_rksg_n$(n).csv",  DataFrame) for n in n_ds]
    df_tnbb = [CSV.read("../../data/main/complexity/random_ksg/tnbb_ksg_n$(n).csv",     DataFrame) for n in n_tnbb]

    tc_tn   = log10.(2 .^([geometric_mean(df_tn[i].tc)          for i in 1:length(n_tn)]))
    tc_ds   = log10.(2 .^([geometric_mean(df_ds[i].sliced_tc)   for i in 1:length(n_ds)]))
    tc_tnbb = log10.(2 .^([geometric_mean(df_tnbb[i].total_tc)  for i in 1:length(n_tnbb)]))

    @. model_tn(x, p)   = p[1] * x + p[2]
    fit_tn   = curve_fit(model_tn, n_tn, tc_tn, [1.0, 1.0])
    @. model_ds(x, p)   = p[1] * x^p[2] + p[3]
    fit_ds   = curve_fit(model_ds, n_ds, tc_ds, [1.0, 1.0, 1.0])
    @. model_tnbb(x, p) = p[1] * x + p[2]
    fit_tnbb = curve_fit(model_tnbb, n_tnbb[1:4], tc_tnbb[1:4], [1.0, 1.0])

    xs = range(45, 105, length = 100)

    lines!(ax, xs, model_tn(xs, fit_tn.param),     color = method_colors["TN"],              linestyle = :dash)
    lines!(ax, xs, model_ds(xs, fit_ds.param),     color = method_colors["TN_with_Slicing"], linestyle = :solid)
    lines!(ax, xs, model_tnbb(xs, fit_tnbb.param), color = method_colors["BBTN"],            linestyle = :solid)

    sc_tn   = scatter!(ax, n_tn,   tc_tn,   markersize = t * 1.0, marker = :utriangle,        color = method_colors["TN"],              strokewidth = 1.0, strokecolor = :black)
    sc_ds   = scatter!(ax, n_ds,   tc_ds,   markersize = t * 1.0, marker = markerstyle[3],    color = method_colors["TN_with_Slicing"], strokewidth = 1.0, strokecolor = :black)
    sc_tnbb = scatter!(ax, n_tnbb[1:4], tc_tnbb[1:4], markersize = t * 1.0, marker = markerstyle[2], color = method_colors["BBTN"], strokewidth = 1.0, strokecolor = :black)
    scatter!(ax, n_tnbb[5:end], tc_tnbb[5:end], markersize = t * 1.0, marker = markerstyle[2],
             color = :white, strokewidth = 2, strokecolor = method_colors["BBTN"])

    xlims!(ax, 45, 105)
    ylims!(ax, 0, 35)

    hlines!(ax, [tc_min],           color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, 46, tc_min,           text = L"$1$ min",      color = :black, fontsize = 22)
    hlines!(ax, [tc_month],         color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, 46, tc_month,         text = L"$1$ month",    color = :black, fontsize = 22)
    hlines!(ax, [tc_1000000_years], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, 46, tc_1000000_years, text = L"$10^6$ years", color = :black, fontsize = 22)

    legend_dict = Dict{String, Any}()
    legend_dict["BBTN"]            = sc_tnbb
    legend_dict["TN with Slicing"] = sc_ds
    legend_dict["TN"]              = sc_tn
    labels_order = ["BBTN", "TN with Slicing", "TN"]
    legend_items = [legend_dict[l] for l in labels_order]
    Legend(parent[0, 1], legend_items, labels_order,
           labelsize = 18, orientation = :horizontal,
           nbanks = 1, tellwidth = false, halign = :center)
    return ax
end

function build_runtime_spin_glass!(parent)
    L_values = [10, 20, 30, 40, 50, 60]

    ax = Axis(parent[1, 1],
        xlabel = L"L", ylabel = L"\text{Runtime (s)}",
        xticks = (1:length(L_values), [LaTeXString("L=$L") for L in L_values]),
        yticks = (0:5, [L"10^0", L"10^1", L"10^2", L"10^3", L"10^4", L"10^5"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 18, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df = CSV.read("../../data/main/runtime/spin_glass/all_method_summary.csv", DataFrame)

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

    max_time = 7 * 24 * 3600.0
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

    ylims!(ax, 0, log10(max_time))

    one_hour = log10(3600)
    one_day  = log10(24 * 3600)
    one_week = log10(7 * 24 * 3600)

    hlines!(ax, [one_hour], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [one_day],  color = :black, linestyle = :dash, linewidth = 1)

    text!(ax, 0.05, one_hour, text = L"$1$ hour", fontsize = 22, color = :black)
    text!(ax, 0.05, one_day,  text = L"$1$ day",  fontsize = 22, color = :black)

    limit_color = "#8B0000"
    text!(ax, 0.15, one_week,
          text = L"\text{time limit} = 1\text{ week}",
          color = limit_color, fontsize = 20, font = :bold,
          align = (:left, :bottom), offset = (0, 4))

    xlims!(ax, 0, length(L_values) + 1)

    legend_dict = Dict{String, Any}()
    for m in methods
        legend_dict[method_legend_label[m]] = PolyElement(polycolor = method_colors[method_color_keys[m]])
    end
    labels_order = [method_legend_label[m] for m in methods]
    legend_items = [legend_dict[l] for l in labels_order]
    Legend(parent[0, 1], legend_items, labels_order,
           labelsize = 18, orientation = :horizontal,
           nbanks = 1, tellwidth = false, halign = :center)
    return ax
end

function build_runtime_energy!(parent)
    y_baseline = -1

    ax = Axis(parent[1, 1],
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
    Legend(parent[0, 1], legend_items, labels_order,
           labelsize = 18, orientation = :horizontal,
           nbanks = 1, tellwidth = false, halign = :center)
    return ax
end

# --------------------------- assemble figure ---------------------------

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (1900, 1150), fontsize = 20)

    row1 = fig[1, 1] = GridLayout()
    row2 = fig[2, 1] = GridLayout()
    rowgap!(fig.layout, 24)
    colgap!(row1, 16)
    colgap!(row2, 20)

    gl_a = row1[1, 1] = GridLayout()
    gl_b = row1[1, 2] = GridLayout()
    gl_c = row1[1, 3] = GridLayout()

    gl_d = row2[1, 1] = GridLayout()
    gl_e = row2[1, 2] = GridLayout()

    ax_a = build_tc_counting_scailing!(gl_a)
    ax_b = build_tc_counting_multi_types!(gl_b)
    ax_c = build_tc_energy_scailing!(gl_c)
    ax_d = build_runtime_spin_glass!(gl_d)
    ax_e = build_runtime_energy!(gl_e)

    # Panel letters inside the plot viewport (relative coords) so they do not cover the y-axis label.
    for (ax, ch) in zip((ax_a, ax_b, ax_c, ax_d, ax_e), ('a', 'b', 'c', 'd', 'e'))
        text!(ax, 0.02, 0.98, text = "($ch)", space = :relative,
              fontsize = 28, font = :bold, align = (:left, :top))
    end

    # Make the 3 columns in row 1 roughly proportional to the originals (800:800:600)
    colsize!(row1, 1, Auto(8))
    colsize!(row1, 2, Auto(8))
    colsize!(row1, 3, Auto(6))

    # Row 2: spin_glass (900) vs runtime_energy (800)
    colsize!(row2, 1, Auto(9))
    colsize!(row2, 2, Auto(8))

    save("../../figs/combined_main.pdf", fig)
    fig
end
