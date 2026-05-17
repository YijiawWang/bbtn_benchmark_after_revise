include("../settings.jl")

df_finetune = CSV.read("../../data/sm/finetune/finetune_n60_s1.csv", DataFrame)

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (600, 400), fontsize = 20)
    ax_fig = Axis(fig[1, 1], xlabel = L"N_{iters}", ylabel = L"t.c.", xticks = (10:20:200, [L"10", L"30", L"50", L"70", L"90", L"110", L"130", L"150", L"170", L"190"]), yticks = (25:5:55, [L"2^{25}", L"2^{30}", L"2^{35}", L"2^{40}", L"2^{45}", L"2^{50}", L"2^{55}"]))

    baseline = df_finetune[df_finetune.name .== "baseline", :]
    finetune = df_finetune[df_finetune.name .== "finetune", :]
    treesa = df_finetune[df_finetune.name .== "treesa", :]

    finetune_niter = unique(finetune.iters)
    finetune_tc = [mean(finetune[finetune.iters .== i, :tc]) for i in finetune_niter]
    finetune_tc_min = [minimum(finetune[finetune.iters .== i, :tc]) for i in finetune_niter]
    finetune_tc_max = [maximum(finetune[finetune.iters .== i, :tc]) for i in finetune_niter]

    treesa_niter = unique(treesa.iters)
    treesa_tc = [mean(treesa[treesa.iters .== i, :tc]) for i in treesa_niter]
    treesa_tc_min = [minimum(treesa[treesa.iters .== i, :tc]) for i in treesa_niter]
    treesa_tc_max = [maximum(treesa[treesa.iters .== i, :tc]) for i in treesa_niter]
    
    scatter_finetune = scatter!(ax_fig, finetune_niter, finetune_tc, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "Finetune")
    errorbars!(ax_fig, finetune_niter, finetune_tc, finetune_tc .- finetune_tc_min, finetune_tc_max .- finetune_tc, color = colors[2], whiskerwidth = 10)
    scatter_treesa = scatter!(ax_fig, treesa_niter, treesa_tc, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "Treesa")
    errorbars!(ax_fig, treesa_niter, treesa_tc, treesa_tc .- treesa_tc_min, treesa_tc_max .- treesa_tc, color = colors[3], whiskerwidth = 10)

    hline_baseline = hlines!(ax_fig, [baseline.tc[1]], color = colors[1], linestyle = :solid, label = "Baseline")

    xlims!(ax_fig, 0, 200)
    ylims!(ax_fig, 30, 55)

    axislegend(ax_fig, [scatter_finetune, scatter_treesa, hline_baseline], ["Finetune", "TreeSA", "Baseline"], orientation = :horizontal, labelsize = 15)

    save("../../figs/finetune_n60_s1.pdf", fig)

    fig
end
