include("../settings.jl")

# Color kept consistent with the cyan/sky used in `count_vs_L_pbc.jl`.
const COLOR_MAIN = "#33BBEE"

begin
    t = 15  # marker size, consistent with tc_counting_scailing.jl

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (800, 500), fontsize = 20)

    xtick_positions = collect(0.1:0.1:1.0)
    xtick_labels = [LaTeXString(string(round(x, digits=1))) for x in xtick_positions]
    # Add custom y-ticks at log10(2) and log10(4) on top of the decade ticks
    # so the values 2 and 4 are labelled directly on the y-axis.
    ytick_positions = vcat(collect(0:1:6), [log10(2), log10(4)])
    ytick_labels    = vcat([L"$10^0$", L"$10^1$", L"$10^2$", L"$10^3$",
                            L"$10^4$", L"$10^5$", L"$10^6$"],
                           [L"$2$", L"$4$"])

    ax = Axis(fig[1, 1],
        xlabel = L"g", ylabel = L"\text{count}",
        xticks = (xtick_positions, xtick_labels),
        yticks = (ytick_positions, ytick_labels),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df = CSV.read("../../data/sm/pbc/bbtn_pbc_L18_count_vs_g.csv",
                  DataFrame, missingstring=["-", ""])

    g_all = Float64[]; cnt_all = Float64[]
    for i in 1:nrow(df)
        g = df.g[i]; c = df.count[i]
        if ismissing(g) || ismissing(c) || c <= 0
            continue
        end
        push!(g_all, g); push!(cnt_all, log10(c))
    end

    # Horizontal dashed reference lines at count = 2 and count = 4, spanning
    # the entire x-axis.
    hlines!(ax, [log10(2)], color = :black, linestyle = :dash, linewidth = 1.5)
    hlines!(ax, [log10(4)], color = :black, linestyle = :dash, linewidth = 1.5)

    scatter!(ax, g_all, cnt_all,
        markersize = t * 1.0, marker = markerstyle[2],
        color = COLOR_MAIN, strokewidth = 1.0, strokecolor = :black)

    xlims!(ax, 0.0, 1.1)
    ylims!(ax, -0.3, 6.5)

    save("../../figs/count_vs_g_pbc.pdf", fig)
    fig
end
