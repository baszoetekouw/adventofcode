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

function matrixprint(m::Matrix)
	if length(m)>10000
		@printf("Matrix %dx%d too large to display\n", size(m)...)
		return
	end
	for y in 1:size(m,1)
		for x in 1:size(m,2)
			if m[y,x]==0
				print(".")
			else
				print(m[y,x])
			end
		end
		print("\n")
	end
end

function read_file_simple(filename::String)::Array{Any}
	f = open(filename)
	data = readdlm(f, Any)
	return data
end

function read_file_complex(filename::String)::Tuple{Vector{Int},Vector{Matrix{Int}}}
	f = open(filename)

	str = readuntil(f, "\n\n")
	vec = readdlm(IOBuffer(str), ',', Int, )[1,:]

	matrices = Vector{Maxtrix{Int}}()
	while (str = lstrip(readuntil(f,"\n\n"))) != ""
		mat = readdlm(IOBuffer(str), Int)
		push!(matrices,mat)
	end
	display(matrices)

	return (vec,matrices)
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
