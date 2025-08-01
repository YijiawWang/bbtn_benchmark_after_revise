include("settings.jl")

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

    t = markersize
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
end

fig