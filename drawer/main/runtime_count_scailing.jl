include("../settings.jl")
using Printf

begin
    t = 15
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (800, 500), fontsize = 20)

    ax = Axis(fig[1, 1],
        xscale = log10,
        yscale = log10,
        xlabel = L"|\mathrm{GS}|",
        ylabel = L"t\ \text{(s)}",
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    # CPLEX pool vs |GS| (n=30 2D grid): log–log linear fit used as scaling law
    df_fit = CSV.read("../../data/sm/cplex_pool_scailing/scailing.csv", DataFrame, missingstring = ["", "NA"])
    cplex_mask = .!ismissing.(df_fit.cplex_pool_runtime)
    counts_c = Float64.(df_fit.count[cplex_mask])
    cplex_t = Float64.(collect(skipmissing(df_fit.cplex_pool_runtime)))

    @. model_lin(x, p) = p[1] * x + p[2]
    fit_c = curve_fit(model_lin, log10.(counts_c), log10.(cplex_t), [1.0, 1.0])
    pfit = fit_c.param
    pred_logt(c::Real) = pfit[1] * log10(c) + pfit[2]
    pred_t(c::Real) = exp10(pred_logt(c))

    sc_cplex = scatter!(ax, counts_c, cplex_t,
        markersize = t * 0.85, marker = markerstyle[3],
        color = (method_colors["CPLEX"], 0.35), strokewidth = 1.0, strokecolor = :black,
        label = "n=30")

    function parse_seed(path::AbstractString)
        m = match(r"seed=(\d+)", path)
        m === nothing && return typemax(Int)
        return parse(Int, m.captures[1])
    end

    root = "../../../bbtn_results/contractors/results"
    # One distinct color per n (n=40 / 50 / 60); all markers are circles.
    n_color = Dict(
        40 => "#E36D44",  # orange
        50 => "#228833",  # green
        60 => "#AA3377",  # purple
    )
    nn_specs = [
        (40, joinpath(root, "bbtn_nn_pm1_n40.csv")),
        (50, joinpath(root, "bbtn_nn_pm1_n50.csv")),
        (60, joinpath(root, "bbtn_nn_pm1_n60.csv")),
    ]

    SEC_PER_YEAR = 365.25 * 24 * 3600
    SEC_PER_DAY  = 24 * 3600

    # Per-n data: counts, predicted times, color, min-time index
    per_n = Dict{Int, NamedTuple{(:cs, :τs, :col, :jmin), Tuple{Vector{Float64}, Vector{Float64}, String, Int}}}()
    all_c = Float64[]
    all_t = Float64[]

    for (ngrid, path) in nn_specs
        df = CSV.read(path, DataFrame)
        df.seed = parse_seed.(df.subdir)
        sort!(df, :seed)
        df10 = first(df, min(10, nrow(df)))
        cs = Float64[]
        τs = Float64[]
        for row in eachrow(df10)
            c = Float64(row.count)
            push!(cs, c)
            push!(τs, pred_t(c))
        end
        append!(all_c, cs)
        append!(all_t, τs)
        per_n[ngrid] = (cs = cs, τs = τs, col = n_color[ngrid], jmin = argmin(τs))
    end

    x_min = min(minimum(counts_c), 1.0)
    x_max = max(maximum(counts_c), maximum(all_c))
    xs = range(x_min, x_max * 1.02, length = 200)
    ln_fit = lines!(ax, xs, exp10.(model_lin(log10.(xs), pfit)),
        color = method_colors["CPLEX"], linestyle = :solid, linewidth = 2,
        label = "CPLEX fit")

    # Per-n scatter (all circles, color encodes n)
    sc_handles = Dict{Int, Any}()
    for ngrid in (40, 50, 60)
        d = per_n[ngrid]
        h = scatter!(ax, d.cs, d.τs,
            color = d.col, marker = :circle, markersize = t * 1.0,
            strokewidth = 1.0, strokecolor = :black)
        sc_handles[ngrid] = h
    end

    span_log = log10(maximum(vcat(all_c, counts_c))) - log10(minimum(vcat(all_c, counts_c)))
    lo_c = minimum(vcat(all_c, counts_c))
    hi_c = maximum(vcat(all_c, counts_c))
    x0t = exp10(log10(lo_c) - max(span_log * 0.12, 0.25))
    x_line_right = exp10(log10(hi_c) + max(span_log * 0.02, 0.05))

    # Reference time lines (1 min / 1 h / 1 day) — keep as before
    hlines!(ax, [60.0, 3600.0, 86400.0], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, x0t, 60.0, text = L"$1$ min", color = :black, fontsize = 22)
    text!(ax, x0t, 3600.0, text = L"$1$ h", color = :black, fontsize = 22)
    text!(ax, x0t, 86400.0, text = L"$1$ day", color = :black, fontsize = 22)

    # Horizontal line at the min predicted time of each n + y-axis label
    for ngrid in (40, 50, 60)
        d = per_n[ngrid]
        τj = d.τs[d.jmin]
        if ngrid == 40
            vstr = @sprintf("%.3g days", τj / SEC_PER_DAY)
        else
            vstr = @sprintf("%.3g years", τj / SEC_PER_YEAR)
        end
        # full-width dashed line in the n-color
        hlines!(ax, [τj], color = d.col, linestyle = :dash, linewidth = 1.8)
        # label at the y-axis location
        text!(ax, x0t, τj,
            text = rich("n=$(ngrid): ", rich(vstr; color = d.col, font = :bold)),
            color = d.col, fontsize = 18, align = (:left, :bottom), offset = (0, 2))
    end

    xlims!(ax, nothing, nothing)
    ylims!(ax, nothing, nothing)

    # Legend: CPLEX data, fit, color meanings for n
    leg_elems = [
        sc_cplex,
        ln_fit,
        MarkerElement(marker = :circle, color = n_color[40], markersize = 12, strokecolor = :black, strokewidth = 1),
        MarkerElement(marker = :circle, color = n_color[50], markersize = 12, strokecolor = :black, strokewidth = 1),
        MarkerElement(marker = :circle, color = n_color[60], markersize = 12, strokecolor = :black, strokewidth = 1),
    ]
    leg_labs = [
        L"n=30",
        "log–log fit",
        L"n=40",
        L"n=50",
        L"n=60",
    ]
    Legend(fig[0, 1], leg_elems, leg_labs,
        orientation = :horizontal, labelsize = 18,
        nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/runtime_count_scailing.pdf", fig)
    fig
end
