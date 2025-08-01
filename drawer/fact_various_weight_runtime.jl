include("settings.jl")

# begin
#     df_branch = CSV.read("../data/runtime/branch_runtime_ksg_n70.csv", DataFrame)
#     df_contract = CSV.read("../data/runtime/contract_runtime_ksg_n70.csv", DataFrame)
#     scs = 32 .- df_branch.ds

#     fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 350), fontsize = 20)
#     ax = Axis(fig[1, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{Runtime (s)}", yscale = log2, xticks = (-scs, string.(scs)))

#     xlims!(ax, (- 31.5, -26.5))
#     ylims!(ax, (2^4, 2^10))

#     sc_branch = scatter!(ax, - scs, df_branch.runtime, markersize = markersize, marker = markerstyle[1], color = colors[1], strokewidth = strokewidth, strokecolor = :black, label = "branching phase")
#     sc_contract = scatter!(ax, - scs, df_contract.runtime, markersize = markersize, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black, label = "contraction phase")
#     sc_total = scatter!(ax, - scs, df_branch.runtime + df_contract.runtime, markersize = markersize, marker = markerstyle[3], color = colors[3], strokewidth = strokewidth, strokecolor = :black, label = "total")

#     # Legend(fig[2, :], [sc_branch, sc_contract, sc_total], ["branching phase", "contraction phase", "total"], orientation = :horizontal, nbanks = 1, labelsize = 12)
#     axislegend(ax, position = :lt, labelsize = 12)

#     # ax2 = Axis(fig[2, 1], xlabel = L"\text{log}_2(\text{sc})", ylabel = L"\text{log}_2(\text{tc})", xticks = (-scs, string.(scs)))
#     # scatter!(ax2, - scs, df_branch.total_tc, markersize = markersize, marker = markerstyle[4], color = colors[4], strokewidth = strokewidth, strokecolor = :black, label = "total tc")

#     # axislegend(ax2, position = :lt, labelsize = 12)
#     # xlims!(ax2, (- 31.5, -26.5))
#     # ylims!(ax2, (44, 46))

#     save("../figs/ksg_runtime.pdf", fig)

#     fig
# end

# time to solve ksg 70x70, sc = 31
begin
    # 读取CSV文件并提取数组
    df = CSV.read("../data/runtime/fact_k16_tnbb_ds_scip.csv", DataFrame)
    
    # 将每一行数据存储到同名数组中
    infoW = [df[1, :tnbb_branching_time], df[1, :tnbb_contract_time], df[1, :dynamic_slicing_time], df[1, :scip_time]]
    onesW = [df[2, :tnbb_branching_time], df[2, :tnbb_contract_time], df[2, :dynamic_slicing_time], df[2, :scip_time]]
    randW = [df[3, :tnbb_branching_time], df[3, :tnbb_contract_time], df[3, :dynamic_slicing_time], df[3, :scip_time]]
    
    
    # 打印数据用于调试
    println("infoW: $infoW")
    println("onesW: $onesW")
    println("randW: $randW")
    
    # 创建柱状图
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 450), fontsize = 20)
    ax = Axis(fig[2, 1], 
        xlabel = "Weight Type", 
        ylabel = L"\text{log}_2(\text{Runtime}) \text{ (s)}", 
        xticks = (1:3, ["Information\nencoded", "All-ones\n", "Random\nweights"])
    )
    
    # 准备数据
    x_positions = [1, 2, 3]  # factorization, arbitrary_mis, qubo
    problem_data = [infoW, onesW, randW]
    

    heights = []
    for (i, data) in enumerate(problem_data)
        tnbb_total = data[1] + data[2]
        push!(heights, log2(tnbb_total) * data[1] / tnbb_total)
        push!(heights, log2(tnbb_total) * data[2] / tnbb_total)
        push!(heights, log2(data[3]))
        push!(heights, log2(data[4]))
    end

    x_grp = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3]
    bar_grp = [1, 1, 2, 3, 1, 1, 2, 3, 1, 1, 2, 3]
    y_grp = [1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1]

    cat = [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]

    barplot!(ax, x_grp, heights,
       dodge = bar_grp,
       stack = y_grp,
       color = colors[cat],)

    # 添加cut-off线
    cut_off_y = log2(100000)
    hlines!(ax, [cut_off_y], color = :black, linestyle = :dash, linewidth = 2)
    
    # 在右边添加"timeout"标签
    text!(ax, 3.2, cut_off_y - 0.5, text = "timeout", align = (:left, :center), fontsize = 12)

    # 绘制每个问题的柱状图
    # for (i, data) in enumerate(problem_data)
    #     tnbb_branching = data[1]  # tnbb_branching_time
    #     tnbb_contract = data[2]   # tnbb_contract_time
        
    #     # 绘制第一个柱子：TNBB Total，分为两部分
    #     # 下半部分：branching time
    #     barplot!(ax, [i], [tnbb_branching], 
    #         color = colors[1], 
    #         width = 0.6
    #     )
        
    #     # 上半部分：contract time（堆叠在branching time上面）
    #     barplot!(ax, [i], [tnbb_contract], 
    #         color = colors[2], 
    #         width = 0.6,
    #         stack = [1, 1, 1]  # 堆叠在第一个柱子上
    #     )
        
    #     # 绘制第二个柱子：dynamic_slicing_time
    #     barplot!(ax, [i + 0.4], [data[3]], 
    #         color = colors[3], 
    #         width = 0.6
    #     )
    # end
    
    # # 手动添加图例
    Legend(fig[1, :], 
        [PolyElement(polycolor = colors[1]), PolyElement(polycolor = colors[2]), PolyElement(polycolor = colors[3]),PolyElement(polycolor = colors[4])],
        ["TNBB Branching", "TNBB Contract", "Dynamic Slicing", "SCIP"],
        nbanks = 1,
        labelsize = 9,
        orientation = :horizontal
    )
    
    # 保存图片（PDF和PNG格式）
    save("../figs/fact_various_weight_runtime.pdf", fig)
    save("../figs/fact_various_weight_runtime.png", fig, px_per_unit = 3)
    
    fig
end

