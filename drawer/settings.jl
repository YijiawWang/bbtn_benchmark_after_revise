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