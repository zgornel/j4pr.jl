###########################
# FunctionCell Interface  #	
###########################
"""
	scaler!([f,] opts)

Returns a cell that scales data piped to it according to the scaling options specified 
in `opts`. If the dataset is labeled, an additional function `f` can be specified to 
obtain the labels calling `LearnBase.targets(f,data)`. The argument `opts` can be a 
string specifying the scaling method or a `Dict(idx=>method)` if different methods 
are to be used for different variables. In this case, 

* `idx` can be an `Int`, `Vector{Int}` or `UnitRange` and specifies the variable indices
* `method` is a string that specifies the method. Available methods: `"mean"`, `"variance"`,
`"domain"`,`"c-mean"`, `"c-variance"` and `"2-sigma"`. Unrecognized options will be ignored. 

# Examples
```
julia> a=[1.0 0 0; 0 1.0 1.0];

julia> w = a |> scaler!("mean")
Data scaler! (mean), 2 -> 2, trained

julia> a |> w
2×3 Array{Float64,2}:
 0.666667  -0.333333  -0.333333
 -0.666667   0.333333   0.333333

julia> a=datacell([1.0 -1 0 0 0; 5 0 1.0 1.0 1.0; 1 2 3 4 5], [0, 0, 1, 1, 1]);

julia> +a
3×5 Array{Float64,2}:
 1.0  -1.0  0.0  0.0  0.0
 5.0   0.0  1.0  1.0  1.0
 1.0   2.0  3.0  4.0  5.0

julia> w=a |> scaler!(Dict(1=>"mean", 2=>"2-sigma"))
Data scaler! (mixed), 3 -> 3, trained

julia> a|>w; +a
3×5 Array{Float64,2}:
 1.0       -1.0       0.0       0.0       0.0     
 0.880132   0.321115  0.432918  0.432918  0.432918
 1.0        2.0       3.0       4.0       5.0     
```
"""
scaler!(f::Function, opts::T where T<:AbstractString) = FunctionCell(scaler!, (f,opts), ModelProperties(), "Data scaler! ("*opts*")")
scaler!(opts::T where T<:AbstractString) = scaler!(identity, opts) 

scaler!(f::Function, opts::T where T<:Dict) = FunctionCell(scaler!, (f, opts), ModelProperties(), "Data scaler! (mixed)")
scaler!(opts::T where T<:Dict) = scaler!(identity, opts)



############################
# DataCell/Array Interface #	
############################
"""
	scaler!(data, [f,] opts)

Scales `data` according to the scaling options specified in `opts`. 
If the dataset is labeled, an additional function `f` can be specified to 
obtain the labels calling `LearnBase.targets(data,f)`. """
# Training
scaler!(x::T where T<:CellData, opts) = scaler!(strip(x), identity, opts)
scaler!(x::T where T<:CellData, f::Function, opts) = scaler!(strip(x), f, opts)

scaler!(x::Tuple{T,S} where T<:AbstractArray where S<:AbstractArray, opts) = scaler!(x[1], x[2], identity, opts)
scaler!(x::Tuple{T,S} where T<:AbstractArray where S<:AbstractArray, f::Function, opts) = scaler!(x[1], x[2], f, opts)

scaler!(x::T where T<:AbstractArray, opts) = scaler!(x, Void[], identity, opts)
scaler!(x::T where T<:AbstractArray, f::Function, opts) = scaler!(x, Void[], f, opts)

scaler!(x::T where T<:AbstractArray, y::S where S<: AbstractArray, f::Function, opts) = begin
	
	# Get dictionary or construct a proper one from original;
	# Inputs: scaling option and total number of variables 
	_sdict_(x::T, m) where T<:String = Dict(i=>x for i in 1:m) 
	_sdict_(x::T, m) where T<:Dict = begin
		out = Dict{Int, String}()
		for (k,v) in x 
			if(k isa Int)
				@assert (k>=1)&&(k<= m) "[scaler!] Index $(k) for a variable out of bounds."
				push!(out, k=>v) 
			elseif (k isa UnitRange{Int} || k isa Vector{Int})
				@assert (minimum(k)>=1)&&(maximum(k)<= m) "[scaler!] Index $(k) for a variable out of bounds."
				push!(out, (ki=>v for ki in k)...) 
			else
				error("[scaler!] Unsupported variable index syntax.")
			end
		end
		return out
	end
	dopts = _sdict_(opts, nvars(x))
	
	# Determine scaler name (for information only)
	_scalername_(x) = begin 
		if isempty(x) return "Data scaler! ()"
		elseif (length(unique(x)) == 1) return "Data scaler! ("*collect(x)[1]*")"
		else return "Data scaler! (mixed)"
		end
	end
	scalername = _scalername_(values(dopts))
	
	# Get targets (nothing for unlabeled data cells and arrays)
	_targets_(f,y) = targets(f,y)
	_targets_(f,::AbstractArray{Void}) = nothing
	labels = _targets_(f,y)
	@assert !any(isna.(labels))		
	@assert !any(isnan.(labels))		
	@assert (labels isa Vector)||(labels isa Void) "[scaler!] Labels need to be a Vector or ::Void." 

	# Get priors
	priors = countmapn(labels)	

	# Create model properties
	modelprops = ModelProperties(nvars(x), nvars(x), nothing, 
			Dict("priors" => priors,						# Priors
			"variables_to_process" => collect(keys(dopts))				# Which columns to process (can be any sort of vector)
			)	
	)
	
	# Define processing functions (x - data vector, t - targets array, p - class priors), returns Tuple(mean, variance, clip) 
	# - Scalers not based on class information have also an overloaded version for labeled datasets which reverts to one where 
	#   no labels are present
	# - Class based scalers expect targets to be a vector (not matrix) or default to non-class versions if possible
	_mean_(x::T, ::Void) where T<:AbstractVector = (1.0, -mean(x), false)
	_mean_(x::T, t::S) where T<:AbstractVector where S<:AbstractArray = _mean_(x,nothing)

	_variance_(x::T, ::Void) where T<:AbstractVector = (1/std(x), -mean(x)/std(x), false)
	_variance_(x::T, t::S) where T<:AbstractVector where S<:AbstractArray = _variance_(x,nothing)

	_domain_(x::T, ::Void) where T<:AbstractVector = begin 
		maxv = maximum(x)
		minv = minimum(x)
		return (1/(maxv-minv+eps()), -minv/(maxv-minv+eps()), false)
	end
	_domain_(x::T, t::S) where T<:AbstractVector where S<:AbstractArray = _domain_(x,nothing)

	_cmean_(x::T, ::Void, p) where T<:AbstractVector = _mean_(x,nothing)
	_cmean_(x::T, t::S, p) where T<:AbstractVector where S<:AbstractVector = begin 
		offset = 0.0
		@inbounds for c in keys(p)
			d = x[isequal.(t,c)]
			offset += p[c] * mean(d)
		end
		return (1.0, -offset, false)
	end

	_cvariance_(x::T, ::Void, p) where T<:AbstractVector = _variance_(x,nothing)
	_cvariance_(x::T, t::S, p) where T<:AbstractVector where S<:AbstractArray = begin 
		offset = 0.0
		scale = 0.0
		@inbounds for c in keys(p)
			d = x[isequal.(t,c)]
			offset += p[c] * mean(d)
			scale += p[c] * var(d)
		end
		return (1.0/scale, -offset/scale, false)
	end

	_2sigma_(x::T, ::Void, p) where T<:AbstractVector = error("[scaler!] 2-sigma scaling needs labels")
	_2sigma_(x::T, t::S, p) where T<:AbstractVector where S<:AbstractVector = begin 
		offset = 0.0
		scale = 0.0
		@inbounds for c in keys(p)
			d = x[isequal.(t,c)]
			offset += p[c] * mean(d)
			scale += p[c] * var(d)
		end
		scale = 4*sqrt(scale)
		offset = offset - 0.5*scale
		return (1.0/scale, -offset/scale, true)
	end
	
	
	# Create dictionary for each processed variable Dict(column=>(scale, offset, labels))
	modeldata = Dict{Int, Tuple{eltype(1.0),eltype(1.0), Bool}}()
	for (idx, v) in dopts
		variable = _variable_(x,idx)
		if v=="mean" 
			s = _mean_(variable, labels) 
		elseif v=="variance" 
			s = _variance_(variable, labels)
		elseif v=="domain" 
			s = _domain_(variable, labels)
		elseif v=="c-mean" 
			s = _cmean_(variable, labels, priors) 
		elseif v=="c-variance" 
			s = _cvariance_(variable, labels, priors)
		elseif v=="2-sigma" 
			s = _2sigma_(variable, labels, priors)
		else # do not scale if option not recognized
			warn("[scaler!] Option $(v) not recognized, will not process variable $(idx)") 
			s = (1.0, 0.0, false)
		end
		push!(modeldata, idx => s ) 
	end
	
	# Return trained cell
	return FunctionCell(scaler!, Model(modeldata, modelprops), scalername)
end



# Execution
scaler!(x::T where T<:CellData, model::Model) = datacell(scaler!(strip(x), model))

scaler!(x::Tuple{T,S} where T<:AbstractArray where S<:AbstractArray, model::Model) = (scaler!(x[1], model),x[2])

scaler!(x::T where T<:AbstractArray, model::Model) = begin
	
	@inbounds for (idx, (scale, offset, clip)) in model.data
		variable = _variable_(x,idx) 	# Assign temp variable
		
		# Process variable vector
		variable .*= scale
		variable .+= offset
		ifelse(clip, clamp!(variable,0.0,1.0), nothing)
	end
	return x
end
