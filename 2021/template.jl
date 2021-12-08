using DelimitedFiles

function read_file(filename::String)::Array{Any}
	f = open(filename)
	data = readdlm(f, Any)
	return data
end

function do_calc(data::Array{Any})
	result = data
	return result
end

function main()
	filename = ARGS[1]
	data = read_file(filename)
	result = do_calc(data)
	println("result: ", result)
end

main()
exit(0)
