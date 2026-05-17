include("../settings.jl")

# Colors consistent with count_vs_L_pbc.jl / count_vs_g_pbc.jl.
const COLOR_CNT = "#33BBEE"  # cyan / sky (count)
const COLOR_TC  = "#CC3311"  # vermillion red (t.c.)

begin
    t = 15  # marker size, consistent with count_vs_g_pbc.jl

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (1300, 500), fontsize = 20)

    df = CSV.read("../../data/sm/nnn_obc/bbtn_obc_L40_gsweep_sc31.csv",
                  DataFrame, missingstring=["-", ""])

    g_arr   = Float64[]
    cnt_arr = Float64[]
    tc_arr  = Float64[]
    for i in 1:nrow(df)
        g  = df.g[i]
        c  = df.count[i]
        tc = df.tc_total[i]
        if ismissing(g) || ismissing(c) || c <= 0 || ismissing(tc)
            continue
        end
        push!(g_arr, g)
        push!(cnt_arr, log10(c))
        push!(tc_arr, tc)
    end
    sortidx = sortperm(g_arr)
    g_arr   = g_arr[sortidx]
    cnt_arr = cnt_arr[sortidx]
    tc_arr  = tc_arr[sortidx]

    xtick_positions = collect(0.0:0.5:4.0)
    xtick_labels    = [LaTeXString(string(round(x, digits=1))) for x in xtick_positions]

    # ---------- Left: count vs g ----------
    ytick_positions_l = collect(0:2:10)
    ytick_labels_l    = [L"$10^0$", L"$10^2$", L"$10^4$",
                         L"$10^6$", L"$10^8$", L"$10^{10}$"]

    ax_l = Axis(fig[1, 1],
        xlabel = L"g", ylabel = L"\text{count}",
        xticks = (xtick_positions, xtick_labels),
        yticks = (ytick_positions_l, ytick_labels_l),
        xlabelsize = 26, ylabelsize = 26,
        xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    ln_cnt = lines!(ax_l, g_arr, cnt_arr,
        color = COLOR_CNT, linestyle = :solid, linewidth = 2)

    sc_cnt = scatter!(ax_l, g_arr, cnt_arr,
        markersize = t * 1.0, marker = markerstyle[2],
        color = COLOR_CNT, strokewidth = 1.0, strokecolor = :black,
        label = L"\text{count}")

    xlims!(ax_l, -0.2, 4.2)
    ylims!(ax_l, -0.5, 11.0)

    # ---------- Right: tc_total vs g ----------
    ytick_positions_r = collect(44:1:49)
    ytick_labels_r    = [L"2^{44}", L"2^{45}", L"2^{46}",
                         L"2^{47}", L"2^{48}", L"2^{49}"]

    ax_r = Axis(fig[1, 2],
        xlabel = L"g", ylabel = L"\text{t.c. (Flops)}",
        xticks = (xtick_positions, xtick_labels),
        yticks = (ytick_positions_r, ytick_labels_r),
        xlabelsize = 26, ylabelsize = 26,
        xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    ln_tc = lines!(ax_r, g_arr, tc_arr,
        color = COLOR_TC, linestyle = :solid, linewidth = 2)

    sc_tc = scatter!(ax_r, g_arr, tc_arr,
        markersize = t * 1.0, marker = markerstyle[3],
        color = COLOR_TC, strokewidth = 1.0, strokecolor = :black,
        label = L"\text{t.c.}")

    xlims!(ax_r, -0.2, 4.2)
    ylims!(ax_r, 44.0, 49.5)

    Legend(fig[0, 1:2], [sc_cnt, sc_tc],
           [L"\text{count}", L"\text{t.c.}"],
           orientation = :horizontal, labelsize = 20,
           nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/count_vs_g_obc.pdf", fig)
    fig
end
