include("settings.jl")

begin
    t = 15  # 散点大小，与 (b) 图一致
    t_cross = 18  # × 和 + 的长度更长一些
    
    # ========== 第一幅图：(a) 和 (c) ==========
    fig1 = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (1000, 400), fontsize = 20)
    colgap!(fig1.layout, 80)
    
    # ========== (a)：spin_glass_counging_lattice.jl ==========
    xtick_positions = collect(5:5:65)
    xtick_labels = [mod(x, 10) == 0 ? string(x) : "" for x in xtick_positions]  # 10,20,... 有标签，其余仅刻度
    ax1_top = Axis(fig1[1, 1], xlabel = L"N", ylabel = L"t.c.\text{(Flops)}", xticks = (xtick_positions, xtick_labels), yticks = (0:5:35, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$", L"$10^{20}$", L"$10^{25}$", L"$10^{30}$", L"$10^{35}$"]))
    ax1_top_2 = Axis(fig1[1, 1],
                     yaxisposition = :right,
                     ylabel = L"N_{BB}",
                     ygridvisible = false,
                     yticks = ([0,2,4,6,8,10], [L"$10^0$", L"$10^2$", L"$10^4$", L"$10^6$", L"$10^8$", L"$10^{10}$"]),
                     rightspinecolor = colors[6],
                     rightspinevisible = true,
                     ytickcolor = colors[6],
                     yticklabelcolor = colors[6],
                     ylabelcolor = colors[6])
    
    hidespines!(ax1_top_2, :l, :b, :t)
    hidexdecorations!(ax1_top_2)
    
    # 读取数据
    df_spin = CSV.read("../data/spin_glass_counting/lattice_J+-1_h_05.csv", DataFrame, missingstring=["-", ""])
    
    # 提取数据（只处理有效的 total_tc_mean 和 total_tc_slicing_mean）
    n_vals = Int[]
    total_tc_mean_vals = Float64[]
    total_tc_slicing_mean_vals = Float64[]
    
    for i in 1:nrow(df_spin)
        tc_mean_val = df_spin.total_tc_mean[i]
        tc_slicing_val = df_spin.total_tc_slicing_mean[i]
        
        # 只处理两个值都有效的情况
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
    
    # 在 n <= 30 时，total_tc_mean 使用 total_tc_slicing_mean 的值
    for i in 1:length(n_vals)
        if n_vals[i] <= 30
            total_tc_mean_vals[i] = total_tc_slicing_mean_vals[i]
        end
    end
    
    # 提取 pure_tn_tc 数据
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
    
    # bb_branch_num 可能为空，需要处理
    bb_branch_num_vals = Float64[]
    n_bb_vals = Int[]
    for i in 1:nrow(df_spin)
        val = df_spin.bb_branch_num[i]
        # 尝试转换为 Float64，处理可能的类型问题
        try
            if !ismissing(val)
                val_float = Float64(val)
                if !isnan(val_float) && isfinite(val_float) && val_float > 0
                    transformed_val = log10(val_float)
                    if isfinite(transformed_val)
                        push!(n_bb_vals, df_spin.n[i])
                        push!(bb_branch_num_vals, transformed_val)
                    end
                end
            end
        catch
            # 如果转换失败，跳过这一行
            continue
        end
    end
    
    # 拟合曲线
    # 定义模型函数
    function model_power(x, p)
        # 使用 exp 和 log 来安全计算幂函数，避免负数或零的问题
        return p[1] .* exp.(p[2] .* log.(max.(x, 0.1))) .+ p[3]
    end
    @. model_tn(x, p) = p[1] * x + p[2]        # 线性模型
    @. model_bb_quad(x, p) = p[1] * x^2 + p[2]  # 二次模型（无一次项）
    
    # Branch & Bound (bb_branch_num): 二次模型 y = a*x^2 + b（右侧 y 轴）
    fit_bb = nothing
    if length(n_bb_vals) >= 2
        fit_bb = curve_fit(model_bb_quad, n_bb_vals, bb_branch_num_vals, [1.0, 1.0])
    end
    
    # Slicing (total_tc_slicing_mean): 幂函数模型 y = a*x^b + c（左侧 y 轴）
    # 去掉前 6 个绿色点（不画也不参与拟合），并让最大 n 的点权重大一些
    fit_slicing = nothing
    n_vals_slicing = length(n_vals) > 6 ? n_vals[7:end] : Int[]
    total_tc_slicing_mean_vals_slicing = length(total_tc_slicing_mean_vals) > 6 ? total_tc_slicing_mean_vals[7:end] : Float64[]
    if length(n_vals_slicing) >= 3
        weights_slicing = ones(length(n_vals_slicing))
        max_n_slicing = maximum(n_vals_slicing)
        max_idx_slicing = findfirst(==(max_n_slicing), n_vals_slicing)
        if max_idx_slicing !== nothing
            weights_slicing[max_idx_slicing] = 5.0  # 调高末尾点权重
        end
        # 旧版 LsqFit 的签名是 curve_fit(model, x, y, wt, p0)
        fit_slicing = curve_fit(model_power, n_vals_slicing, total_tc_slicing_mean_vals_slicing, weights_slicing, [1.0, 1.0, 1.0])
    end
    
    # Tropical-TN (pure_tn_tc): 线性模型 y = a*x + b（左侧 y 轴）
    fit_tn = nothing
    if length(n_pure_tn_vals) >= 2
        # 再次检查数据中是否有 Inf 或 NaN
        valid_indices = [i for i in 1:length(pure_tn_tc_vals) if isfinite(pure_tn_tc_vals[i]) && isfinite(n_pure_tn_vals[i])]
        if length(valid_indices) >= 2
            n_pure_tn_vals_filtered = n_pure_tn_vals[valid_indices]
            pure_tn_tc_vals_filtered = pure_tn_tc_vals[valid_indices]
            fit_tn = curve_fit(model_tn, n_pure_tn_vals_filtered, pure_tn_tc_vals_filtered, [1.0, 1.0])
        end
    end
    
    # 绘制拟合曲线
    all_n_vals = vcat(n_vals, n_bb_vals, n_pure_tn_vals)
    if length(all_n_vals) > 0
        # 确保 x 范围只包含正数，避免幂函数计算错误
        x_min = max(0.1, minimum(all_n_vals) - 4.5)
        x_max = maximum(all_n_vals) + 4.5
        xs = range(x_min, x_max, length = 100)
        
        # Tropical-TN 拟合曲线（左侧 y 轴，虚线，先绘制）
        if fit_tn !== nothing
            lines!(ax1_top, xs, model_tn(xs, fit_tn.param), color = colors[1], linestyle = :dash, linewidth = 2)
        end
        
        # Branch & Bound 拟合曲线（右侧 y 轴，二次）
        if fit_bb !== nothing
            lines!(ax1_top_2, xs, model_bb_quad(xs, fit_bb.param), color = colors[6], linestyle = :solid, linewidth = 2)
        end
    end
    
    # 绘制散点图（部分在拟合曲线之前，部分之后）
    # BBTN 去掉前 6 个数据点
    n_vals_tc_plot = length(n_vals) > 6 ? n_vals[7:end] : Int[]
    total_tc_mean_vals_plot = length(total_tc_mean_vals) > 6 ? total_tc_mean_vals[7:end] : Float64[]
    sc_tc = scatter!(ax1_top, n_vals_tc_plot, total_tc_mean_vals_plot, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = 0.6, strokecolor = :black, label = "total_tc_mean")
    
    # 绘制 pure_tn_tc：全部实心×（在 Slicing 拟合曲线之前）
    if length(n_pure_tn_vals) > 0
        sc_pure_tn = scatter!(ax1_top,
                              n_pure_tn_vals,
                              pure_tn_tc_vals,
                              markersize = t_cross,
                              marker = :x,
                              color = colors[1],
                              strokewidth = 0,
                              label = "pure_tn_tc")
    end
    
    # Slicing 拟合曲线（在 Tropical-TN 散点之后绘制，位于上层）
    all_n_vals = vcat(n_vals_slicing, n_bb_vals, n_pure_tn_vals)
    if length(all_n_vals) > 0 && fit_slicing !== nothing
        # x_min = max(0.1, minimum(all_n_vals) - 3.5)
        x_min = 35
        x_max = maximum(all_n_vals) + 4.5
        xs = range(x_min, x_max, length = 100)
        lines!(ax1_top, xs, model_power(xs, fit_slicing.param), color = colors[3], linestyle = :solid, linewidth = 2)
    end
    
    # 绘制其他散点（在 Slicing 拟合曲线之后），去掉前 6 个绿色点
    sc_tc_slicing = scatter!(ax1_top, n_vals_slicing, total_tc_slicing_mean_vals_slicing, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "total_tc_slicing_mean")
    
    if length(n_bb_vals) > 0
        sc_bb = scatter!(ax1_top_2, n_bb_vals, bb_branch_num_vals, markersize = t_cross, marker = :+, color = colors[6], strokewidth = 0, label = "bb_branch_num")
    end
    
    # 设置 x 轴和 y 轴范围（包含所有有效的 n 值，Slicing 去掉前 6 个点）
    all_n_vals = vcat(n_vals_slicing, n_bb_vals, n_pure_tn_vals)
    if length(all_n_vals) > 0
        n_start = minimum(all_n_vals) - 4.5
        n_end = maximum(all_n_vals) + 4.5
    else
        n_start = 0
        n_end = 100
    end
    
    xlims!(ax1_top, n_start, n_end)
    xlims!(ax1_top_2, n_start, n_end)
    
    # 设置对应的阈值（log10 值）
    t_14_bb = 13165.399528717995
    branch_num_14 = 15376.6
    branch_num_one_hour = branch_num_14 / t_14_bb * 3600
    t_bb = log10(branch_num_one_hour)
    println("branch_num_one_hour: ", branch_num_one_hour)
    # 提前绘制右轴参考线，使其位于所有数据和文字下方
    hlines!(ax1_top_2, log10(branch_num_one_hour), color = "#8B0000", linestyle = :dashdot, linewidth = hwidth)
    
    # 两个轴都从 0 开始
    ylims!(ax1_top, 0, (tc_hour-log10(2)) * 2.3)
    ylims!(ax1_top_2, 0, log10(branch_num_one_hour) * 2.3)
    # ylims!(ax1_top, tc_hour-log10(2)-log10(branch_num_one_hour), (tc_hour-log10(2)) * 2.2)
    # ylims!(ax1_top_2, 0, log10(branch_num_one_hour) + (tc_hour-log10(2)) * 2.2 - tc_hour-log10(2))
    # 在对应位置画参考线
    # hlines!(ax1_top, tc_min-log10(2), color = :black, linestyle = hstyle, linewidth = hwidth)
    # text!(ax1_top, n_start + 1, tc_min-log10(2), text = L"$1$ min", color = :black, fontsize = 18)
    # hlines!(ax1_top, tc_hour-log10(2), color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1_top, n_start + 1, tc_hour-log10(2), text = L"$1$ hour", color = "#8B0000", fontsize = 18)
    hlines!(ax1_top, [tc_month-log10(2)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1_top, n_start + 1, tc_month-log10(2), text = L"$1$ month", color = :black, fontsize = 18)
    hlines!(ax1_top, [tc_1000000_years-log10(2)], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1_top, n_start + 1, tc_1000000_years-log10(2), text = L"$10^6$ years", color = :black, fontsize = 18)
    # txt_bb = text!(ax1_top_2, n_end - 1, log10(branch_num_one_hour) + 0.12,
    #                text = L"$1$ hour",
    #                color = :red,
    #                fontsize = 18)
    
    # hlines!(ax1_top_2, log10(branch_num_one_hour*24*30*12), color = colors[6], linestyle = :dashdot, linewidth = hwidth)
    # text!(ax1_top_2, n_end - 1, log10(branch_num_one_hour*24*30*12), text = L"$1$ year", color = colors[6], fontsize = 18, align = (:right, :center), offset = (6, 0))
    # ========== (c)：ground_counting_tc.jl ==========
    ax2_left = Axis(fig1[1, 2], 
        ylabel = L"t.c.\text{(Flops)}",
        xticks = (1:4, ["Spin Glass\nRRG", "Spin Glass\n3D Grid", "MIS\nRKSG", "MWIS\nMKSG"]),
        yticks = (0:5:30, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$", L"$10^{20}$", L"$10^{25}$", L"$10^{30}$"]),
        xticklabelsize = 13,
    )
    
    # 读取数据
    df_ground = CSV.read("../data/ground_state_counting/tc_ground_counting.csv", DataFrame)
    
    # 提取数据并转换为 log10
    total_tc_vals = log10.(2 .^ df_ground.total_tc)
    total_tc_slicing_vals = log10.(2 .^ df_ground.total_tc_slicing)
    
    # 准备柱状图数据
    cat = [1, 1, 2, 2, 3, 3, 4, 4]
    bar_grp = [1, 2, 1, 2, 1, 2, 1, 2]
    mean_times = Float64[]
    for i in 1:4
        push!(mean_times, total_tc_vals[i])
        push!(mean_times, total_tc_slicing_vals[i])
    end
    
    # 颜色设置
    bar_colors = [colors[2], colors[3]]
    
    # 绘制柱状图
    barplot!(ax2_left, cat, mean_times, dodge = bar_grp, color = bar_colors[bar_grp], strokecolor = :black, strokewidth = 1)
    
    # 设置 y 轴范围
    ylims!(ax2_left, 0, 25)
    
    
    hlines!(ax2_left, [tc_min-log10(2)], color = :black, linestyle = :dash, linewidth = 1)
    # hlines!(ax2_left, [one_day], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax2_left, [tc_month-log10(2)], color = :black, linestyle = :dash, linewidth = 1)
    
    text!(ax2_left, 0.05, tc_min-log10(2), text = L"$1$ min", fontsize = 18, color = :black)
    # text!(ax2_left, 0.05, one_day, text = L"$1$ day", fontsize = 15, color = :black)
    text!(ax2_left, 0.05, tc_month-log10(2), text = L"$1$ month", fontsize = 18, color = :black)
    
    xlims!(ax2_left, 0, 5)
    
    # (a) 的图例
    fig1a_legend_dict = Dict{String, Any}()
    fig1a_legend_dict["BBTN"] = sc_tc
    fig1a_legend_dict["Slicing"] = sc_tc_slicing
    # 为 Tropical-TN 创建蓝色填充的图例项
    if length(n_pure_tn_vals) > 0
        sc_pure_tn_legend = scatter!(ax1_top, [NaN], [NaN], markersize = t_cross, marker = :x, color = colors[1], strokewidth = 0, label = "Tropical-TN")
        fig1a_legend_dict["Tropical-TN"] = sc_pure_tn_legend
    end
    if length(n_bb_vals) > 0
        fig1a_legend_dict["Branch & Bound"] = sc_bb
    end
    # 按顺序构建图例
    fig1a_labels_order = ["BBTN", "Slicing", "Tropical-TN"]
    if length(n_bb_vals) > 0
        push!(fig1a_labels_order, "Branch & Bound")
    end
    fig1a_legend_items = [fig1a_legend_dict[label] for label in fig1a_labels_order if haskey(fig1a_legend_dict, label)]
    fig1a_legend_labels = [label for label in fig1a_labels_order if haskey(fig1a_legend_dict, label)]
    Legend(fig1[0, 1], fig1a_legend_items, fig1a_legend_labels, orientation = :horizontal, labelsize = 15, nbanks = 1, tellwidth = false, halign = :center)
    
    # (b) 的图例
    fig1b_legend_dict = Dict{String, Any}()
    fig1b_legend_dict["BBTN"] = PolyElement(polycolor = bar_colors[1])
    fig1b_legend_dict["Slicing"] = PolyElement(polycolor = bar_colors[2])
    fig1b_labels_order = ["BBTN", "Slicing"]
    fig1b_legend_items = [fig1b_legend_dict[label] for label in fig1b_labels_order if haskey(fig1b_legend_dict, label)]
    fig1b_legend_labels = [label for label in fig1b_labels_order if haskey(fig1b_legend_dict, label)]
    Legend(fig1[0, 2], fig1b_legend_items, fig1b_legend_labels, orientation = :horizontal, labelsize = 15, nbanks = 1, tellwidth = false, halign = :center)
    
    # 添加子图标签
    text!(ax1_top, 0, 1, text = L"\textbf{(a)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)
    text!(ax2_left, 0, 1, text = L"\textbf{(b)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)
    
    save("../figs/grouping_subgraphs_fig1.pdf", fig1)
    
    # ========== 第二幅图：(a) 和 (b) ==========
    fig2 = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (1000, 400), fontsize = 20)
    
    # ========== (b)：time_complexity.jl 的左子图 ==========
    ax1_right = Axis(fig2[1, 1], xlabel = L"N", ylabel = L"t.c. \text{ (Flops)}", xticks = (30:10:100, [L"30", L"40", L"50", L"60", L"70", L"80", L"90", L"100"]), yticks = (0:5:35, [L"10^0", L"10^{5}", L"10^{10}", L"10^{15}", L"10^{20}", L"10^{25}", L"10^{30}", L"10^{35}"]))
    
    n_tn = [50:10:100...]
    n_ds = [50:10:100...]
    n_tnbb = [50:10:100...]
    
    df_tn = [CSV.read("../data/complexity/random_ksg/original_ksg_n$(n).csv", DataFrame) for n in n_tn]
    df_ds = [CSV.read("../data/complexity/random_ksg/slice32_rksg_n$(n).csv", DataFrame) for n in n_ds]
    df_tnbb = [CSV.read("../data/complexity/random_ksg/tnbb_ksg_n$(n).csv", DataFrame) for n in n_tnbb]
    
    tc_tn = log10.(2 .^([geometric_mean(df_tn[i].tc) for i in 1:length(n_tn)]))
    tc_ds = log10.(2 .^([geometric_mean(df_ds[i].sliced_tc) for i in 1:length(n_ds)]))
    tc_tnbb = log10.(2 .^([geometric_mean(df_tnbb[i].total_tc) for i in 1:length(n_tnbb)]))
    
    @. model_tn(x, p) = p[1] * x + p[2]
    fit_tn = curve_fit(model_tn, n_tn, tc_tn, [1.0, 1.0])
    @. model_ds(x, p) = p[1] * x^p[2] + p[3]
    fit_ds = curve_fit(model_ds, n_ds, tc_ds, [1.0, 1.0, 1.0])
    @. model_tnbb(x, p) = p[1] * x + p[2]
    fit_tnbb = curve_fit(model_tnbb, n_tnbb[1:4], tc_tnbb[1:4], [1.0, 1.0])
    
    xs = range(45, 105, length = 100)
    
    lines!(ax1_right, xs, model_tn(xs, fit_tn.param), color = colors[1], linestyle = :dash)
    lines!(ax1_right, xs, model_ds(xs, fit_ds.param), color = colors[3], linestyle = :solid)
    lines!(ax1_right, xs, model_tnbb(xs, fit_tnbb.param), color = colors[2], linestyle = :solid)
    
    sc_tn = scatter!(ax1_right, n_tn, tc_tn, markersize = t_cross, marker = :x, color = colors[1], strokewidth = 0, label = "Tropical-TN")
    sc_ds = scatter!(ax1_right, n_ds, tc_ds, markersize = t, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "Slicing")
    sc_tnbb = scatter!(ax1_right, n_tnbb[1:4], tc_tnbb[1:4], markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "BBTN")
    scatter!(ax1_right, n_tnbb[5:end], tc_tnbb[5:end], markersize = t, marker = markerstyle[2], color = :white, strokewidth = 2, strokecolor = colors[2])
    
    xlims!(ax1_right, 45, 105)
    ylims!(ax1_right, 0, 35)
    
    hlines!(ax1_right, [tc_min], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1_right, 46, tc_min, text = L"$1$ min", color = :black, fontsize = 18)
    #hline for one hour
    # hlines!(ax1_right, [tc2_min], color = :black, linestyle = hstyle, linewidth = hwidth)
    # text!(ax1_right, 46, tc2_min, text = L"$1$ minute", color = :black, fontsize = 15)
    hlines!(ax1_right, [tc_month], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1_right, 46, tc_month, text = L"$1$ month", color = :black, fontsize = 18)
    # hlines!(ax1_right, [tc_day], color = :black, linestyle = hstyle, linewidth = hwidth)
    # text!(ax1_right, 46, tc_day, text = L"$1$ day", color = :black, fontsize = 15)
    # hlines!(ax1_right, [tc_month], color = :black, linestyle = hstyle, linewidth = hwidth)
    # text!(ax1_right, 46, tc_month, text = L"$1$ month", color = :black, fontsize = 15)
    hlines!(ax1_right, [tc_1000000_years], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1_right, 46, tc_1000000_years, text = L"$10^6$ years", color = :black, fontsize = 18)
    
    # ========== (d)：time_complexity.jl 的右子图 ==========
    ax2_right = Axis(fig2[1, 2], ylabel = L"\text{Runtime (s)}", 
        xticks = (1:5, ["RKSG\nN=60", "RKSG\nN=70", "RKSG\nN=80", "MKSG\nStructured", "MKSG\nRandom"]),
        yticks = (0:7, [L"10^0", L"10^1", L"10^2", L"10^3", L"10^4", L"10^5", L"10^6", L"10^7"]),
        xticklabelsize = 13,
    )
    
    df_ksg_60 = CSV.read("../data/runtime/ksg_n60_runtime_all.csv", DataFrame)
    df_ksg_70 = CSV.read("../data/runtime/ksg_n70_runtime_all.csv", DataFrame)
    df_ksg_80 = CSV.read("../data/runtime/ksg_n80_runtime_all.csv", DataFrame)
    
    df = CSV.read("../data/runtime/fact_k16_tnbb_ds_scip.csv", DataFrame)
    
    df_ksg_60_tnbb_time = df_ksg_60.tnbb_contract_runtime .+ df_ksg_60.tnbb_branch_runtime
    df_ksg_70_tnbb_time = df_ksg_70.tnbb_contract_runtime .+ df_ksg_70.tnbb_branch_runtime
    df_ksg_80_tnbb_time = df_ksg_80.tnbb_contract_runtime .+ df_ksg_80.tnbb_branch_runtime
    df_ksg_60_ds_time = df_ksg_60.ds_contract_runtime .+ df_ksg_60.ds_slice_runtime
    df_ksg_70_ds_time = df_ksg_70.ds_contract_runtime .+ df_ksg_70.ds_slice_runtime
    df_ksg_80_ds_time = df_ksg_80.ds_contract_runtime .+ df_ksg_80.ds_slice_runtime
    
    # Extract mean times for each category and algorithm
    rksg_60_means = [mean(df_ksg_60_tnbb_time), mean(df_ksg_60_ds_time), mean(df_ksg_60.scip_runtime)]
    rksg_70_means = [mean(df_ksg_70_tnbb_time), mean(df_ksg_70_ds_time), mean(df_ksg_70.scip_runtime)]
    rksg_80_means = [mean(df_ksg_80_tnbb_time), mean(df_ksg_80_ds_time), mean(df_ksg_80.scip_runtime)]
    
    rksg_60_mins = [minimum(df_ksg_60_tnbb_time), minimum(df_ksg_60_ds_time), minimum(df_ksg_60.scip_runtime)]
    rksg_70_mins = [minimum(df_ksg_70_tnbb_time), minimum(df_ksg_70_ds_time), minimum(df_ksg_70.scip_runtime)]
    rksg_80_mins = [minimum(df_ksg_80_tnbb_time), minimum(df_ksg_80_ds_time), minimum(df_ksg_80.scip_runtime)]
    
    rksg_60_maxs = [maximum(df_ksg_60_tnbb_time), maximum(df_ksg_60_ds_time), maximum(df_ksg_60.scip_runtime)]
    rksg_70_maxs = [maximum(df_ksg_70_tnbb_time), maximum(df_ksg_70_ds_time), maximum(df_ksg_70.scip_runtime)]
    rksg_80_maxs = [maximum(df_ksg_80_tnbb_time), maximum(df_ksg_80_ds_time), maximum(df_ksg_80.scip_runtime)]
    
    if_easy_means = [df[df.name .== "IF_EASY", :bbtn_mean_time][1], 
                     df[df.name .== "IF_EASY", :ttn_mean_time][1], 
                     df[df.name .== "IF_EASY", :scip_mean_time][1]]
    
    if_hard_means = [df[df.name .== "IF_HARD", :bbtn_mean_time][1], 
                     df[df.name .== "IF_HARD", :ttn_mean_time][1], 
                     df[df.name .== "IF_HARD", :scip_mean_time][1]]
    
    # Extract min and max times for error bars
    rksg_mins = [df[df.name .== "rksg", :bbtn_min_time][1], 
                 df[df.name .== "rksg", :ttn_min_time][1], 
                 df[df.name .== "rksg", :scip_min_time][1]]
    
    rksg_maxs = [df[df.name .== "rksg", :bbtn_max_time][1], 
                 df[df.name .== "rksg", :ttn_max_time][1], 
                 df[df.name .== "rksg", :scip_max_time][1]]
    
    if_easy_mins = [df[df.name .== "IF_EASY", :bbtn_min_time][1], 
                    df[df.name .== "IF_EASY", :ttn_min_time][1], 
                    df[df.name .== "IF_EASY", :scip_min_time][1]]
    
    if_easy_maxs = [df[df.name .== "IF_EASY", :bbtn_max_time][1], 
                    df[df.name .== "IF_EASY", :ttn_max_time][1], 
                    df[df.name .== "IF_EASY", :scip_max_time][1]]
    
    if_hard_mins = [df[df.name .== "IF_HARD", :bbtn_min_time][1], 
                    df[df.name .== "IF_HARD", :ttn_min_time][1], 
                    df[df.name .== "IF_HARD", :scip_min_time][1]]
    
    if_hard_maxs = [df[df.name .== "IF_HARD", :bbtn_max_time][1], 
                    df[df.name .== "IF_HARD", :ttn_max_time][1], 
                    df[df.name .== "IF_HARD", :scip_max_time][1]]
    
    # Combine all data
    mean_times = vcat(rksg_60_means, rksg_70_means, rksg_80_means, if_easy_means, if_hard_means)
    min_times = vcat(rksg_60_mins, rksg_70_mins, rksg_80_mins, if_easy_mins, if_hard_mins)
    max_times = vcat(rksg_60_maxs, rksg_70_maxs, rksg_80_maxs, if_easy_maxs, if_hard_maxs)
    
    # Cap extreme values
    max_time = 1e7
    mean_times = map(x -> x > max_time ? max_time : x, mean_times)
    min_times = map(x -> x > max_time ? max_time : x, min_times)
    max_times = map(x -> x > max_time ? max_time : x, max_times)
    
    cat = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5]
    bar_grp = [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
    
    runtime_colors = ["#E36D44","#228833", "#CCBB44", "#CCBB44", "#228833", "#E36D44"]
    barplot!(ax2_right, cat, log10.(mean_times), dodge = bar_grp, color = runtime_colors[bar_grp], strokecolor = :black, strokewidth = 1)
    
    # Add error bars
    dodge_width = 0.8
    bar_width = dodge_width / 3
    
    for i in 1:length(cat)
        x_pos = cat[i] + (bar_grp[i] - 2) * bar_width
        y_mean = log10(mean_times[i])
        y_min = log10(min_times[i])
        y_max = log10(max_times[i])
        
        lines!(ax2_right, [x_pos, x_pos], [y_min, y_max], color = :black, linewidth = 1)
        cap_width = 0.05
        lines!(ax2_right, [x_pos - cap_width, x_pos + cap_width], [y_min, y_min], color = :black, linewidth = 1)
        lines!(ax2_right, [x_pos - cap_width, x_pos + cap_width], [y_max, y_max], color = :black, linewidth = 1)
    end
    
    ylims!(ax2_right, 0, 7)
    
    # Add horizontal lines and labels for time references
    one_hour = log10(3600)
    one_day = log10(24 * 3600)
    ten_days = log10(7 * 24 * 3600)
    
    hlines!(ax2_right, [one_hour], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax2_right, [one_day], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax2_right, [ten_days], color = :black, linestyle = :dash, linewidth = 1)
    
    text!(ax2_right, 0.05, one_hour, text = L"$1$ hour", fontsize = 18, color = :black)
    text!(ax2_right, 0.05, one_day, text = L"$1$ day", fontsize = 18, color = :black)
    text!(ax2_right, 0.05, ten_days, text = L"$1$ week", fontsize = 18, color = :black)
    
    xlims!(ax2_right, 0, 6)
    
    # (a) 的图例
    fig2a_legend_dict = Dict{String, Any}()
    fig2a_legend_dict["BBTN"] = sc_tnbb
    fig2a_legend_dict["Slicing"] = sc_ds
    sc_tn_legend = scatter!(ax1_right, [NaN], [NaN], markersize = t_cross, marker = :x, color = colors[1], strokewidth = 0, label = "Tropical-TN")
    fig2a_legend_dict["Tropical-TN"] = sc_tn_legend
    # 按顺序构建图例
    fig2a_labels_order = ["BBTN", "Slicing", "Tropical-TN"]
    fig2a_legend_items = [fig2a_legend_dict[label] for label in fig2a_labels_order if haskey(fig2a_legend_dict, label)]
    fig2a_legend_labels = [label for label in fig2a_labels_order if haskey(fig2a_legend_dict, label)]
    Legend(fig2[0, 1], fig2a_legend_items, fig2a_legend_labels, labelsize = 15, orientation = :horizontal, nbanks = 1, tellwidth = false, halign = :center)
    
    # (b) 的图例
    fig2b_legend_dict = Dict{String, Any}()
    fig2b_legend_dict["BBTN"] = PolyElement(polycolor = runtime_colors[1])
    fig2b_legend_dict["Slicing"] = PolyElement(polycolor = runtime_colors[2])
    fig2b_legend_dict["SCIP"] = PolyElement(polycolor = runtime_colors[3])
    fig2b_labels_order = ["BBTN", "Slicing", "SCIP"]
    fig2b_legend_items = [fig2b_legend_dict[label] for label in fig2b_labels_order if haskey(fig2b_legend_dict, label)]
    fig2b_legend_labels = [label for label in fig2b_labels_order if haskey(fig2b_legend_dict, label)]
    Legend(fig2[0, 2], fig2b_legend_items, fig2b_legend_labels, labelsize = 15, orientation = :horizontal, nbanks = 1, tellwidth = false, halign = :center)
    
    # 添加子图标签
    text!(ax1_right, 0, 1, text = L"\textbf{(a)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)
    text!(ax2_right, 0, 1, text = L"\textbf{(b)}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)
    
    save("../figs/grouping_subgraphs_fig2.pdf", fig2)
    
    (fig1, fig2)
end
