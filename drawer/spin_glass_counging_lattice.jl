include("settings.jl")

begin
    fig = Figure(size = (500, 350), fontsize = 20)
    ax1 = Axis(fig[2, 1], xlabel = L"N", ylabel = L"t.c.\text{(Flops)}", xticks = (10:10:60, [L"10", L"20", L"30", L"40", L"50", L"60"]), yticks = (0:5:30, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$", L"$10^{20}$", L"$10^{25}$", L"$10^{30}$"]))
    ax1_2 = Axis(fig[2, 1], yaxisposition = :right, ylabel = L"N_{BB}", ygridvisible = false, yticks = ([0,2,4,6,8,10], [L"$10^0$", L"$10^2$", L"$10^4$", L"$10^6$", L"$10^8$", L"$10^{10}$"]))

    hidespines!(ax1_2)
    hidexdecorations!(ax1_2)

    # 读取数据
    df = CSV.read("../data/spin_glass_counting/lattice_J+-1_h_05.csv", DataFrame, missingstring=["-", ""])
    
    # 提取数据（只处理有效的 total_tc_mean 和 total_tc_slicing_mean）
    n_vals = Int[]
    total_tc_mean_vals = Float64[]
    total_tc_slicing_mean_vals = Float64[]
    
    for i in 1:nrow(df)
        tc_mean_val = df.total_tc_mean[i]
        tc_slicing_val = df.total_tc_slicing_mean[i]
        
        # 只处理两个值都有效的情况
        if !ismissing(tc_mean_val) && !ismissing(tc_slicing_val) && 
           !isnan(tc_mean_val) && !isnan(tc_slicing_val) &&
           tc_mean_val > 0 && tc_slicing_val > 0
            push!(n_vals, df.n[i])
            push!(total_tc_mean_vals, log10(2^tc_mean_val))
            push!(total_tc_slicing_mean_vals, log10(2^tc_slicing_val))
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
    for i in 1:nrow(df)
        val = df.pure_tn_tc[i]
        if !ismissing(val) && !isnan(val) && val > 0
            push!(n_pure_tn_vals, df.n[i])
            push!(pure_tn_tc_vals, log10(2^val))
        end
    end
    
    # bb_branch_num 可能为空，需要处理
    bb_branch_num_vals = Float64[]
    n_bb_vals = Int[]
    for i in 1:nrow(df)
        val = df.bb_branch_num[i]
        if !ismissing(val) && !isnan(val) && val > 0
            push!(n_bb_vals, df.n[i])
            push!(bb_branch_num_vals, log10(val))
        end
    end

    # 绘制散点图
    sc_tc = scatter!(ax1, n_vals, total_tc_mean_vals, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "total_tc_mean")
    sc_tc_slicing = scatter!(ax1, n_vals, total_tc_slicing_mean_vals, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "total_tc_slicing_mean")
    
    # 绘制 pure_tn_tc（空心蓝色点）
    if length(n_pure_tn_vals) > 0
        sc_pure_tn = scatter!(ax1, n_pure_tn_vals, pure_tn_tc_vals, markersize = markersize, marker = markerstyle[1], color = :white, strokewidth = 2, strokecolor = colors[1], label = "pure_tn_tc")
    end
    
    if length(n_bb_vals) > 0
        sc_bb = scatter!(ax1_2, n_bb_vals, bb_branch_num_vals, markersize = markersize, marker = markerstyle[1], color = colors[5], strokewidth = strokewidth, strokecolor = :black, label = "bb_branch_num")
    end

    # 设置 x 轴和 y 轴范围（包含所有有效的 n 值）
    all_n_vals = vcat(n_vals, n_bb_vals, n_pure_tn_vals)
    n_start = minimum(all_n_vals) - 6.5
    n_end = maximum(all_n_vals) + 6.5
    
    xlims!(ax1, n_start, n_end)
    xlims!(ax1_2, n_start, n_end)
    
    # 设置对应的阈值（log10 值）
    t0_tc = log10(2^52.72703455212527/60)  # 左侧轴对应 1 min 的值
    t0_bb = log10(2^13.661416871102356/60)  # 右侧轴对应 1 min 的值

    t_tc = log10(2^52.72703455212527)  # 左侧轴对应 1 hour 的值
    t_bb = log10(2^13.661416871102356)  # 右侧轴对应 1 hour 的值

    t1_tc = log10(2^52.72703455212527*24*30)  # 左侧轴对应 1 month 的值
    t1_bb = log10(2^13.661416871102356*24*30)  # 右侧轴对应 1 month 的值

    t2_tc = log10(2^52.72703455212527*24*30*12*10000)  # 左侧轴对应 10000 year 的值
    t2_bb = log10(2^13.661416871102356*24*30*12*10000)  # 右侧轴对应 10000 year 的值
    
    # 两个轴都从 0 开始
    ylims!(ax1, 0, t_tc * 1.9)
    ylims!(ax1_2, 0, t_bb * 1.9)
    
    # 在对应位置画 1 min 线
    hlines!(ax1, [t0_tc], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, n_start + 1, t0_tc, text = L"$\sim 1$ min", color = :black, fontsize = 13.5)

    # 在对应位置画 1 month 线
    hlines!(ax1, [t1_tc], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, n_start + 1, t1_tc, text = L"$\sim 1$ month", color = :black, fontsize = 13.5)

    # 在对应位置画 10000 year 线
    hlines!(ax1, [t2_tc], color = :black, linestyle = hstyle, linewidth = hwidth)
    text!(ax1, n_start + 1, t2_tc, text = L"$\sim 10000$ years", color = :black, fontsize = 13.5)

    # 图例
    legend_items = [sc_tc, sc_tc_slicing]
    legend_labels = ["BBTN", "Slicing"]
    if length(n_pure_tn_vals) > 0
        push!(legend_items, sc_pure_tn)
        push!(legend_labels, "Tropical-TN")
    end
    if length(n_bb_vals) > 0
        push!(legend_items, sc_bb)
        push!(legend_labels, "Branch & Bound")
    end
    Legend(fig[1, :], legend_items, legend_labels, position = :lt, labelsize = 15, orientation = :horizontal, nbanks = 1)

    save("../figs/spin_glass_counting_lattice.pdf", fig)
    fig
end

