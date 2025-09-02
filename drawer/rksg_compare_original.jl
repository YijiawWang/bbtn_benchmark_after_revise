include("settings.jl")
t = 15


begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 560), fontsize = 20)

    ax1 = Axis(fig[3, 1], xlabel = L"N", ylabel = L"t.c. \text{ (Flops)}", xticks = (50:10:100, [L"50", L"60", L"70", L"80", L"90", L"100"]), yticks = (20:20:100, [L"2^{20}", L"2^{40}", L"2^{60}", L"2^{80}", L"2^{100}"]))
    ax2 = Axis(fig[2, 1], xlabel = L"\log_2(s.c.)", ylabel = L"t.c. \text{ (Flops)}", xreversed = true, xticks = ([32, 30, 28, 26, 24, 22, 20, 18], [L"32", L"30", L"28", L"26", L"24", L"22", L"20", L"18"]), yticks = (46:3:58, [L"2^{46}", L"2^{49}", L"2^{52}", L"2^{55}", L"2^{58}"]))

    text!(ax2, 0, 1, text = L"\textbf{(a)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)

    df_tnbb_vsc = CSV.read("../data/complexity/random_ksg/tnbb_different_target_freoptimize_n80.csv", DataFrame)
    df_ds_vsc = CSV.read("../data/complexity/random_ksg/treesa_different_target_n80.csv", DataFrame)


    i = 4
    sc_tnbb = df_tnbb_vsc.target
    tc_tnbb = df_tnbb_vsc.total_tc
    orignal_tc = df_ds_vsc[df_ds_vsc.name .== i, :origin_tc][1]
    orignal_sc = df_ds_vsc[df_ds_vsc.name .== i, :origin_sc][1]
    sc_ds = df_ds_vsc[df_ds_vsc.name .== i, :sliced_sc][1:2:end]
    tc_ds = df_ds_vsc[df_ds_vsc.name .== i, :sliced_tc][1:2:end]

    scatter!(ax2, sc_ds, tc_ds, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black)
    scatter!(ax2, sc_tnbb, tc_tnbb, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black)
    # scatter!(ax2, orignal_sc, orignal_tc, markersize = t, marker = markerstyle[2], color = :white, strokewidth = 2, strokecolor = colors[2])
    hlines!(ax2, [orignal_tc], color = colors[1], linestyle = :solid)
    
    xlims!(ax2, 33, 21)
    ylims!(ax2, 46, 58)

    ## ax1, compare tropical tensor network and pure branch&bound
    n_tn = [50:10:100...]
    n_ds = [50:10:100...]
    n_tnbb = [50:10:100...]

    df_tn = [CSV.read("../data/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ds = [CSV.read("../data/complexity/random_ksg/slice32_rksg_n$(n).csv", DataFrame) for n in n_ds]
    df_tnbb = [CSV.read("../data/complexity/random_ksg/tnbb_ksg_n$(n).csv", DataFrame) for n in n_tnbb]
    
    tc_tn = [geometric_mean(df_tn[i].tc) for i in 1:length(n_tn)]
    tc_ds = [geometric_mean(df_ds[i].sliced_tc) for i in 1:length(n_ds)]
    tc_tnbb = [geometric_mean(df_tnbb[i].total_tc) for i in 1:length(n_tnbb)]

    @. model_tn(x, p) = p[1] * x + p[2]
    fit_tn = curve_fit(model_tn, n_tn, tc_tn, [1.0, 1.0])
    @. model_ds(x, p) = p[1] * x^p[2] + p[3]
    fit_ds = curve_fit(model_ds, n_ds, tc_ds, [1.0, 1.0, 1.0])
    @. model_tnbb(x, p) = p[1] * x + p[2]
    fit_tnbb = curve_fit(model_tnbb, n_tnbb, tc_tnbb, [1.0, 1.0])


    xs = range(45, 105, length = 100)

    lines!(ax1, xs, model_tn(xs, fit_tn.param), color = colors[1], linestyle = :dash)
    lines!(ax1, xs, model_ds(xs, fit_ds.param), color = colors[3], linestyle = :dash)
    lines!(ax1, xs, model_tnbb(xs, fit_tnbb.param), color = colors[2], linestyle = :dash)

    sc_tn = scatter!(ax1, n_tn, tc_tn, markersize = t, marker = markerstyle[1], color = :white, strokewidth = 2, strokecolor = colors[1], label = "Tropical TN")
    sc_ds = scatter!(ax1, n_ds, tc_ds, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "Dynamic Slicing")
    sc_tnbb = scatter!(ax1, n_tnbb, tc_tnbb, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "TNBB")

    xlims!(ax1, 45, 105)
    ylims!(ax1, 20, 100)

    Legend(fig[1, :], [sc_tnbb, sc_tn, sc_ds], ["BBTN", "Tropical-TN", "DS"], orientation = :horizontal, nbanks = 1, labelsize = 15)
    text!(ax1, 0, 1, text = L"\textbf{(b)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)

    
    # hlines!(ax1, [tc_min], color = :black, linestyle = :dash)
    # hlines!(ax1, [tc_hour], color = :black, linestyle = hstyle, linewidth = hwidth)
    # text!(ax1, 46, tc_hour, text = L"$1$ hour", color = :black, fontsize = 15)
    hlines!(ax1, [tc_month], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, 46, tc_month, text = L"$1$ month", color = :black, fontsize = 18)
    # hlines!(ax1, [tc_100_years], color = :black, linestyle = hstyle, linewidth = hwidth)
    # text!(ax1, 46, tc_100_years, text = L"$100$ years", color = :black, fontsize = 18)

    save("../figs/tnbb_random_ksg_large.pdf", fig)

    fig
end