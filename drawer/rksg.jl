include("settings.jl")

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 900), fontsize = 20)
    ax1 = Axis(fig[1, 1], xlabel = L"N", ylabel = L"\text{log}_2(\text{tc})", yticklabelcolor = :blue)
    ax1_2 = Axis(fig[1, 1], yticklabelcolor = :red, yaxisposition = :right, ylabel = L"\text{log}_2(N_{bb})", ygridvisible = false)

    hidespines!(ax1_2)
    hidexdecorations!(ax1_2)
    # hideydecorations!(ax1_2, ticks = false, label = true, ticklabels = true)

    ax2 = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{sc}_0)", ylabel = L"\text{log}_2(\text{tc})")
    ax3 = Axis(fig[3, 1], xlabel = L"Δ \text{log}_2(\text{sc})", ylabel = L"Δ \text{log}_2(\text{tc})")

    ## ax1, compare tropical tensor network and pure branch&bound
    n_bb = [30, 35, 40, 45, 50]
    n_tn = [30:10:70...]
    n_ktn = [40:10:100...]

    df_bbs = [CSV.read("../data/count_vc/ksg_n$(n)_count_vc.csv", DataFrame) for n in n_bb]
    df_tns = [CSV.read("../data/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ktns = [CSV.read("../data/complexity/random_ksg/treesa_tn_ksg_n$(n).csv", DataFrame) for n in n_ktn]

    count_bbs = log2.([maximum(df_bbs[i].count_lp) for i in 1:length(n_bb)])
    sc_tns = [maximum(df_tns[i].tc) for i in 1:length(n_tn)]
    sc_ktns = [maximum(df_ktns[i].tc) for i in 1:length(n_ktn)]

    sc_bb = scatter!(ax1_2, n_bb, count_bbs, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "Branch&Bound")
    sc_tn = scatter!(ax1, n_ktn, sc_ktns, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Tropical TN")

    # dummy
    scatter!(ax1, [0], [0],markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "Branch&Bound")
    
    scatter!(ax1, n_tn, sc_tns, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black)

    x_start = 25
    x_end = 105

    xlims!(ax1, x_start, x_end)
    ylims!(ax1, 0, 80)
    xlims!(ax1_2, x_start, x_end)
    ylims!(ax1_2, 0, 25)

    # axislegend(ax1, position = :rb)
    text!(ax1, 0, 1, text = "(a)", align = (:left, :top), fontsize = 25, font = :bold, space = :relative, offset = (4, -2))


    ## ax2, compare dynamic slicing and tnbb on different graphs
    df_tn = [CSV.read("../data/complexity/random_ksg/treesa_tn_ksg_n$(n).csv", DataFrame) for n in 70:10:100]
    df_ds = [CSV.read("../data/complexity/random_ksg/slice32_tn_ksg_n$(n).csv", DataFrame) for n in 70:10:100]
    df_tnbb = [CSV.read("../data/complexity/random_ksg/tnbb_ksg_n$(n).csv", DataFrame) for n in 70:10:90]

    scs = []
    tcs_tn = []
    tcs_ds = []
    tcs_tnbb = []

    for n in 70:10:100
        df_tnbb = CSV.read("../data/complexity/random_ksg/tnbb_ksg_n$(n).csv", DataFrame)
        df_ds = CSV.read("../data/complexity/random_ksg/slice32_tn_ksg_n$(n).csv", DataFrame)

        for name_i in df_tnbb.name
            tc_tnbb = df_tnbb[df_tnbb.name .== name_i, :total_tc][1]
            tc_ds = df_ds[df_ds.name .== name_i, :sliced_tc][1]
            tc_tn = df_ds[df_ds.name .== name_i, :origin_tc][1]
            sc = df_ds[df_ds.name .== name_i, :origin_sc][1]

            if sc >= 32
                push!(scs, sc)
                push!(tcs_tn, tc_tn)
                push!(tcs_ds, tc_ds)
                push!(tcs_tnbb, tc_tnbb)
            end
        end
    end

    t = markersize
    scatter!(ax2, scs, tcs_tn, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Tropical TN")
    sc_tnbb = scatter!(ax2, scs, tcs_tnbb, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "TNBB")
    sc_ds = scatter!(ax2, scs, tcs_ds, markersize = t, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black, label = "Dynamic Slicing")

    xlims!(ax2, 30, 48)
    ylims!(ax2, 35, 85)

    Legend(fig[4, :], [sc_bb, sc_tn, sc_tnbb, sc_ds], ["Branch&Bound", "Tropical TN", "TNBB", "Dynamic Slicing"], orientation = :horizontal, nbanks = 1, labelsize = 12)
    text!(ax2, 0, 1, text = "(b)", align = (:left, :top), fontsize = 25, font = :bold, space = :relative, offset = (4, -2))


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

    sc_ds = scatter!(ax3, delta_sc, avg_tc_dss, markersize = t, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black)
    sc_tnbb = scatter!(ax3, delta_sc, avg_tc_tnbbs, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black)
    # hlines!(ax3, [orignal_tc], color = :blue, linestyle = :dash)

    xlims!(ax3, 0, 15)
    ylims!(ax3, -10, 20)

    text!(ax3, 0, 1, text = "(c)", align = (:left, :top), fontsize = 25, font = :bold, space = :relative, offset = (4, -2))

    # save("../figs/random_ksg.pdf", fig)
end

fig