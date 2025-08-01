include("settings.jl")

# 读取数据
df = CSV.read("../data/complexity/mapped_ksg/k16_tnbb_ds.csv", DataFrame)

# 提取数据
delta_sc = df[!, :delta_sc]
slice_num_tnbb = df[!, :slice_num_tnbb]
slice_num_ds = df[!, :slice_num_dynamic_slicing]
total_tc_tnbb = df[!, :total_tc_tnbb]
total_tc_ds = df[!, :total_tc_dynamic_slicing]

# 图1：slice_num对比
begin
    fig1 = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 400), fontsize = 20)
    ax1 = Axis(fig1[1, 1], 
        xlabel = L"\Delta \text{sc}", 
        ylabel = L"\text{Slice Number}",
        yscale = log2
    )
    
    # 绘制散点图
    sc_tnbb = scatter!(ax1, delta_sc, slice_num_tnbb, 
        markersize = markersize, 
        marker = markerstyle[1], 
        color = colors[1], 
        strokewidth = strokewidth, 
        strokecolor = :black, 
        label = "TNBB"
    )
    
    sc_ds = scatter!(ax1, delta_sc, slice_num_ds, 
        markersize = markersize, 
        marker = markerstyle[2], 
        color = colors[2], 
        strokewidth = strokewidth, 
        strokecolor = :black, 
        label = "Dynamic Slicing"
    )
    
    # 设置坐标轴范围
    xlims!(ax1, 0, 6)
    ylims!(ax1, 1, 10^7)
    
    # 添加图例
    axislegend(ax1, position = :lt, labelsize = 12)
    
    # 添加子图标签
    text!(ax1, 0, 1, text = "(a)", align = (:left, :top), fontsize = 25, font = :bold, space = :relative, offset = (4, -2))
    
    # 保存图片
    save("../figs/mapped_ksg_slice_num_comparison.pdf", fig1)
    save("../figs/mapped_ksg_slice_num_comparison.png", fig1, px_per_unit = 3)
    
    fig1
end

# 图2：total_tc对比
begin
    fig2 = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (500, 400), fontsize = 20)
    ax2 = Axis(fig2[1, 1], 
        xlabel = L"\Delta \text{sc}", 
        ylabel = L"\text{Total TC}"
    )
    
    # 绘制散点图
    sc_tnbb_tc = scatter!(ax2, delta_sc, total_tc_tnbb, 
        markersize = markersize, 
        marker = markerstyle[1], 
        color = colors[1], 
        strokewidth = strokewidth, 
        strokecolor = :black, 
        label = "TNBB"
    )
    
    sc_ds_tc = scatter!(ax2, delta_sc, total_tc_ds, 
        markersize = markersize, 
        marker = markerstyle[2], 
        color = colors[2], 
        strokewidth = strokewidth, 
        strokecolor = :black, 
        label = "Dynamic Slicing"
    )
    
    # 设置坐标轴范围
    xlims!(ax2, 0, 6)
    ylims!(ax2, 50, 65)
    
    # 添加图例
    axislegend(ax2, position = :lt, labelsize = 12)
    
    # 添加子图标签
    text!(ax2, 0, 1, text = "(b)", align = (:left, :top), fontsize = 25, font = :bold, space = :relative, offset = (4, -2))
    
    # 保存图片
    save("../figs/mapped_ksg_total_tc_comparison.pdf", fig2)
    save("../figs/mapped_ksg_total_tc_comparison.png", fig2, px_per_unit = 3)
    
    fig2
end

# 打印数据用于验证
println("Delta SC: $delta_sc")
println("TNBB Slice Numbers: $slice_num_tnbb")
println("DS Slice Numbers: $slice_num_ds")
println("TNBB Total TC: $total_tc_tnbb")
println("DS Total TC: $total_tc_ds") 