##############################################################################################################################
#															     #
# J4PR - a small library and package wrapper written in Julia by Cornel Cofaru at 0x0α Research                              #
# 															     #
##############################################################################################################################
VERSION >= v"0.6.0" && __precompile__(true)

"""
**J4PR**

A small library and package wrapper written in Julia for A.I. hacking. 
It relies on various packages from the Julia ecosystem and a quite simple 
constructs to provide a consistent way of solving problems. 
Documentation for the main types and functions is provided. 
Digging into the code will yield more low-level documentation
in the form of comments :) . 

To begin the documentation process regarding the library, type 
`?DataCell`, `?FunctionCell`, `?PipeCell` and `?datacell`. 
Also, start exploring **src/j4pr.jl** as well as the included files. 
The code is commented as much as possible and should at least partially 
make up for the lack in documentation. 

For bugs, remarks and other related issues, e-mail at **j4pr@oxoaresearch.com**.
Please note that support is not oficially available however any feedback is welcomed. 
"""
module j4pr

    	##############################################################################################################################
    	# Dependencies														     #
    	##############################################################################################################################
	
	# Imports section
	import Base: Test, convert, promote_rule, show, +, -, *, |>, ~, vcat, hcat, getindex, setindex!, size, endof, ndims, 
		     isnan, deleteat!, values, start, next, done, length, eltype, strip, interrupt
	import StatsBase: sample
	import MLDataPattern: nobs, getobs, datasubset, targets, gettargets 
	import UnicodePlots, LossFunctions, Distances, MultivariateStats, Clustering, DecisionTree, NetworkLearning, MLKernels

	# Using section
	using DataStructures: SortedDict
	using StatsBase: countmap, fit, Histogram
	using Reexport, StaticArrays, DataArrays, Compat, LearnBase, MLLabelUtils, MLLabelUtils.LabelEncoding

	# If Julia > 0.7, skip some packages
	if v"0.6" <= VERSION < v"0.7-"
		import LIBSVM
		using RDatasets, Images, ImageInTerminal
	end


    	##############################################################################################################################
    	# Global variables and logging configuration										     #
	##############################################################################################################################
	global const j4pr_version = "0.1.3-alpha"                      				# The current version of j4pr

	oinfoglobal = j4pr_version*Dates.format(Dates.now(), " dd-mm-YYYY")			# Define information string
		

    	##############################################################################################################################
    	# Export														     #
    	##############################################################################################################################
	@reexport using MLDataPattern
	
	# Some packages do not work for Julia > 0.6
	if v"0.6" <= VERSION < v"0.7-"
    		export 
		rdataset,									# R datasets
		im2targets, targets2im,								# From Images.jl Arrays to DataCells and back	
		libsvm,										# LIBSVM classifier/regressor 
		kNNClassifier, knn, knnr,							# k-nearest neighbours classifier and regressor
		ROC, findop, changeop!, simpleop,						# Operating point optimization
		rocplot
	end

	export
		# [core]
		@async_cell, @remote_cell,							# Macros
	   	AbstractCell, DataCell, FunctionCell, PipeCell,					# The basic types and constructors 
		Model, ModelProperties,								# Model related types	
	   	DataGenerator,									# Data generator submodule
		functioncell, datacell,                                                         # Functions to create cells 
	   	getx, getx!, gety, gety!, getf, getf!,                               		# Functions the get various cell fields
	   	nvars, size, start, next, done, eltype, length, ndims, endof,			# Various useful functions for data cells	
	   	classsizes, nclasssizes, classnames, countmapn,
		nclass, deleteat!, deleteat, idx, 
		varsubset, labelencn,								# Lazy subset of variables 
	   	strip, 										# Return tuple from data cell
	   	pipestack, pipeparallel, pipeserial,                                          	# Create pipes	   
	   	flatten, mat, 		                                                       	# Flatten a pipe made out of data
	   	addlabels, unlabel, labelize,							# Label-related functionality
	   	interrupt,
		
		# [lib]	
		countapp, countapp!, countappw, countappw!, 					# Counting utils 
	  	pintgen,									# Generate numbers based on priors	
		gini, misclassification,							# Purity utility functions
		linearsplit, densitysplit,							# Split vectors according to different criteria	
		confusionmatrix,								# Confusion matrix

		# [lib/data]
		DataGenerator, 									# Small sub-module that generates some datasets 
		cslice,										# Class slicing
	   	sample,										# Data sampling (sub/super sampling)
	   	scaler!,									# Data scaling
	   	filterg,									# Data processing (for missing values)	
	   	filterdomain!,									# Data domain filtering
	   	ohenc, ohenc_integer, ohenc_binary,						# One hot encoder
	   	lineplot, scatterplot, densityplot1d, 						# Plots
		densityplot2d, 

		# [lib/ext]
		### fa, far,									# Factor Analysis and reconstruction
		### kpca, kpcar,								# Kernel-PCA and reconstruction
		dist,										# Distances
		whiten,										# Data Whitening
		pca, pcar,									# PCA and reconstruction
		ppca, ppcar,									# Probabilistic PCA and reconstruction
		ica,										# ICA
		mds,										# MDS
		lda, ldasub,									# Multiclass LDA, Subspace LDA
		lr,										# Linear regression (Linear+Ridge)
		kmeans, kmeans!,								# K-means clustering 
		kmedoids, kmedoids!,								# K-medoids clustering 
		affinityprop,									# Affinity propagation clustering
		dbscan,										# DBSCAN clustering  
		tree, randomforest,								# Decision tree, random forest classifiers
		treer, randomforestr,								# Decisiontree, random forest regression
		aboostump,									# Adaptively boosted stump classifier
		mlkernel, 									# Machine Learning kernels from MLKernels.jl	
		
		# [lib/sup]
		loss,										# Calculate losses based on MLLabelUtils.jl and LossFunctions.jl
		LinDiscClassifier, lindisc,							# Linear discriminant classifier
		QuadDiscClassifier, quaddisc,							# Quadratic discriminant classifier
		ParzenClassifier, parzen,							# Parzen window density estimator/regressor/classifier
		ClassifierCombiner, votecombiner, wvotecombiner,				# Label combiners
		naivebayescombiner, bkscombiner,
		meancombiner, wmeancombiner, productcombiner,					# Continuous output combiners
		mediancombiner, dtcombiner,
		RandomSubspace, randomsubspace,							# Random sub-space ensemble
		AdaBoost, adaboost,								# AdaBoost ensemble
		DecisionStump, stump, stumpr,							# Decision stump classifier and regressor
		networklearner,									# Network learning

		# [lib/unsup]
		kernelize!, kernelize, kernel							# Construct kernels

    	##############################################################################################################################
    	# Include														     #
    	##############################################################################################################################
	
    	# [core]
    	include("core/abstractcell.jl")                                                         # AbstractCell related  
    	include("core/datacell.jl")                                                         	# DataCell related  
    	include("core/functioncell.jl")                                                         # FunctionCell related  
    	include("core/pipecell.jl")                                                         	# PipeCell related  
	include("core/calls.jl")                                                                # < call > methods
    	include("core/convert_promote.jl")                                                      # Conversion and Promotion rules in J4PR
    	include("core/printers.jl")                                                             # Text output (e.g. in REPL) for J4PR objects
    	include("core/coreutils.jl")                                                            # Utility functions (manipulate data and pipes)
    	include("core/macros.jl") 								# Macros
    	include("core/parallel.jl") 								# Code associated with Cell parallelism
	include("core/checks.jl")								# Various checks needed for the library
	include("core/version.jl")								# Fancy J4PR info
    
	# [lib]
	include("lib/libutils.jl")								# Utility functions for learning
	include("lib/mldatapattern.jl")								# MLDataPattern interface

	# [lib/data] e.g. data manipulation
		include("lib/data/cslice.jl")							# Class slicing (e.g. select classes)
		include("lib/data/labelutils.jl")                                               # Manipulation of datacell labels
		include("lib/data/datagen.jl")							# Datasets in datacell format
		include("lib/data/sample.jl")							# Data sampling
		include("lib/data/scale.jl")							# Data scaling
		include("lib/data/filter.jl")							# Data filter: generic, can be used for missing values
		include("lib/data/filterdomain.jl")						# Data domain filtering
		include("lib/data/ohenc.jl")							# One-hot encoding
		include("lib/data/textanalysis_interface.jl")					# TextAnalysis.jl interface (so far empty) 
		include("lib/data/videoio_interface.jl")					# VideoIO.jl interface (so far empty) 

	# [lib/ext] e.g external algorithms
		### include("lib/ext/kpca.jl")							# Kernel-PCA (MultivariateStats.jl)
		### include("lib/ext/fa.jl")							# Factor Analysis (MultivariateStats.jl)
		include("lib/ext/dist.jl")							# Distances (Distances.jl)
		include("lib/ext/whiten.jl")							# Data whitening (MultivariateStats.jl)
		include("lib/ext/pca.jl")							# PCA (MultivariateStats.jl)
		include("lib/ext/ppca.jl")							# Probabilistic PCA (MultivariateStats.jl)
		include("lib/ext/ica.jl")							# ICA (MultivariateStats.jl)
		include("lib/ext/mds.jl")							# MDS (MultivariateStats.jl)
		include("lib/ext/lda.jl")							# Multiclass LDA, Subspace LDA (MultivariateStats.jl)
		include("lib/ext/lr.jl")							# Linear regression (MultivariateStats.jl)
		include("lib/ext/kmeans.jl")							# K-means clustering (Clustering.jl)
		include("lib/ext/kmedoids.jl")							# K-medoids clustering (Clustering.jl)
		include("lib/ext/affinityprop.jl")						# Affinity propagation clustering (Clustering.jl)
		include("lib/ext/dbscan.jl")							# DBSCAN clustering (Clustering.jl)	
		include("lib/ext/decisiontree.jl")						# DecisionTree, Random Forest, Boosted stumps (DecisionTree.jl) 
		include("lib/ext/mlkernel.jl") 							# Machine Learning kernels (MLKernels.jl)			
	
	# [lib/unsup] e.g. unsupervised learning
		include("lib/unsup/kernel.jl")							# Lightweight way of constructing kernels

	# [lib/sup] e.g. supervised learning
		include("lib/sup/lindisc.jl")							# Linear discriminant classifier
		include("lib/sup/quaddisc.jl")							# Quadratic discriminant classifier
		include("lib/sup/parzen.jl")							# Parzen window density estimator/regressor/classifier
		include("lib/sup/loss.jl")							# Calculate losses based on MLLabelUtils.jl and LossFunctions.jl
		include("lib/sup/combiner.jl")							# Combine classifier outputs (labels, class posteriors, etc.)
		include("lib/sup/randomsubspace.jl")						# Random subspace ensemble framework
		include("lib/sup/adaboost.jl")							# AdaBoost ensemble framework
		include("lib/sup/stump.jl")							# Decision stump classifier and regressor
		include("lib/sup/networklearner.jl")						# Network learning 
	
	# Some packages do not work for Julia > 0.6
	if v"0.6" <= VERSION < v"0.7-"
		include("lib/data/images_interface.jl")						# Functions to transform to/from Images.jl representations from/to DataCells 
		include("lib/data/rdataset.jl")							# Loads different R datasets
		include("lib/ext/libsvm.jl")							# LIBSVM classifier/regressor (LIBSVM.jl)
		include("lib/sup/knn.jl")							# kNN classifier/regressor/density estimator
		include("lib/sup/roc.jl")							# ROC Analysis and operating point related functionality
	end

	# [exp] Experimental stuff
		include("exp/plotting.jl")							# Plots for labeled/unlabeled datasets (UnicodePlots.jl)
												# limited and biased view on the library's performance)	

    	##############################################################################################################################
    	# Post-loading steps 													     #		
    	##############################################################################################################################
	
	# Print welcome message
    	version(j4pr_version)

end
