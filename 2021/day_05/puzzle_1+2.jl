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


struct Line
	start::CartesianIndex
	stop::CartesianIndex
end

function Base.length(l::Line)
	diff = l.stop-l.start
	return max(abs(diff[1]), abs(diff[2]))+1
end

function Base.iterate(l::Line, state::Union{Nothing,Tuple{Integer,Integer,CartesianIndex}})
	i = 0
	i_max = 0
	delta = CartesianIndex()

	if state===nothing
		diff = l.stop-l.start
		i_max = max(abs(diff[1]), abs(diff[2]))
		delta = CartesianIndex(diff[1]÷i_max, diff[2]÷i_max)
		i = 0
	else
		i, i_max, delta = state
		if i > i_max
			return nothing
		end
	end

	current = l.start + i*delta

	return (current, (i+1,i_max,delta))
end
Base.iterate(l::Line) = Base.iterate(l,nothing)


function Base.convert(::Type{CartesianIndex}, v::Vector{Int64})
	CartesianIndex(v...)
end

function Line(s::String)::Line
	coord = parse.(Int, split(s, r"->|,"))
	coord .+= 1
	Line([coord[2],coord[1]],[coord[4],coord[3]])
end

function is_recht(l::Line)::Bool
	l.start[1]==l.stop[1] || l.start[2]==l.stop[2]
end


function read_file(filename::String)::Vector{Line}
	f = open(filename)

	lines = Vector{Line}()
	while (str = readline(f)) != ""
		line = Line(str)
		push!(lines, line)
		display(line)
	end

	return lines
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

function do_calc1(lines::Vector{Line})
	max_x = 0
	max_y = 0
	for line in lines
		if line.start[1]>max_x; max_x = line.start[1]; end
		if line.stop[1] >max_x; max_x = line.stop[1];  end
		if line.start[2]>max_y; max_y = line.start[2]; end
		if line.stop[2] >max_y; max_y = line.stop[2];  end
	end

	field = zeros(Int, max_x, max_y)
	for line in lines
		if ! is_recht(line)
			continue
		end
		for p in line
			field[p] += 1
		end
	end

	matrixprint(field)

	gevaarlijk = count(x->(x>1), field)

	println("Result: $gevaarlijk gevaarlijke hokjes")

end


function do_calc2(lines::Vector{Line})
	max_x = 0
	max_y = 0
	for line in lines
		if line.start[1]>max_x; max_x = line.start[1]; end
		if line.stop[1] >max_x; max_x = line.stop[1];  end
		if line.start[2]>max_y; max_y = line.start[2]; end
		if line.stop[2] >max_y; max_y = line.stop[2];  end
	end

	field = zeros(Int, max_x, max_y)
	for line in lines
		for p in line
			field[p] += 1
		end
	end

	matrixprint(field)

	gevaarlijk = count(x->(x>1), field)

	println("Result: $gevaarlijk gevaarlijke hokjes")

end

function main()
	filename = ARGS[1]
	data = read_file(filename)
	do_calc1(data)
	do_calc2(data)
end

main()
exit(0)
