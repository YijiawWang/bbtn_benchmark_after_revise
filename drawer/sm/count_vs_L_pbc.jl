include("../settings.jl")

# Two new colors not present in `method_colors`.
const COLOR_EVEN = "#33BBEE"  # cyan / sky
const COLOR_ODD  = "#CC3311"  # vermillion red

begin
    t = 15  # marker size, consistent with tc_counting_scailing.jl

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (800, 500), fontsize = 20)

    xtick_positions = collect(4:1:19)
    xtick_labels = [LaTeXString("$x") for x in xtick_positions]
    ytick_positions = collect(0:1:7)
    ytick_labels = [L"$10^0$", L"$10^1$", L"$10^2$", L"$10^3$",
                    L"$10^4$", L"$10^5$", L"$10^6$", L"$10^7$"]

    ax = Axis(fig[1, 1],
        xlabel = L"L", ylabel = L"\text{count}",
        xticks = (xtick_positions, xtick_labels),
        yticks = (ytick_positions, ytick_labels),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df = CSV.read("../../data/sm/pbc/bbtn_pbc_g0.5_count_vs_L.csv",
                  DataFrame, missingstring=["-", ""])

    L_even = Int[]; count_even = Float64[]
    L_odd  = Int[]; count_odd  = Float64[]
    for i in 1:nrow(df)
        L = df.L[i]; c = df.count[i]
        if ismissing(L) || ismissing(c) || c <= 0
            continue
        end
        if iseven(L)
            push!(L_even, L); push!(count_even, log10(c))
        else
            push!(L_odd, L);  push!(count_odd,  log10(c))
        end
    end

    # Reference scaling curve: count = 2^(L+1) - 2
    xs = range(minimum(df.L) - 0.5, maximum(df.L) + 0.5, length = 400)
    ys = log10.(2.0 .^ (xs .+ 1) .- 2.0)
    ln_scale = lines!(ax, xs, ys,
        color = COLOR_EVEN, linestyle = :solid, linewidth = 2,
        label = L"2^{L+1}-2")

    sc_even = scatter!(ax, L_even, count_even,
        markersize = t * 1.0, marker = markerstyle[2],
        color = COLOR_EVEN, strokewidth = 1.0, strokecolor = :black,
        label = L"\text{even } L")

    sc_odd = scatter!(ax, L_odd, count_odd,
        markersize = t * 1.0, marker = markerstyle[3],
        color = COLOR_ODD, strokewidth = 1.0, strokecolor = :black,
        label = L"\text{odd } L")

    xlims!(ax, minimum(df.L) - 0.5, maximum(df.L) + 0.5)
    ylims!(ax, 0, log10(2.0^(maximum(df.L) + 1) - 2.0) + 0.5)

    Legend(fig[0, 1], [sc_even, sc_odd, ln_scale],
           [L"\text{even } L", L"\text{odd } L", L"2^{L+1}-2"],
           orientation = :horizontal, labelsize = 20,
           nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/count_vs_L_pbc.pdf", fig)
    fig
end
