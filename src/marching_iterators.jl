function pushintersection!(intersection_points,triangle::LinearSimplex{2},levels)
    f = values(triangle)
    coord=points(triangle)
    
    (n1, n2, n3) = (1, 2, 3)
    
    f[1] <= f[2] ? (n1, n2) = (1, 2) : (n1, n2) = (2, 1)
    f[n2] <= f[3] ? n3 = 3 : (n2, n3) = (3, n2)
    f[n1] > f[n2] ? (n1, n2) = (n2, n1) : nothing
    
    dx31 = coord[n3][1] - coord[n1][1]
    dx21 = coord[n2][1] - coord[n1][1]
    dx32 = coord[n3][1] - coord[n2][1]
    
    dy31 = coord[n3][2] - coord[n1][2]
    dy21 = coord[n2][2] - coord[n1][2]
    dy32 = coord[n3][2] - coord[n2][2]
    
    df31 = f[n3] != f[n1] ? 1 / (f[n3] - f[n1]) : 0.0
    df21 = f[n2] != f[n1] ? 1 / (f[n2] - f[n1]) : 0.0
    df32 = f[n3] != f[n2] ? 1 / (f[n3] - f[n2]) : 0.0
    
    for level ∈ levels
        if (f[n1] <= level) && (level < f[n3])
            α = (level - f[n1]) * df31
            x1 = coord[n1][1] + α * dx31
            y1 = coord[n1][2] + α * dy31
            
            if (level < f[n2])
                α = (level - f[n1]) * df21
                x2 = coord[n1][1] + α * dx21
                y2 = coord[n1][2] + α * dy21
            else
                α = (level - f[n2]) * df32
                x2 = coord[n2][1] + α * dx32
                y2 = coord[n2][2] + α * dy32
            end
            push!(intersection_points, Point{2,Float32}(x1, y1))
            push!(intersection_points, Point{2,Float32}(x2, y2))
        end
    end
end

function intersections(triangles::T,levels) where T<:LinearSimplexIterator{2}
    local intersection_points = Vector{Point{2,Float32}}(undef, 0)
    for triangle in triangles
        pushintersection!(intersection_points,triangle,levels)
    end
    intersection_points
end

function marching_triangles(triangle_iterators::Vector{T},levels) where T<:LinearSimplexIterator{2}
    if Threads.nthreads()==1
        map(triangle_iterators) do triangles
            intersections(triangles,levels)
        end
    else
        threads=map(triangle_iterators) do triangles
            Threads.@spawn intersections(triangles,levels)
        end
        fetch.(threads)
    end
end
