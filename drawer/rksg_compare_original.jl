include("settings.jl")
t = markersize

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 700), fontsize = 20)

    ax1 = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{sc}_0)", ylabel = L"\text{log}_2(\text{tc})")
    ax2 = Axis(fig[3, 1], xlabel = L"Δ \text{log}_2(\text{sc})", ylabel = L"Δ \text{log}_2(\text{tc})")

    ## ax1, compare tropical tensor network and pure branch&bound
    n_tn = [50:10:100...]
    n_ds = [50:10:100...]
    n_tnbb = [50:10:100...]

    df_tn = [CSV.read("../data/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ds = [CSV.read("../data/complexity/random_ksg/slice32_rksg_n$(n).csv", DataFrame) for n in n_ds]
    df_tnbb = [CSV.read("../data/complexity/random_ksg/tnbb_ksg_n$(n).csv", DataFrame) for n in n_tnbb]

    sc_tn = []
    tc_tn = []
    sc_ds = []
    tc_ds = []
    sc_tnbb = []
    tc_tnbb = []

    for (i, n) in enumerate(n_tnbb)
        for name_i in df_tnbb[i].name
            sc0 = df_tn[i][df_tn[i].name .== name_i, :sc][1]
            if sc0 >= 32
                push!(sc_tnbb, sc0)
                push!(tc_tnbb, df_tnbb[i][df_tnbb[i].name .== name_i, :total_tc][1])
                push!(sc_tn, sc0)
                push!(tc_tn, df_tn[i][df_tn[i].name .== name_i, :tc][1])
                push!(sc_ds, sc0)
                push!(tc_ds, df_ds[i][df_ds[i].name .== name_i, :sliced_tc][1])
            end
        end
    end

    sc_tn = scatter!(ax1, sc_tn, tc_tn, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Tropical TN")
    sc_tnbb = scatter!(ax1, sc_tnbb, tc_tnbb, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "TNBB")
    sc_ds = scatter!(ax1, sc_ds, tc_ds, markersize = t, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black, label = "Dynamic Slicing")

    xlims!(ax1, 30, 70)
    ylims!(ax1, 10, 170)

    # axislegend(ax1, position = :rb, labelsize = 12)

    Legend(fig[1, :], [sc_tn, sc_tnbb, sc_ds], ["Tropical TN", "TNBB", "Dynamic Slicing"], orientation = :horizontal, nbanks = 1, labelsize = 12)

    text!(ax1, 0, 1, text = "(a)", align = (:left, :top), fontsize = 25, font = :bold, space = :relative, offset = (4, -2))


    ## ax3, compare ds and tnbb on the same graph with different sc_target
    df_ds = CSV.read("../data/complexity/random_ksg/treesa_different_target_n80.csv", DataFrame)
    df_tnbb = CSV.read("../data/complexity/random_ksg/tnbb_different_target_n80.csv", DataFrame)

    delta_sc = collect(1:14)

    tc_tnbbs = []
    tc_dss = []

    for i in 1:10
        orignal_tc = df_ds[df_ds.name .== i, :origin_tc][1]
        tc_ds = [df_ds[df_ds.name .== i .&& df_ds.ds .== dsi, :sliced_tc][1] for dsi in delta_sc]
        push!(tc_dss, tc_ds .- orignal_tc)
    end
    avg_tc_dss = [mean([tc_dss[i][j] for i in 1:10]) for j in delta_sc]

    for i in [2]
        orignal_tc = df_ds[df_ds.name .== i, :origin_tc][1]
        tc_tnbb = [df_tnbb[df_tnbb.name .== i .&& df_tnbb.ds .== dsi, :total_tc][1] for dsi in delta_sc]
        push!(tc_tnbbs, tc_tnbb .- orignal_tc)
    end
    avg_tc_tnbbs = [mean([tc_tnbbs[i][j] for i in 1:1]) for j in delta_sc]

    sc_ds = scatter!(ax2, delta_sc, avg_tc_dss, markersize = t, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black)
    sc_tnbb = scatter!(ax2, delta_sc, avg_tc_tnbbs, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black)
    # hlines!(ax3, [orignal_tc], color = :blue, linestyle = :dash)

    xlims!(ax2, 0, 15)
    ylims!(ax2, -10, 20)

    text!(ax2, 0, 1, text = "(b)", align = (:left, :top), fontsize = 25, font = :bold, space = :relative, offset = (4, -2))

    save("../figs/random_ksg_compare_original.pdf", fig)

    fig
end

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 280), fontsize = 15)

    ax1 = Axis(fig[2, 2], xlabel = L"N", ylabel = L"t.c. \text{ (Flops)}", xticks = (50:10:100, [L"50", L"60", L"70", L"80", L"90", L"100"]), yticks = (20:20:100, [L"2^{20}", L"2^{40}", L"2^{60}", L"2^{80}", L"2^{100}"]))
    ax2 = Axis(fig[2, 1], xlabel = L"\log_2(s.c.)", ylabel = L"t.c. \text{ (Flops)}", xreversed = true, xticks = ([32, 30, 28, 26, 24, 22, 20, 18], [L"32", L"30", L"28", L"26", L"24", L"22", L"20", L"18"]), yticks = (40:10:80, [L"2^{40}", L"2^{50}", L"2^{60}", L"2^{70}", L"2^{80}"]))

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

    scatter!(ax2, sc_ds, tc_ds, markersize = t, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black)
    scatter!(ax2, sc_tnbb, tc_tnbb, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black)
    # scatter!(ax2, orignal_sc, orignal_tc, markersize = t, marker = markerstyle[2], color = :white, strokewidth = 2, strokecolor = colors[2])
    hlines!(ax2, [orignal_tc], color = :blue, linestyle = :solid)
    
    xlims!(ax2, 33, 21)
    ylims!(ax2, 39, 71)

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

    lines!(ax1, xs, model_tn(xs, fit_tn.param), color = colors[2], linestyle = :dash)
    lines!(ax1, xs, model_ds(xs, fit_ds.param), color = colors[4], linestyle = :dash)
    lines!(ax1, xs, model_tnbb(xs, fit_tnbb.param), color = colors[3], linestyle = :dash)

    sc_tn = scatter!(ax1, n_tn, tc_tn, markersize = t, marker = markerstyle[2], color = :white, strokewidth = 2, strokecolor = colors[2], label = "Tropical TN")
    sc_ds = scatter!(ax1, n_ds, tc_ds, markersize = t, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black, label = "Dynamic Slicing")
    sc_tnbb = scatter!(ax1, n_tnbb, tc_tnbb, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "TNBB")

    xlims!(ax1, 45, 105)
    ylims!(ax1, 20, 100)

    Legend(fig[1, :], [sc_tn, sc_ds, sc_tnbb], ["TTN", "TTN & DS", "BBTN"], orientation = :horizontal, nbanks = 1, labelsize = 15)
    text!(ax1, 0, 1, text = L"\textbf{(b)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)

    
    # hlines!(ax1, [tc_min], color = :black, linestyle = :dash)
    hlines!(ax1, [tc_hour], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, 46, tc_hour, text = L"$1$ hour", color = :black, fontsize = 12)
    hlines!(ax1, [tc_month], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, 46, tc_month, text = L"$1$ month", color = :black, fontsize = 12)
    # hlines!(ax1, [tc_100_years], color = :black, linestyle = hstyle, linewidth = hwidth)
    # text!(ax1, 46, tc_100_years, text = L"$100$ years", color = :black, fontsize = 18)

    save("../figs/tnbb_random_ksg.pdf", fig)

    fig
end