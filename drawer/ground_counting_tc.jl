include("settings.jl")

begin
    fig = Figure(size = (500, 400), fontsize = 20)
    
    ax = Axis(fig[2, 1], 
        ylabel = L"\text{t.c. (Flops)}",
        xticks = (1:4, ["Spin Glass\nRRG", "Spin Glass\n3D Grid", "MIS\nRKSG", "MWIS\nMKSG"]),
        yticks = (0:5:30, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$", L"$10^{20}$", L"$10^{25}$", L"$10^{30}$"]),
        xticklabelsize = 13,
    )
    
    # 读取数据
    df = CSV.read("../data/ground_state_counting/tc_ground_counting.csv", DataFrame)
    
    # 提取数据并转换为 log10
    total_tc_vals = log10.(2 .^ df.total_tc)
    total_tc_slicing_vals = log10.(2 .^ df.total_tc_slicing)
    
    # 准备柱状图数据
    # 每个模型一行，每行有两个柱子：total_tc 和 total_tc_slicing
    cat = [1, 1, 2, 2, 3, 3, 4, 4]  # 4个模型，每个2个柱子
    bar_grp = [1, 2, 1, 2, 1, 2, 1, 2]  # 每个模型有2个柱子
    mean_times = Float64[]
    for i in 1:4
        push!(mean_times, total_tc_vals[i])
        push!(mean_times, total_tc_slicing_vals[i])
    end
    
    # 颜色设置
    bar_colors = [colors[2], colors[3]]  # BBTN 和 Slicing 的颜色
    
    # 绘制柱状图
    barplot!(ax, cat, mean_times, dodge = bar_grp, color = bar_colors[bar_grp], strokecolor = :black, strokewidth = 1)
    
    # 设置 y 轴范围
    ylims!(ax, 0, 22)
    
    # 添加水平参考线
    one_min = tc_min
    one_day = tc_day
    one_year = tc_year
    
    hlines!(ax, [one_min], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [one_day], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [one_year], color = :black, linestyle = :dash, linewidth = 1)
    
    text!(ax, 0.05, one_min, text = L"$1$ min", fontsize = 13.5, color = :black)
    text!(ax, 0.05, one_day, text = L"$1$ day", fontsize = 13.5, color = :black)
    text!(ax, 0.05, one_year, text = L"$1$ year", fontsize = 13.5, color = :black)
    
    xlims!(ax, 0, 5)
    
    # 图例
    Legend(fig[1, 1], [PolyElement(polycolor = bar_colors[i]) for i in 1:2], ["BBTN", "Slicing"], labelsize = 15, orientation = :horizontal)
    
    save("../figs/ground_counting_tc.pdf", fig)
    fig
end

