using DelimitedFiles

function read_ints(filename::String)::Array{Any}
	f = open(filename)
	data = readdlm(f, Any)
	return data
end

function do_calc(data::Array{Any})
	depth = pos = 0
	for i in 1:size(data)[1]
		cmd = data[i,1]
		num = data[i,2]
		if cmd=="up"
			depth -= num
		elseif cmd=="down"
			depth += num
		elseif cmd=="forward"
			pos += num
		end
	end
	return [pos, depth]
end

function main()
	filename = ARGS[1]
	data = read_ints(filename)
	result = do_calc(data)
	println("position: ", result)
	println("answer: ", prod(result))
end

main()
exit(0)
