include("../settings.jl")

begin
    t = 15  # 散点大小，与原 (a) 图一致

    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (800, 500), fontsize = 20)

    xtick_positions = collect(5:5:70)
    xtick_labels = [x in [10, 20, 30, 35, 40, 45, 50, 55, 60, 65, 70] ? LaTeXString("$x") : "" for x in xtick_positions]
    ax = Axis(fig[1, 1],
        xlabel = L"N", ylabel = L"t.c.\text{(Flops)}",
        xticks = (xtick_positions, xtick_labels),
        yticks = (0:5:40, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$",
                           L"$10^{20}$", L"$10^{25}$", L"$10^{30}$", L"$10^{35}$", L"$10^{40}$"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 22, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df_spin = CSV.read("../../data/main/complexity/spin_glass_counting/lattice_J+-1_h_05.csv",
                       DataFrame, missingstring=["-", ""])

    n_vals = Int[]
    total_tc_mean_vals = Float64[]
    total_tc_slicing_mean_vals = Float64[]
    for i in 1:nrow(df_spin)
        tc_mean_val = df_spin.total_tc_mean[i]
        tc_slicing_val = df_spin.total_tc_slicing_mean[i]
        if !ismissing(tc_mean_val) && !ismissing(tc_slicing_val) &&
           !isnan(tc_mean_val) && !isnan(tc_slicing_val) &&
           isfinite(tc_mean_val) && isfinite(tc_slicing_val) &&
           tc_mean_val > 0 && tc_slicing_val > 0
            transformed_mean = log10(2^tc_mean_val)
            transformed_slicing = log10(2^tc_slicing_val)
            if isfinite(transformed_mean) && isfinite(transformed_slicing)
                push!(n_vals, df_spin.n[i])
                push!(total_tc_mean_vals, transformed_mean)
                push!(total_tc_slicing_mean_vals, transformed_slicing)
            end
        end
    end

    # n <= 30 时，total_tc_mean 使用 total_tc_slicing_mean 的值
    for i in 1:length(n_vals)
        if n_vals[i] <= 30
            total_tc_mean_vals[i] = total_tc_slicing_mean_vals[i]
        end
    end

    pure_tn_tc_vals = Float64[]
    n_pure_tn_vals = Int[]
    for i in 1:nrow(df_spin)
        val = df_spin.pure_tn_tc[i]
        if !ismissing(val) && !isnan(val) && isfinite(val) && val > 0
            transformed_val = log10(2^val)
            if isfinite(transformed_val)
                push!(n_pure_tn_vals, df_spin.n[i])
                push!(pure_tn_tc_vals, transformed_val)
            end
        end
    end

    function model_power(x, p)
        return p[1] .* exp.(p[2] .* log.(max.(x, 0.1))) .+ p[3]
    end
    @. model_tn(x, p) = p[1] * x + p[2]

    # Slicing (total_tc_slicing_mean): 幂函数模型 y = a*x^b + c
    fit_slicing = nothing
    n_vals_slicing = length(n_vals) > 6 ? n_vals[7:end] : Int[]
    total_tc_slicing_mean_vals_slicing = length(total_tc_slicing_mean_vals) > 6 ? total_tc_slicing_mean_vals[7:end] : Float64[]
    if length(n_vals_slicing) >= 3
        weights_slicing = ones(length(n_vals_slicing))
        max_n_slicing = maximum(n_vals_slicing)
        max_idx_slicing = findfirst(==(max_n_slicing), n_vals_slicing)
        if max_idx_slicing !== nothing
            weights_slicing[max_idx_slicing] = 5.0
        end
        fit_slicing = curve_fit(model_power, n_vals_slicing, total_tc_slicing_mean_vals_slicing,
                                weights_slicing, [1.0, 1.0, 1.0])
    end

    # Tropical-TN (pure_tn_tc): 线性模型 y = a*x + b
    fit_tn = nothing
    if length(n_pure_tn_vals) >= 2
        valid_indices = [i for i in 1:length(pure_tn_tc_vals) if isfinite(pure_tn_tc_vals[i]) && isfinite(n_pure_tn_vals[i])]
        if length(valid_indices) >= 2
            n_pure_tn_vals_filtered = n_pure_tn_vals[valid_indices]
            pure_tn_tc_vals_filtered = pure_tn_tc_vals[valid_indices]
            fit_tn = curve_fit(model_tn, n_pure_tn_vals_filtered, pure_tn_tc_vals_filtered, [1.0, 1.0])
        end
    end

    # 主图：BBTN 散点
    n_vals_tc_plot = length(n_vals) > 6 ? n_vals[7:end] : Int[]
    total_tc_mean_vals_plot = length(total_tc_mean_vals) > 6 ? total_tc_mean_vals[7:end] : Float64[]
    sc_tc = scatter!(ax, n_vals_tc_plot, total_tc_mean_vals_plot,
                     markersize = t * 1.0, marker = markerstyle[2],
                     color = method_colors["BBTN"], strokewidth = 1.0, strokecolor = :black,
                     label = "BBTN")

    # Slicing 拟合曲线
    if length(n_vals_slicing) > 0 && fit_slicing !== nothing
        x_min = 35
        x_max = maximum(n_vals_slicing) + 4.5
        xs = range(x_min, x_max, length = 100)
        lines!(ax, xs, model_power(xs, fit_slicing.param),
               color = method_colors["TN_with_Slicing"], linestyle = :solid, linewidth = 2)
    end

    # Slicing 散点
    sc_tc_slicing = scatter!(ax, n_vals_slicing, total_tc_slicing_mean_vals_slicing,
                             markersize = t * 1.0, marker = markerstyle[3],
                             color = method_colors["TN_with_Slicing"], strokewidth = 1.0, strokecolor = :black,
                             label = "TN with Slicing")

    # Tropical-TN 拟合曲线（虚线）
    if length(n_pure_tn_vals) > 0 && fit_tn !== nothing
        x_min_tn = 20
        x_max_tn = maximum(n_pure_tn_vals) + 4.5
        xs_tn = range(x_min_tn, x_max_tn, length = 100)
        lines!(ax, xs_tn, model_tn(xs_tn, fit_tn.param),
               color = method_colors["TN"], linestyle = :dash, linewidth = 2)
    end

    # Tropical-TN 散点（只画 n > 20 的点）
    sc_pure_tn_main = nothing
    if length(n_pure_tn_vals) > 0
        n_pure_tn_main = Int[]
        pure_tn_tc_main = Float64[]
        for i in 1:length(n_pure_tn_vals)
            if n_pure_tn_vals[i] > 20
                push!(n_pure_tn_main, n_pure_tn_vals[i])
                push!(pure_tn_tc_main, pure_tn_tc_vals[i])
            end
        end
        if length(n_pure_tn_main) > 0
            sc_pure_tn_main = scatter!(ax,
                n_pure_tn_main, pure_tn_tc_main,
                markersize = t * 1.0, marker = :utriangle,
                color = method_colors["TN"], strokewidth = 1.0, strokecolor = :black)
        end
    end

    # 设置 x 轴范围
    if length(n_vals_slicing) > 0
        n_start = minimum(n_vals_slicing) - 4.5
        n_end = maximum(n_vals_slicing) + 4.5
    else
        n_start = 0
        n_end = 100
    end
    xlims!(ax, n_start, n_end)
    ylims!(ax, 10, 40)

    # 参考线
    hlines!(ax, tc_min - log10(2), color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, n_start + 1, tc_min - log10(2), text = L"$1$ min", color = :black, fontsize = 22)
    hlines!(ax, [tc_month - log10(2)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, n_start + 1, tc_month - log10(2), text = L"$1$ month", color = :black, fontsize = 22)
    hlines!(ax, [tc_1000000_years - log10(2)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax, n_start + 1, tc_1000000_years - log10(2), text = L"$10^6$ years", color = :black, fontsize = 22)

    # Legend (no Branch & Bound)
    legend_dict = Dict{String, Any}()
    legend_dict["BBTN"] = sc_tc
    legend_dict["TN with Slicing"] = sc_tc_slicing
    if sc_pure_tn_main !== nothing
        legend_dict["TN"] = sc_pure_tn_main
    end
    labels_order = ["BBTN", "TN with Slicing", "TN"]
    legend_items  = [legend_dict[l] for l in labels_order if haskey(legend_dict, l)]
    legend_labels = [l for l in labels_order if haskey(legend_dict, l)]
    Legend(fig[0, 1], legend_items, legend_labels,
           orientation = :horizontal, labelsize = 20,
           nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/tc_counting_scailing.pdf", fig)
    fig
end
