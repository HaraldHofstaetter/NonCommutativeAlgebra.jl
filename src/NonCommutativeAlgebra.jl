module NonCommutativeAlgebra

import
Base: (*), /, ^, +, -

export Element, adjoint


Element{K} = Dict{Array{Int,1},K}


+{K}(f::Element{K}) = copy(f)

function -{K}(f::Element{K})
    Element{K}([(i,-c) for (i,c) in f])
end    


function +{K}(f::Element{K}, g::Element{K})
    r = copy(f)
    for (key, val) in g
        if haskey(r, key)
            r[key] += val
        else
            r[key] = val
        end    
        if r[key]==zero(K)
            delete!(r, key) 
        end     
    end
    r
end

function -{K}(f::Element{K}, g::Element{K})
    r = copy(f)
    for (key, val) in g
        if haskey(r, key)
            r[key] -= val
        else
            r[key] = -val
        end    
        if r[key]==zero(K)
            delete!(r, key) 
        end     
    end
    r
end

function *{K}(f::Element{K}, g::Element{K})
    r = Element{K}()
    for (s,c) in f
        for (t,d) in g
             r += Element{K}( vcat(s,t)=>c*d )
        end
    end                    
    r
end

function *{K1, K2}(f::Element{K1}, g::Element{K2})
    error("not implemented.")
end

function *{K}(f::Element{K}, a)
    a1 = convert(K, a)
    if a1==zero(K)
        return Element{K}()
    end
    r = copy(f)
    for key in keys(r)
        r[key]*=a1
    end
    r 
end

*{K}(a, f::Element{K}) = *(f, a)

function /{K}(f::Element{K}, a)
    a1 = convert(K, a)
    r = copy(f)
    for key in keys(r)
        r[key]/=a1
    end
    r 
end


function adjoint{K}(f::Element{K}, g::Element{K}, k::Integer=1)
    if k==0
        return g 
    elseif k==1
        return f*g-g*f
    else
        h = adjoint(f,g,k-1)
        return f*h-h*f
    end
end


function ^{K}(f::Element{K}, e::Integer)
    if e<0
        error("Nonnegative exponent expected")
    elseif e==0
        return Element{K}(Int[] => 1)
    elseif e==1
        return f
    else
        s = bits(e)
        s = reverse(s[first(search(s,"1")):end])
        r = Element{K}() 
        q = Element{K}() 
        isfirst = true
        for k=1:length(s)
            if k==1
                q = f
            else
                q = q*q
            end    
            if s[k:k]=="1"
                if isfirst
                    r = q
                    isfirst = false
                else
                    r = r*q
                end
            end    
        end        
        return r
    end    
end



end 
