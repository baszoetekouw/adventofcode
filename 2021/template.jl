using DelimitedFiles

function read_ints(filename::String)::Array{Int}
	f = open(filename)
	data = readdlm(f, Int)
	return data
end

function do_calc(data::Array{Int})
	result = data
	return result
end

function main()
	filename = ARGS[1]
	data = read_ints(filename)
	result = do_calc(data)
	println("result: ", result)
end

main()
exit(0)
