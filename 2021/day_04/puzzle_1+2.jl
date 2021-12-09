using DelimitedFiles
using Printf

#import Pkg; Pkg.add("Crayons")
using Crayons

function display(x)
	Base.Multimedia.display(x)
	println()
end

function Base.show(io::IO, mime::MIME"text/plain", v::Vector{T}) where {T}
	@printf("%d-element Vector{%s}: ", length(v), eltype(v))
	println('[', join(v,','), ']')

end

struct Bingokaart
	size::Int
	kaart::Matrix{Int}
	afgestreept::Set{CartesianIndex}
	afgestreept_row::Vector{Int}
	afgestreept_col::Vector{Int}
	mapping::Dict{Int,CartesianIndex}
end

function Bingokaart(m::Matrix{Int})
	if (n=size(m,1)) != size(m,2)
		error("Matrix is not square")
	end
	mapping = Dict{Int,CartesianIndex}()
	for i in CartesianIndices(m)
		mapping[ m[i] ] = i
	end
	Bingokaart(n,m,Set{CartesianIndex}(),zeros(Int,n),zeros(Int,n),mapping)
end

function bingo(kaart::Bingokaart)::Bool
	if kaart.size in kaart.afgestreept_row || kaart.size in kaart.afgestreept_col
		true
	else
		false
	end
end

function vink_af(kaart::Bingokaart, getal::Int)::Bool
	if getal ∈ keys(kaart.mapping)
		pos = kaart.mapping[getal]
		if pos ∉ kaart.afgestreept
			push!(kaart.afgestreept, pos)
			kaart.afgestreept_row[pos[1]] += 1
			kaart.afgestreept_col[pos[2]] += 1
		end
	end
	return bingo(kaart)
end

function Base.CartesianIndices(kaart::Bingokaart)
	Base.CartesianIndices(kaart.kaart)
end

function bingo_score(kaart::Bingokaart)::Int
	onafgestreept = setdiff(CartesianIndices(kaart), kaart.afgestreept)
	score = sum(kaart.kaart[onafgestreept])
	score
end

function Base.show(io::IO, mime::MIME"text/plain", bk::Bingokaart)
	@printf("%dx%d Bingokaart: (%s)\n", bk.size, bk.size, bingo(bk) ? "BINGO!" : "no bingo")
	mat = bk.kaart
	for y in 1:size(mat,2)
		for x in 1:size(mat,1)
			kleurtje = CartesianIndex(x,y) ∈ bk.afgestreept
			kl1 = kleurtje ? Crayon(foreground=:red)  : ""
			kl2 = kleurtje ? Crayon(reset=true) : ""
			@printf( "%s%4d%s ", kl1, mat[x,y], kl2)
		end
		println()
	end
end


function read_file(filename::String)::Tuple{Vector{Int},Vector{Bingokaart}}
	f = open(filename)

	str = readuntil(f, "\n\n")
	ballen = readdlm(IOBuffer(str), ',', Int, )[1,:]

	kaarten = Vector{Bingokaart}()
	while (str = lstrip(readuntil(f,"\n\n"))) != ""
		mat = readdlm(IOBuffer(str), Int)
		kaart = Bingokaart(mat)
		push!(kaarten, kaart)
	end
	display(ballen)

	return (ballen,kaarten)
end


function calc1(ballen::Vector{Int}, kaarten::Vector{Bingokaart})
	bingos = Vector{Bool}()
	lastball = 0
	for bal in ballen
		lastball=bal
		print("Getrokken bal $bal...")
		bingos = vink_af.(kaarten,bal)
		if any(bingos)
			print("BINGO!\n")
			break
		else
			print("geen bingo\n")
		end
	end

	println()
	for i in findall(bingos)
		score = bingo_score(kaarten[i])
		result = score*lastball
		println("Bingo in kaart $i, score=$score, result=$result")
		display(kaarten[i])
		println()
	end
	println()
end

function calc2(ballen::Vector{Int}, kaarten::Vector{Bingokaart})
	bingos = Vector{Bool}()
	lastball = 0
	lastbingos = Vector{Int}()
	for bal in ballen
		lastball=bal
		print("Getrokken bal $bal...")
		bingos = vink_af.(kaarten,bal)
		if count(.!bingos)==0
			print("Iedereen heeft bingo!\n")
			break
		else
			num = count(.!bingos)
			print("Nog $num kaarten over\n")
		end
		lastbingos = bingos
	end

	println()

	# laatste kaart die bingo heeft
	notbingo = findfirst(.!lastbingos)
	score = bingo_score(kaarten[notbingo])
	result = score*lastball
	println("Laatste bingo in kaart $notbingo, score=$score, result=$result")
	display(kaarten[notbingo])

	println()
end

function main1()
	filename = ARGS[1]
	ballen, kaarten = read_file(filename)

	println("======== Opgave 1 ================================")
	calc1(ballen, copy(kaarten))
	println("======== Opgave 2 ================================")
	calc2(ballen, copy(kaarten))
end

main1()
exit(0)
