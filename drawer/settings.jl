using CSV, DataFrames
using CairoMakie, LaTeXStrings
using Statistics
using LsqFit

colors = [:red, :blue, :green, :orange, :purple, :brown, :pink, :gray, :black]
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

tc_min = log2(60 * (18.3 * 10^12)) - 1
tc_hour = log2(3600 * (18.3 * 10^12)) - 1
tc_day = log2(24 * 3600 * (18.3 * 10^12)) - 1
tc_week = log2(7 * 24 * 3600 * (18.3 * 10^12)) - 1
tc_month = log2(30 * 24 * 3600 * (18.3 * 10^12)) - 1
tc_year = log2(365 * 24 * 3600 * (18.3 * 10^12)) - 1
tc_100_years = log2(100 * 365 * 24 * 3600 * (18.3 * 10^12)) - 1

hstyle = :dot
hwidth = 1.5