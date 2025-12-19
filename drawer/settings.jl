using CSV, DataFrames
using CairoMakie, LaTeXStrings
using Statistics
using LsqFit

# colors = [:red, :blue, :green, :orange, :purple, :brown, :pink, :gray, :black]
colors = ["#4477AA", "#E36D44", "#228833", "#CCBB44", "#66CCEE", "#AA3377"]
markersize = 12
linestyle = [:solid, :dash, :dot, :dashdot, :dashdotdot]
linewidth = 2
markerstyle = [:rect, :circle, :diamond, :utriangle, :dtriangle, :rtriangle, :ltriangle]
strokecolor = :black
strokewidth = 0.5

function geometric_mean(x)
    return prod(Float64.(x))^(1/length(x))
end

function max_n(x, n)
    # get the n largest elements in x
    xs = sort(x)
    return xs[end-n+1:end]
end
# t_30_tn =  12.2944445822*2
# tc_30_tn = 41.98505
# tc_tn_one_hour = 2^tc_30_tn / t_30_tn * 3600
tc_tn_one_hour = 3600 * (19.5 * 10^12)
tc_min = log10(tc_tn_one_hour/60)
tc_hour = log10(tc_tn_one_hour)
tc_day = log10(tc_tn_one_hour*24)
tc_month = log10(tc_tn_one_hour*24*30)
tc_year = log10(tc_tn_one_hour*24*30*12)
tc_100_years = log10(tc_tn_one_hour*24*30*12*100)
tc_10000_years = log10(tc_tn_one_hour*24*30*12*10000)
tc_1000000_years = log10(tc_tn_one_hour*24*30*12*1000000)
hstyle = :dot
hwidth = 1.5