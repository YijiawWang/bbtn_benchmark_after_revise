include("settings.jl")
t = 15

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (1000, 400), fontsize = 20)

    # Left subplot - N40RKSG
    ax1 = Axis(fig[2, 1], xlabel = L"\Delta s.c.", ylabel = L"t.c. \text{ (Flops)}", 
        xticks = (0:2:10, [L"0", L"2", L"4", L"6", L"8", L"10"]), 
        yticks = (35:5:45, [L"2^{35}", L"2^{40}", L"2^{45}"]))

    # Right subplot - N200D3
    ax2 = Axis(fig[2, 2], xlabel = L"\Delta s.c.", ylabel = L"t.c. \text{ (Flops)}", 
        xticks = (0:2:12, [L"0", L"2", L"4", L"6", L"8", L"10", L"12"]), 
        yticks = (25:5:45, [L"2^{25}", L"2^{30}", L"2^{35}", L"2^{40}", L"2^{45}"]))

    # Load data
    df_n40rksg = CSV.read("../data/compared_with_uniform/n40rksg_seed1_tc.csv", DataFrame)
    df_n200d3 = CSV.read("../data/compared_with_uniform/n200d3_seed1_tc.csv", DataFrame)

    # Extract N40RKSG data
    delta_sc_n40rksg = df_n40rksg.delta_sc
    nu_5_n40rksg = df_n40rksg.nu_5
    nu_20_n40rksg = df_n40rksg.nu_20
    uniform_5_n40rksg = df_n40rksg.uniform_5
    uniform_20_n40rksg = df_n40rksg.uniform_20

    # Extract N200D3 data
    delta_sc_n200d3 = df_n200d3.delta_sc
    nu_5_n200d3 = df_n200d3.nu_5
    nu_20_n200d3 = df_n200d3.nu_20
    uniform_5_n200d3 = df_n200d3.uniform_5
    uniform_20_n200d3 = df_n200d3.uniform_20

    # Plot N40RKSG data (left subplot) - point line plot
    lines!(ax1, delta_sc_n40rksg, nu_5_n40rksg, color = colors[2], linewidth = 2, label = "NU slicing: Region_size=5")
    scatter!(ax1, delta_sc_n40rksg, nu_5_n40rksg, markersize = t, marker = markerstyle[1], color = colors[2], strokewidth = strokewidth, strokecolor = :black)
    
    lines!(ax1, delta_sc_n40rksg, nu_20_n40rksg, color = colors[2], linewidth = 2, label = "Region_size=20")
    scatter!(ax1, delta_sc_n40rksg, nu_20_n40rksg, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black)
    
    lines!(ax1, delta_sc_n40rksg, uniform_5_n40rksg, color = colors[4], linewidth = 2, label = "Uniform slicing: Region_size=5")
    scatter!(ax1, delta_sc_n40rksg, uniform_5_n40rksg, markersize = t, marker = markerstyle[1], color = colors[4], strokewidth = strokewidth, strokecolor = :black)
    
    lines!(ax1, delta_sc_n40rksg, uniform_20_n40rksg, color = colors[4], linewidth = 2, label = "Region_size=20")
    scatter!(ax1, delta_sc_n40rksg, uniform_20_n40rksg, markersize = t, marker = markerstyle[2], color = colors[4], strokewidth = strokewidth, strokecolor = :black)

    # Plot N200D3 data (right subplot) - point line plot
    lines!(ax2, delta_sc_n200d3, nu_5_n200d3, color = colors[2], linewidth = 2, label = "NU slicing: Region_size=5")
    scatter!(ax2, delta_sc_n200d3, nu_5_n200d3, markersize = t, marker = markerstyle[1], color = colors[2], strokewidth = strokewidth, strokecolor = :black)
    
    lines!(ax2, delta_sc_n200d3, nu_20_n200d3, color = colors[2], linewidth = 2, label = "Region_size=20")
    scatter!(ax2, delta_sc_n200d3, nu_20_n200d3, markersize = t, marker = markerstyle[2], color = colors[2], strokewidth = strokewidth, strokecolor = :black)
    
    lines!(ax2, delta_sc_n200d3, uniform_5_n200d3, color = colors[4], linewidth = 2, label = "Uniform slicing: Region_size=5")
    scatter!(ax2, delta_sc_n200d3, uniform_5_n200d3, markersize = t, marker = markerstyle[1], color = colors[4], strokewidth = strokewidth, strokecolor = :black)
    
    lines!(ax2, delta_sc_n200d3, uniform_20_n200d3, color = colors[4], linewidth = 2, label = "Region_size=20")
    scatter!(ax2, delta_sc_n200d3, uniform_20_n200d3, markersize = t, marker = markerstyle[2], color = colors[4], strokewidth = strokewidth, strokecolor = :black)

    # Set axis limits
    xlims!(ax1, -1, 10)
    ylims!(ax1, 35, 45)
    xlims!(ax2, -1, 13)
    ylims!(ax2, 25, 35)

    # Create shared legend - using line and scatter elements
    # NU slicing elements
    nu_line1 = LineElement(color = colors[2], linewidth = 2)
    nu_scatter1 = MarkerElement(marker = markerstyle[1], color = colors[2], markersize = t, strokewidth = strokewidth, strokecolor = :black)
    nu_line2 = LineElement(color = colors[2], linewidth = 2)
    nu_scatter2 = MarkerElement(marker = markerstyle[2], color = colors[2], markersize = t, strokewidth = strokewidth, strokecolor = :black)
    
    # Uniform slicing elements
    uniform_line1 = LineElement(color = colors[4], linewidth = 2)
    uniform_scatter1 = MarkerElement(marker = markerstyle[1], color = colors[4], markersize = t, strokewidth = strokewidth, strokecolor = :black)
    uniform_line2 = LineElement(color = colors[4], linewidth = 2)
    uniform_scatter2 = MarkerElement(marker = markerstyle[2], color = colors[4], markersize = t, strokewidth = strokewidth, strokecolor = :black)
    
    # Slicing elements
    # slicing_line = LineElement(color = colors[1], linewidth = 2)
    # slicing_scatter = MarkerElement(marker = markerstyle[3], color = colors[1], markersize = t, strokewidth = strokewidth, strokecolor = :black)
    
    # Create composite elements (line + scatter)
    element1 = [nu_line1, nu_scatter1]
    element2 = [nu_line2, nu_scatter2]
    element3 = [uniform_line1, uniform_scatter1]
    element4 = [uniform_line2, uniform_scatter2]
    # element5 = [slicing_line, slicing_scatter]
    
    # Shared legend spanning both subplots - FORCE 2 ROWS 2 COLS
    Legend(fig[1, 1:2], [element1, element2, element3, element4], 
           ["NU: |R|=5", "NU: |R|=20", "Vanilla: |R|=5", "Vanilla: |R|=20"], 
           orientation = :horizontal, labelsize = 15, ncol = 3, rowgap = 5, colgap = 20)

    # Add subplot labels and titles
    text!(ax1, 0, 1, text = L"\textbf{(a) RKSG}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)
    text!(ax2, 0, 1, text = L"\textbf{(b) RRG}", align = (:left, :top), fontsize = 20, space = :relative, offset = (4, -4), font = :bold)

    save("../figs/compare_nu_u.pdf", fig)

    fig
end