using DelimitedFiles


parse_int = x -> parse(Int64, x)

function read_ints(filename::String)::Vector{Vector{Int8}}
	f = open(filename)
	data = [ parse_int.(split(line,"")) for line in readlines(f) ]
	#print("data: ")
	#display(data)

	return data
end

function bitvector_to_int(bits::Vector{Int8})::BigInt
	return parse(BigInt, join(bits), base=2)
end

function count_bits(data::Vector{Vector{Int8}})::Vector{Int64}
	counter = zeros(Int64, length(data[1]))
	for line in data
		counter += line
		#print("stap $num: ")
		#println(counter)
	end
	return counter
end

function do_calc_1(data::Vector{Vector{Int8}})::BigInt
	num = size(data,1)
	counter = count_bits(data)

	γ = zeros(Int8, length(counter))
	ε = zeros(Int8, length(counter))
	#println("step 0 γ=$γ ε=$ε")
	for i in 1:length(counter)
		if 2*counter[i]>num
			γ[i] = 1
		else
			ε[i] = 1
		end
		#println("step $i γ=$γ ε=$ε")
	end

	γ_tot = bitvector_to_int(γ)
	ε_tot = bitvector_to_int(ε)

	println("γ = $γ_tot = $γ")
	println("ε = $ε_tot = $ε")

	result = γ_tot * ε_tot
	return result
end

function count_bits(data::Set{Vector{Int8}}, bit::Int)::Int64
	count = 0
	for d in data
		count += d[bit]
	end
	return count
end

function do_calc_2a(data::Vector{Vector{Int8}})::BigInt
	num = size(data,1)
	num_bits = size(data[1],1)
	counter = count_bits(data)

	data_oxygen = Set(data)
	data_co2 = Set(data)

	for bit in 1:num_bits
		oxygen_num_ones = count_bits(data_oxygen, bit)
		oxygen_bit = (2*oxygen_num_ones >= length(data_oxygen))
		for word in data_oxygen
			if word[bit]!=oxygen_bit
				delete!(data_oxygen, word)
			end
		end
		if length(data_oxygen)==1
			break
		end
	end
	if length(data_oxygen)!=1
		println("error: found ", length(data_oxygen), " words instead of 1")
		exit(1)
	end

	oxygen_word = first(data_oxygen)
	oxygen = bitvector_to_int(oxygen_word)
	println("found word $oxygen_word = $oxygen")

	return oxygen
end

function do_calc_2b(data::Vector{Vector{Int8}})::BigInt
	num = size(data,1)
	num_bits = size(data[1],1)
	counter = count_bits(data)

	data_co2 = Set(data)
	data_co2 = Set(data)

	for bit in 1:num_bits
		co2_num_ones = count_bits(data_co2, bit)
		co2_bit = (2*co2_num_ones < length(data_co2))
		for word in data_co2
			if word[bit]!=co2_bit
				delete!(data_co2, word)
			end
		end
		if length(data_co2)==1
			break
		end
	end
	if length(data_co2)!=1
		println("error: found ", length(data_co2), " words instead of 1")
		exit(1)
	end

	co2_word = first(data_co2)
	co2 = bitvector_to_int(co2_word)
	println("found word $co2_word = $co2")

	return co2
end

function main()
	filename = length(ARGS)>=1 ? ARGS[1] : "example_1"
	data = read_ints(filename)
	result1 = do_calc_1(data)
	println("result 1: ", result1)
	result2a = do_calc_2a(data)
	println("Found O2 = $result2a")
	result2b = do_calc_2b(data)
	println("Found CO2 = $result2b")
	println("Result is ", result2a*result2b)
end

main()
exit(0)
