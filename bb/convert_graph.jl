using Graphs, DelimitedFiles

function covert_graph(n)

    dir = @__DIR__
    filename = joinpath(dir, "../graphs/random_ksg/ksg_n$(n).dot")

    @info "reading graphs $filename"
    graphs = loadgraphs(filename)
    @info "reading done"

    for i in 1:10
        g = graphs["$i"]
        target_filename = joinpath(dir, "edges", "ksg_n$(n)_$(i).txt")
        file = open(target_filename, "w")
        println(file, "# FromNodeId	ToNodeId")
        for e in edges(g)
            println(file, e.src - 1, " ", e.dst - 1)
        end
        close(file)
    end
end

function covert_graph_additional(n)

    dir = @__DIR__
    filename = joinpath(dir, "../graphs/random_ksg/additional_ksg_n$(n).dot")

    @info "reading graphs $filename"
    graphs = loadgraphs(filename)
    @info "reading done"

    for i in 1:50
        g = graphs["$i"]
        target_filename = joinpath(dir, "edges", "additional_ksg_n$(n)_$(i).txt")
        file = open(target_filename, "w")
        println(file, "# FromNodeId	ToNodeId")
        for e in edges(g)
            println(file, e.src - 1, " ", e.dst - 1)
        end
        close(file)
    end
end

function main()
    dir = @__DIR__
    !isdir(joinpath(dir, "edges")) && mkdir(joinpath(dir, "edges"))
    for n in [30, 35, 40, 45, 50]
        # covert_graph(n)
        covert_graph_additional(n)
    end
end

main()