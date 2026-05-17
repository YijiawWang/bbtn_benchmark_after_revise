include("../settings.jl")

begin
    fig = Figure(backgroundcolor = RGBf(1.0, 1.0, 1.0), size = (800, 500), fontsize = 20)

    ax = Axis(fig[1, 1],
        ylabel = L"t.c.\text{(Flops)}",
        xticks = (1:4, ["Spin Glass\nRRG", "Spin Glass\n3D Grid", "MIS\nRKSG", "MWIS\nRKSG"]),
        yticks = (0:5:35, [L"$10^0$", L"$10^5$", L"$10^{10}$", L"$10^{15}$",
                           L"$10^{20}$", L"$10^{25}$", L"$10^{30}$", L"$10^{35}$"]),
        xlabelsize = 26, ylabelsize = 26, xticklabelsize = 16, yticklabelsize = 22,
        xticksize = 8, yticksize = 8,
    )

    df_ground = CSV.read("../../data/main/complexity/ground_state_counting/tc_ground_counting.csv", DataFrame)

    total_tc_vals             = log10.(2 .^ df_ground.total_tc_mean)
    total_tc_slicing_vals     = log10.(2 .^ df_ground.total_tc_slicing_mean)
    total_tc_max_vals         = log10.(2 .^ df_ground.total_tc_max)
    total_tc_min_vals         = log10.(2 .^ df_ground.total_tc_min)
    total_tc_slicing_max_vals = log10.(2 .^ df_ground.total_tc_slicing_max)
    total_tc_slicing_min_vals = log10.(2 .^ df_ground.total_tc_slicing_min)

    cat = [1, 1, 2, 2, 3, 3, 4, 4]
    bar_grp = [1, 2, 1, 2, 1, 2, 1, 2]
    mean_times = Float64[]
    min_times  = Float64[]
    max_times  = Float64[]
    for i in 1:4
        push!(mean_times, total_tc_vals[i])
        push!(mean_times, total_tc_slicing_vals[i])
        push!(min_times,  total_tc_min_vals[i])
        push!(min_times,  total_tc_slicing_min_vals[i])
        push!(max_times,  total_tc_max_vals[i])
        push!(max_times,  total_tc_slicing_max_vals[i])
    end

    bar_colors = [method_colors["BBTN"], method_colors["TN_with_Slicing"]]

    barplot!(ax, cat, mean_times, dodge = bar_grp,
             color = bar_colors[bar_grp], strokecolor = :black, strokewidth = 1)

    dodge_width = 0.8
    bar_width = dodge_width / 2
    for i in 1:length(cat)
        x_pos = cat[i] + (bar_grp[i] - 1.5) * bar_width
        y_min = min_times[i]
        y_max = max_times[i]

        lines!(ax, [x_pos, x_pos], [y_min, y_max], color = :black, linewidth = 1)
        cap_width = 0.05
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_min, y_min], color = :black, linewidth = 1)
        lines!(ax, [x_pos - cap_width, x_pos + cap_width], [y_max, y_max], color = :black, linewidth = 1)
    end

    ylims!(ax, 0, 35)

    hlines!(ax, [tc_min - log10(2)],            color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [tc_month - log10(2)],          color = :black, linestyle = :dash, linewidth = 1)
    hlines!(ax, [tc_1000000_years - log10(2)],  color = :black, linestyle = :dash, linewidth = 1)

    text!(ax, 0.05, tc_min - log10(2),            text = L"$1$ min",       fontsize = 22, color = :black)
    text!(ax, 0.05, tc_month - log10(2),          text = L"$1$ month",     fontsize = 22, color = :black)
    text!(ax, 0.05, tc_1000000_years - log10(2),  text = L"$10^6$ years",  fontsize = 22, color = :black)

    xlims!(ax, 0, 5)

    legend_dict = Dict{String, Any}()
    legend_dict["BBTN"]            = PolyElement(polycolor = bar_colors[1])
    legend_dict["TN with Slicing"] = PolyElement(polycolor = bar_colors[2])
    labels_order = ["BBTN", "TN with Slicing"]
    legend_items = [legend_dict[l] for l in labels_order]
    Legend(fig[0, 1], legend_items, labels_order,
           orientation = :horizontal, labelsize = 20,
           nbanks = 1, tellwidth = false, halign = :center)

    save("../../figs/tc_counting_multi_types.pdf", fig)
    fig
end
