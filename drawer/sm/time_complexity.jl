include("../settings.jl")
t = 15

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 400), fontsize = 20)

    ax = Axis(fig[2, 1], xlabel = L"\log_2(s.c.)", ylabel = L"t.c. \text{ (Flops)}", xreversed = true, xticks = ([32, 30, 28, 26, 24, 22, 20, 18], [L"32", L"30", L"28", L"26", L"24", L"22", L"20", L"18"]), yticks = (10:1:22, [L"10^{10}", L"10^{11}", L"10^{12}", L"10^{13}", L"10^{14}", L"10^{15}", L"10^{16}", L"10^{17}", L"10^{18}", L"10^{19}", L"10^{20}", L"10^{21}", L"10^{22}"]))

    df_tnbb_vsc = CSV.read("../../data/main/complexity/random_ksg/tnbb_different_target_freoptimize_n80.csv", DataFrame)
    df_ds_vsc = CSV.read("../../data/main/complexity/random_ksg/treesa_different_target_n80.csv", DataFrame)

    i = 4
    sc_tnbb = df_tnbb_vsc.target
    tc_tnbb = log10.(2 .^df_tnbb_vsc.total_tc)
    orignal_tc = log10.(2 .^df_ds_vsc[df_ds_vsc.name .== i, :origin_tc][1])
    orignal_sc = df_ds_vsc[df_ds_vsc.name .== i, :origin_sc][1]
    sc_ds = df_ds_vsc[df_ds_vsc.name .== i, :sliced_sc][1:2:end]
    tc_ds = log10.(2 .^df_ds_vsc[df_ds_vsc.name .== i, :sliced_tc][1:2:end])

    scatter_ds = scatter!(ax, sc_ds, tc_ds, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black)
    scatter_tnbb = scatter!(ax, sc_tnbb, tc_tnbb, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black)
    hline_ttn = hlines!(ax, [orignal_tc], color = method_colors["TN"], linestyle = :solid)
    
    xlims!(ax, 33, 21)
    ylims!(ax, 13.5, 19.5)

    Legend(fig[1, 1], [scatter_tnbb, scatter_ds, hline_ttn], ["BBTN", "TN with Slicing", "TN"], orientation = :horizontal, labelsize = 15)

    save("../../figs/tc_different_target.pdf", fig)

    fig
end

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (1000, 400), fontsize = 20)

    ax1 = Axis(fig[2, 1], xlabel = L"N", ylabel = L"t.c. \text{ (Flops)}", xticks = (30:10:100, [L"30", L"40", L"50", L"60", L"70", L"80", L"90", L"100"]), yticks = (0:5:35, [L"10^0", L"10^{5}", L"10^{10}", L"10^{15}", L"10^{20}", L"10^{25}", L"10^{30}", L"10^{35}"]))
    ax2 = Axis(fig[2, 2], ylabel = L"\text{Runtime (s)}", 
        xticks = (1:5, ["RKSG\nN=60", "RKSG\nN=70", "RKSG\nN=80", "MKSG\nStructured", "MKSG\nRandom"]),
        yticks = (0:7, [L"10^0", L"10^1", L"10^2", L"10^3", L"10^4", L"10^5", L"10^6", L"10^7"]),
        xticklabelsize = 13,
    )

    n_tn = [50:10:100...]
    n_ds = [50:10:100...]
    n_tnbb = [50:10:100...]

    df_tn = [CSV.read("../../data/main/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ds = [CSV.read("../../data/main/complexity/random_ksg/slice32_rksg_n$(n).csv", DataFrame) for n in n_ds]
    df_tnbb = [CSV.read("../../data/main/complexity/random_ksg/tnbb_ksg_n$(n).csv", DataFrame) for n in n_tnbb]
    
    tc_tn = log10.(2 .^([geometric_mean(df_tn[i].tc) for i in 1:length(n_tn)]))
    tc_ds = log10.(2 .^([geometric_mean(df_ds[i].sliced_tc) for i in 1:length(n_ds)]))
    tc_tnbb = log10.(2 .^([geometric_mean(df_tnbb[i].total_tc) for i in 1:length(n_tnbb)]))

    @. model_tn(x, p) = p[1] * x + p[2]
    fit_tn = curve_fit(model_tn, n_tn, tc_tn, [1.0, 1.0])
    @. model_ds(x, p) = p[1] * x^p[2] + p[3]
    fit_ds = curve_fit(model_ds, n_ds, tc_ds, [1.0, 1.0, 1.0])
    @. model_tnbb(x, p) = p[1] * x + p[2]
    fit_tnbb = curve_fit(model_tnbb, n_tnbb[1:4], tc_tnbb[1:4], [1.0, 1.0])


    xs = range(45, 105, length = 100)

    lines!(ax1, xs, model_tn(xs, fit_tn.param), color = method_colors["TN"], linestyle = :dash)
    lines!(ax1, xs, model_ds(xs, fit_ds.param), color = colors[3], linestyle = :solid)
    lines!(ax1, xs, model_tnbb(xs, fit_tnbb.param), color = colors[2], linestyle = :solid)

    alpha = 0.7

    sc_tn = scatter!(ax1, n_tn, tc_tn, markersize = t, marker = markerstyle[1], color = :white, strokewidth = 2, strokecolor = method_colors["TN"], label = "Tropical-TN")
    sc_ds = scatter!(ax1, n_ds, tc_ds, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "Slicing")
    sc_tnbb = scatter!(ax1, n_tnbb[1:4], tc_tnbb[1:4], markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "BBTN")
    scatter!(ax1, n_tnbb[5:end], tc_tnbb[5:end], markersize = t, marker = markerstyle[2], color = :white, strokewidth = 2, strokecolor = colors[2])

    Legend(fig[1, 1], [sc_tnbb, sc_ds, sc_tn], ["BBTN", "Slicing", "Tropical-TN"], orientation = :horizontal, labelsize = 15)

    xlims!(ax1, 45, 105)
    ylims!(ax1, 0, 35)

    hlines!(ax1, [log10(2^tc_min)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, 46, log10(2^tc_min), text = L"$1$ min", color = :black, fontsize = 18)
    hlines!(ax1, [log10(2^tc_month)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, 46, log10(2^tc_month), text = L"$1$ month", color = :black, fontsize = 18)
    hlines!(ax1, [log10(2^tc_100_years * 100)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, 46, log10(2^tc_100_years * 100), text = L"$10000$ years", color = :black, fontsize = 18)


    # ax2, runtime for different methods

    df_ksg_60 = CSV.read("../../data/main/runtime/mis/ksg_n60_runtime_all.csv", DataFrame)
    df_ksg_70 = CSV.read("../../data/main/runtime/mis/ksg_n70_runtime_all.csv", DataFrame)
    df_ksg_80 = CSV.read("../../data/main/runtime/mis/ksg_n80_runtime_all.csv", DataFrame)

    df = CSV.read("../../data/main/runtime/mis/fact_k16_tnbb_ds_scip.csv", DataFrame)

    df_ksg_60_tnbb_time = df_ksg_60.tnbb_contract_runtime .+ df_ksg_60.tnbb_branch_runtime
    df_ksg_70_tnbb_time = df_ksg_70.tnbb_contract_runtime .+ df_ksg_70.tnbb_branch_runtime
    df_ksg_80_tnbb_time = df_ksg_80.tnbb_contract_runtime .+ df_ksg_80.tnbb_branch_runtime
    df_ksg_60_ds_time = df_ksg_60.ds_contract_runtime .+ df_ksg_60.ds_slice_runtime
    df_ksg_70_ds_time = df_ksg_70.ds_contract_runtime .+ df_ksg_70.ds_slice_runtime
    df_ksg_80_ds_time = df_ksg_80.ds_contract_runtime .+ df_ksg_80.ds_slice_runtime

    # Extract mean times for each category and algorithm
    rksg_60_means = [mean(df_ksg_60_tnbb_time), mean(df_ksg_60_ds_time), mean(df_ksg_60.scip_runtime)]
    rksg_70_means = [mean(df_ksg_70_tnbb_time), mean(df_ksg_70_ds_time), mean(df_ksg_70.scip_runtime)]
    rksg_80_means = [mean(df_ksg_80_tnbb_time), mean(df_ksg_80_ds_time), mean(df_ksg_80.scip_runtime)]

    rksg_60_mins = [minimum(df_ksg_60_tnbb_time), minimum(df_ksg_60_ds_time), minimum(df_ksg_60.scip_runtime)]
    rksg_70_mins = [minimum(df_ksg_70_tnbb_time), minimum(df_ksg_70_ds_time), minimum(df_ksg_70.scip_runtime)]
    rksg_80_mins = [minimum(df_ksg_80_tnbb_time), minimum(df_ksg_80_ds_time), minimum(df_ksg_80.scip_runtime)]

    rksg_60_maxs = [maximum(df_ksg_60_tnbb_time), maximum(df_ksg_60_ds_time), maximum(df_ksg_60.scip_runtime)]
    rksg_70_maxs = [maximum(df_ksg_70_tnbb_time), maximum(df_ksg_70_ds_time), maximum(df_ksg_70.scip_runtime)]
    rksg_80_maxs = [maximum(df_ksg_80_tnbb_time), maximum(df_ksg_80_ds_time), maximum(df_ksg_80.scip_runtime)]
    
    if_easy_means = [df[df.name .== "IF_EASY", :bbtn_mean_time][1], 
                     df[df.name .== "IF_EASY", :ttn_mean_time][1], 
                     df[df.name .== "IF_EASY", :scip_mean_time][1]]
    
    if_hard_means = [df[df.name .== "IF_HARD", :bbtn_mean_time][1], 
                     df[df.name .== "IF_HARD", :ttn_mean_time][1], 
                     df[df.name .== "IF_HARD", :scip_mean_time][1]]
    
    # Extract min and max times for error bars
    rksg_mins = [df[df.name .== "rksg", :bbtn_min_time][1], 
                 df[df.name .== "rksg", :ttn_min_time][1], 
                 df[df.name .== "rksg", :scip_min_time][1]]
    
    rksg_maxs = [df[df.name .== "rksg", :bbtn_max_time][1], 
                 df[df.name .== "rksg", :ttn_max_time][1], 
                 df[df.name .== "rksg", :scip_max_time][1]]
    
    if_easy_mins = [df[df.name .== "IF_EASY", :bbtn_min_time][1], 
                    df[df.name .== "IF_EASY", :ttn_min_time][1], 
                    df[df.name .== "IF_EASY", :scip_min_time][1]]
    
    if_easy_maxs = [df[df.name .== "IF_EASY", :bbtn_max_time][1], 
                    df[df.name .== "IF_EASY", :ttn_max_time][1], 
                    df[df.name .== "IF_EASY", :scip_max_time][1]]
    
    if_hard_mins = [df[df.name .== "IF_HARD", :bbtn_min_time][1], 
                    df[df.name .== "IF_HARD", :ttn_min_time][1], 
                    df[df.name .== "IF_HARD", :scip_min_time][1]]
    
    if_hard_maxs = [df[df.name .== "IF_HARD", :bbtn_max_time][1], 
                    df[df.name .== "IF_HARD", :ttn_max_time][1], 
                    df[df.name .== "IF_HARD", :scip_max_time][1]]
    
    # Combine all data
    mean_times = vcat(rksg_60_means, rksg_70_means, rksg_80_means, if_easy_means, if_hard_means)
    min_times = vcat(rksg_60_mins, rksg_70_mins, rksg_80_mins, if_easy_mins, if_hard_mins)
    max_times = vcat(rksg_60_maxs, rksg_70_maxs, rksg_80_maxs, if_easy_maxs, if_hard_maxs)
    
    # Cap extreme values
    max_time = 1e7
    mean_times = map(x -> x > max_time ? max_time : x, mean_times)
    min_times = map(x -> x > max_time ? max_time : x, min_times)
    max_times = map(x -> x > max_time ? max_time : x, max_times)

    cat = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5]
    bar_grp = [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]

    runtime_colors = ["#E36D44","#228833", "#CCBB44", "#CCBB44", "#228833", "#E36D44"]
    barplot!(ax2, cat, log10.(mean_times), dodge = bar_grp, color = runtime_colors[bar_grp], strokecolor = :black, strokewidth = 1)

    # Add error bars - calculate precise positions
    # For dodge barplot, the default dodge width is 0.8, so each bar is offset by 0.8/3 ≈ 0.267
    dodge_width = 0.8
    bar_width = dodge_width / 3  # Each bar takes 1/3 of the dodge width

    for i in 1:length(cat)
        x_pos = cat[i] + (bar_grp[i] - 2) * bar_width
        y_mean = log10(mean_times[i])
        y_min = log10(min_times[i])
        y_max = log10(max_times[i])
        
        lines!(ax2, [x_pos, x_pos], [y_min, y_max], color = :black, linewidth = 1)
        cap_width = 0.05
        lines!(ax2, [x_pos - cap_width, x_pos + cap_width], [y_min, y_min], color = :black, linewidth = 1)
        lines!(ax2, [x_pos - cap_width, x_pos + cap_width], [y_max, y_max], color = :black, linewidth = 1)
    end

    ylims!(ax2, 0, 7)

    # Add horizontal lines and labels for time references
    one_hour = log10(3600)  # 1 hour = 3600 seconds
    one_day = log10(24 * 3600)  # 1 day = 24 * 3600 seconds
    ten_days = log10(7 * 24 * 3600)  
    
    hlines!(ax2, [one_hour], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax2, [one_day], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax2, [ten_days], color = :black, linestyle = :dash, linewidth = 1)

    
    text!(ax2, 0.05, one_hour, text = L"$1$ hour", fontsize = 18, color = :black)
    text!(ax2, 0.05, one_day, text = L"$1$ day", fontsize = 18, color = :black)
    text!(ax2, 0.05, ten_days, text = L"$1$ week", fontsize = 18, color = :black)

    xlims!(ax2, 0, 6)

    Legend(fig[1, 2], [PolyElement(polycolor = runtime_colors[i]) for i in 1:3], ["BBTN", "Slicing", "SCIP"], labelsize = 15, orientation = :horizontal)

    text!(ax1, 0, 1, text = L"\textbf{(a)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)
    text!(ax2, 0, 1, text = L"\textbf{(b)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)

    save("../../figs/time_complexity.pdf", fig)

    fig
end