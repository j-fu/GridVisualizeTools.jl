struct LinearSimplex{D,N,Tv}
    points::SVector{N,Point{D,Tv}}
    values::SVector{N,Tv}
end

values(s::LinearSimplex)=s.values
points(s::LinearSimplex)=s.points


function LinearSimplex(::Type{Val{D}},points::Union{Vector,Tuple}, values::Union{Vector,Tuple}) where {D}
    spoints=SVector{D+1,Point{D,Float32}}(points...)
    svalues=SVector{D+1,Float32}(values...)
    LinearSimplex(spoints,svalues)
end

function LinearSimplex(::Type{Val{1}},points::AbstractMatrix, values::AbstractVector)
    @views spoints=SVector{2,Point{1,Float32}}(points[:,1],points[:,2])
    svalues=SVector{2,Float32}(values[1],values[2])
    LinearSimplex(spoints,svalues)
end

function LinearSimplex(::Type{Val{2}},points::AbstractMatrix, values::AbstractVector)
    @views spoints=SVector{3,Point{2,Float32}}(points[:,1],points[:,2],points[:,3])
    svalues=SVector{3,Float32}(values[1],values[2],values[3])
    LinearSimplex(spoints,svalues)
end

function LinearSimplex(::Type{Val{3}},points::AbstractMatrix, values::AbstractVector)
    @views spoints=SVector{4,Point{3,Float32}}(points[:,1],points[:,2],points[:,3],points[:,4])
    svalues=SVector{4,Float32}(values[1],values[2],values[3],values[4])
    LinearSimplex(spoints,svalues)
end


function LinearSimplex(::Type{Val{1}},points::AbstractMatrix, values::AbstractVector,coordscale)
    @views spoints=SVector{2,Point{1,Float32}}(points[:,1]*coordscale,points[:,2]*coordscale)
    svalues=SVector{2,Float32}(values[1],values[2])
    LinearSimplex(spoints,svalues)
end

function LinearSimplex(::Type{Val{2}},points::AbstractMatrix, values::AbstractVector,coordscale)
    @views spoints=SVector{3,Point{2,Float32}}(points[:,1]*coordscale,points[:,2]*coordscale,points[:,3]*coordscale)
    svalues=SVector{3,Float32}(values[1],values[2],values[3])
    LinearSimplex(spoints,svalues)
end

function LinearSimplex(::Type{Val{3}},points::AbstractMatrix, values::AbstractVector,coordscale)
    @views spoints=SVector{4,Point{3,Float32}}(points[:,1]*coordscale,points[:,2]*coordscale,points[:,3]*coordscale,points[:,4]*coordscale)
    svalues=SVector{4,Float32}(values[1],values[2],values[3],values[4])
    LinearSimplex(spoints,svalues)
end

LinearEdge(points,values)=LinearSimplex(Val{1},points,values)
LinearTriangle(points,values)=LinearSimplex(Val{2},points,values)
LinearTetrahedron(points,values)=LinearSimplex(Val{3},points,values)


"""
    abstract type LinearSimplexIterator{D}

Iterator over D-dimensional linear simplices. 

Any subtype `TSub` should comply with the [iteration interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration)
and implement
```julia
     Base.iterate(vs::TSub{D}, state):: (LinearSimplex{D}, state) where D
```
The optional methods (in particular, size, length) are not needed.
"""
abstract type LinearSimplexIterator{D} end

"""
    testloop(iterators::AbstractVector{T}) where T<:LinearSimplexIterator

Sum up all values passed via the iterator. Designed for testing iterators.

Useful for:
- Consistency test - e.g. when passing constant ones, the sum can be calculated by 
  other means and compared to the return value of testloop
- Allocation test. `testloop` itself does allocate only a few (<1000) bytes in
  very few (<10) allocations. So any allocations beyond this from a
  call to `testloop` hint at possibilities to improve an iterator implementation.
"""
function testloop(iterators::AbstractVector{T}) where T<:LinearSimplexIterator
    threads=map(iterators) do iterator 
	begin
	    local x=0.0
            for vt in iterator
            	x+=sum(vt.values)
            end
	    x
	end	 
    end
    sum(fetch.(threads))
end
