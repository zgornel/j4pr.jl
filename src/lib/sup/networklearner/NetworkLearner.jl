# Network learning
module NetworkLearner
	
	using LearnBase, MLDataPattern, LightGraphs, SimpleWeightedGraphs, Distances
	
	export AbstractNetworkLearner,
		NetworkLearnerOutOfGraph,
		NetworkLearnerInGraph,
		fit, 
		transform, transform!, 
		add_adjacency!
	
	abstract type AbstractNetworkLearner end
	
	include("adjacency.jl") 								# Adjacency-related structures 
	include("rlearners.jl")									# Relational learners
	include("cinference.jl")								# Collective inference algorithms		
	include("utils.jl")									# Small utility functions
	include("outlearning.jl")								# Out-of-graph learning
	include("inlearning.jl")								# In-graph learning

end


