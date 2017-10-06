# Tests for Label and continuous output combiners 
function t_combiners()

# test labels
L = [ 1 1 2 0; 
      0 0 1 1; 
      1 0 1 2 ]

# train labels
TL =( [1 2 0 0; # estimate labels from 3 ensemble members
      1 0 1 1; 
      1 1 2 1],
     [1,2,0,0] ) # true labels


# Test for vote combiner
Base.Test.@test all((L |> j4pr.votecombiner(size(L,1)))[:,1:3] .== [1 0 1])

# Test for weighted vote combiner
wcmb=TL|> j4pr.wvotecombiner(3) # 1'st line closest, Inf weight to 1'st ensemble memeber
Base.Test.@test all((L |> wcmb) .== L[1:1,:])# the result is identical to the first line of L

# Test for Naive Bayes combiner
nbcmb=TL |> j4pr.naivebayescombiner(3)
Base.Test.@test all((L |> nbcmb) .== [1 1 1 1])

# Test for Naive Bayes combiner - add 2 more label output combinations 
#to L that were seen in training 
bkscmb=TL |> j4pr.bkscombiner(3) 
Base.Test.@test all(([L [1,1,1] [2,0,1]] |> bkscmb) .== [0 0 0 0 1 2])

# Test for the mean combiner (3 outputs, 1 continuous output)
Base.Test.@test L |> j4pr.meancombiner(3,1) ≈ [2/3 1/3 4/3 1.0]

# test for the weighted mean combiner
Base.Test.@test L |> j4pr.wmeancombiner(3,1,[1.0,2,3]) ≈ [(1*1.0+3*1)/3 (1*1.0)/3 (2*1+1*2+1*3)/3 (1*2+2*3)/3]

# Test for the product combiner
Base.Test.@test all((L |> j4pr.productcombiner(3,1)) .== [0 0 2 0])

# Test for the median combiner
Base.Test.@test all((L |> j4pr.mediancombiner(3,1)) .== [1 0 1 1])

end
