# Tests for loss function functionality 
function t_loss()

Ac = j4pr.DataGenerator.fish(20)  # classification dataset
Ar = j4pr.DataGenerator.fishr(20) # regression dataset


# Test losses for classification
tr,ts = j4pr.splitobs(j4pr.shuffleobs(Ac),0.5)
wt = tr |> j4pr.lindisc(rand(),rand())
ts = j4pr.getobs(ts)
wlc1 = j4pr.loss(()->MLLabelUtils.convertlabel(MLLabelUtils.LabelEnc.OneOfK{Float64}, -ts, wt.x.properties.labels.label)::Matrix{Float64 }) # for array input
wlc2 = j4pr.loss((x)->MLLabelUtils.convertlabel(MLLabelUtils.LabelEnc.OneOfK{Float64}, x, wt.x.properties.labels.label)::Matrix{Float64 }) # for Tuple/datacell input
	r1 = +ts |> wt+wlc1
	r2 = ts |> wt+wlc2
	r3 = j4pr.strip(ts|>wt) |> wlc2
Test.@test  r1==r2==r3	

# Test losses for regression
tr,ts = j4pr.splitobs(j4pr.shuffleobs(Ar),0.5)
wt = tr |> j4pr.stumpr()
ts = j4pr.getobs(ts)
wlc1 = j4pr.loss(()->-ts, vec) # for array input
wlc2 = j4pr.loss(identity,vec) # for Tuple/datacell input
	r1 = +ts |> wt+wlc1
	r2 = ts |> wt+wlc2
	r3 = j4pr.strip(ts|>wt) |> wlc2
Test.@test  r1==r2==r3	


end
