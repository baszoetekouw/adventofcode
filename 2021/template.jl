using DelimitedFiles

function display(x)
	Base.Multimedia.display(x)
	println()
end

function Base.show(io::IO, mime::MIME"text/plain", v::Vector{T}) where {T}
	@printf("%d-element Vector{%s}: ", length(v), eltype(v))
	println('[', join(v,','), ']')

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
