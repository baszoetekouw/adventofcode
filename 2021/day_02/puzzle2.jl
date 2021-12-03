import Pkg
Pkg.add("Formatting")

using Formatting: printfmt
using DelimitedFiles

function read_ints(filename::String)::Array{Any}
	f = open(filename)
	data = readdlm(f, Any)
	return data
end

function do_calc(data::Array{Any})
	depth = pos = aim = 0
	for i in 1:size(data)[1]
		cmd = data[i,1]
		num = data[i,2]
		if cmd=="up"
			aim -= num
		elseif cmd=="down"
			aim += num
		elseif cmd=="forward"
			pos += num
			depth += num * aim
		end
		printfmt("cmd={:8s} num={:2d}   pos={:4d} depth={:3d} aim={:+3d}\n", data[i,1], data[i,2], pos, depth, aim)
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
