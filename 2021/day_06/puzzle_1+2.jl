using DelimitedFiles
using Printf

function display(x)
	Base.Multimedia.display(x)
	println()
end

function Base.show(io::IO, mime::MIME"text/plain", v::Vector{T}) where {T}
	@printf("%d-element Vector{%s}: ", length(v), eltype(v))
	println('[', join(v,','), ']')

end

function Base.convert(::Type{CartesianIndex}, v::Vector{Int64})
	CartesianIndex(v...)
end


function read_file(filename::String)::Vector{Int}
	f = open(filename)
	str = readline(f)
	vec = readdlm(IOBuffer(str), ',', Int, )[1,:]
	display(vec)
	return vec
end

function plantvoort(vissen::Vector{Int})
	vissen0 = vissen[1]
	vissen[1:8] = vissen[2:9]
	vissen[7] += vissen0
	vissen[9] = vissen0

	return vissen
end

function do_calc(data::Vector{Int})
	# vector met aantal vissen per dag
	# dus vissen[1] is het aantal vissen dat zich vandaag voorplant
	vissen = zeros(Int,9)
	for vis in data
		vissen[vis+1] += 1
	end

	@printf("na %3d dagen: %s\n", 0, vissen)
	for dag in 1:256
		plantvoort(vissen)
		@printf("na %3d dagen: %4d vissen: %s\n", dag, sum(vissen), vissen)
	end

	return []
end

function main()
	filename = ARGS[1]
	data = read_file(filename)
	result = do_calc(data)
	println("result: ", result)
end

main()
exit(0)
