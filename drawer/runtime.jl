include("settings.jl")

begin
    # Load data from the new CSV file
    df = CSV.read("../data/runtime/fact_k16_tnbb_ds_scip.csv", DataFrame)
    
    # Extract mean times for each category and algorithm
    rksg_means = [df[df.name .== "rksg", :bbtn_mean_time][1], 
                  df[df.name .== "rksg", :ttn_mean_time][1], 
                  df[df.name .== "rksg", :scip_mean_time][1]]
    
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
    mean_times = vcat(rksg_means, if_easy_means, if_hard_means)
    min_times = vcat(rksg_mins, if_easy_mins, if_hard_mins)
    max_times = vcat(rksg_maxs, if_easy_maxs, if_hard_maxs)
    
    # Cap extreme values
    max_time = 1000000
    mean_times = map(x -> x > max_time ? max_time : x, mean_times)
    min_times = map(x -> x > max_time ? max_time : x, min_times)
    max_times = map(x -> x > max_time ? max_time : x, max_times)

    cat = [1, 1, 1, 2, 2, 2, 3, 3, 3]
    bar_grp = [1, 2, 3, 1, 2, 3, 1, 2, 3]

    runtime_colors = ["#E36D44","#228833", "#CCBB44"]
    fig = Figure(size = (500, 400), fontsize = 15)
    ax = Axis(fig[2, 1], 
        # xlabel = "Problem Type", 
        ylabel = L"$T$ (s)", 
        xticks = (1:3, ["Random\n KSG", "IF mappped\nKSG - EASY", "IF mappped\nKSG - HARD"]),
        yticks = (0:6, [L"10^0", L"10^1", L"10^2", L"10^3", L"10^4", L"10^5", L"10^6"]),
        xgridvisible = false,
        ygridvisible = true
    )
    # Create barplot with mean values and black borders
    barplot!(ax, cat, log10.(mean_times), dodge = bar_grp, color = runtime_colors[bar_grp], strokecolor = :black, strokewidth = 1)
    
    # Add error bars - calculate precise positions
    # For dodge barplot, the default dodge width is 0.8, so each bar is offset by 0.8/3 ≈ 0.267
    dodge_width = 0.8
    bar_width = dodge_width / 3  # Each bar takes 1/3 of the dodge width
    
    for i in 1:length(cat)
        # Calculate precise x position for each bar
        # Base position is cat[i], then offset by (bar_grp[i] - 2) * bar_width
        # where 2 is the middle group (bar_grp values are 1, 2, 3)
        x_pos = cat[i] + (bar_grp[i] - 2) * bar_width
        
        y_mean = log10(mean_times[i])
        y_min = log10(min_times[i])
        y_max = log10(max_times[i])
        
        # Draw vertical line from min to max
        lines!(ax, [x_pos, x_pos], [y_min, y_max], color = :black, linewidth = 1)
        
        # Draw horizontal caps at min and max values
        cap_width = 0.05
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_min, y_min], color = :black, linewidth = 1)
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_max, y_max], color = :black, linewidth = 1)
    end
    
    ylims!(ax, 0, 6)

    # Add horizontal lines and labels for time references
    one_hour = log10(3600)  # 1 hour = 3600 seconds
    one_day = log10(24 * 3600)  # 1 day = 24 * 3600 seconds
    ten_days = log10(7 * 24 * 3600)  
    
    hlines!(ax, [one_hour], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [one_day], color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [ten_days], color = :black, linestyle = :dash, linewidth = 1)
    
    # Add ten equal divisions between each log scale (1.1×10^k, 1.2×10^k, etc.)
    for i in 0:5  # From 10^0 to 10^6
        for j in 1:9  # 9 divisions between each power of 10
            # Calculate log10(1.j × 10^i) = log10(1.j) + i
            y_pos = log10(j) + i
            hlines!(ax, [y_pos], color = :gray, linestyle = :dot, linewidth = 0.5, alpha = 0.5)
        end
    end
    
    text!(ax, 0.32, one_hour - 0.3, text = "1 hour", fontsize = 12, color = :black)
    text!(ax, 0.32, one_day - 0.3, text = "1 day", fontsize = 12, color = :black)
    text!(ax, 0.32, ten_days - 0.3, text = "1 week", fontsize = 12, color = :black)

    Legend(fig[1, :], [PolyElement(polycolor = runtime_colors[i]) for i in 1:3], ["BBTN", "DS", "SCIP"], orientation = :horizontal, nbanks = 1, labelsize = 15)

    xlims!(ax, 0.3, 3.7)  # Extended xlims to accommodate the text labels
    # hlines!(ax, [log10(max_time)], color = :black, linestyle = :dot)
    # text!(ax, 0.4, log10(max_time), text = L"Time limit ($72$h)", fontsize = 18)

    save("../figs/runtime.pdf", fig)
    # save("../figs/runtime.png", fig)
    fig
end