using OMEinsum
using CSV, DataFrames

function extract_json_to_csv(input_folder::String, output_file::String)
    # 获取所有JSON文件
    json_files = filter(x -> endswith(x, ".json"), readdir(input_folder, join=true))
    
    @show length(json_files)

    tcs = zeros(Float64, length(json_files))
    
    # name of order is "eincode_id.json", extract the id
    # ids = [split(basename(json_files[i]), "_")[1] for i in 1:length(json_files)]

    Threads.@threads for i in 1:length(json_files)
        code = readjson(json_files[i])
        cc = contraction_complexity(code, uniformsize(code, 2))
        tcs[i] = cc.tc
        @show i, cc.tc
    end

    total_tc = log2(sum(2 .^ tcs))
    @show total_tc

    CSV.write(output_file, DataFrame(name = [1:length(json_files)...], tc = tcs))
end

extract_json_to_csv("/Euler/xzgao/n100/i_9", "temp/extract_slices.csv")