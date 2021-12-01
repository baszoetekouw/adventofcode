using DelimitedFiles

function read_ints(filename::String)::Array{Int}
	f = open(filename)
	data = readdlm(f, Int)
	return data
end

function do_calc1(data::Array{Int})::Int
	num_increase = 0
	for i = 2:length(data)
		if data[i]>data[i-1]
			num_increase += 1
		end
	end
	return num_increase
end

function do_calc2(data::Array{Int})::Int
	num_increase = 0
	for i = 4:length(data)
		if data[i]>data[i-3]
			num_increase += 1
		end
	end
	return num_increase
end

function main()
	filename = ARGS[1]
	data = read_ints(filename)
	result1 = do_calc1(data)
	result2 = do_calc2(data)
	println("result1: ", result1)
	println("result2: ", result2)
end

main()
exit(0)
