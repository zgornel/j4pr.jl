# Tests for ICA 
function t_ica()


N = 10	# variables
M = 25  # samples

vectordata = rand(M)
matrixdata = rand(N,M)
labels = round.(2*rand(M))
multilabels = round.(2*rand(2,M))

A01 = j4pr.datacell(vectordata)
A02 = j4pr.datacell(vectordata, labels)
A03 = j4pr.datacell(vectordata, multilabels)
A04 = j4pr.datacell(matrixdata)
A05 = j4pr.datacell(matrixdata, labels)
A06 = j4pr.datacell(matrixdata, multilabels)


for tr in [A01, A02, A03, vectordata]
	for ts in [A01, A02, A03, vectordata]
		Test.@test try 
			ts |> (tr |> j4pr.ica(1)); 
			true
		catch 
			false
		end
	end
end

for tr in [A04, A05, A06, matrixdata]
	for ts in [A04, A05, A06, matrixdata]
		Test.@test try 
			ts |> (tr |> j4pr.ica(2)); 
			true
		catch 
			false
		end
	end
end

end
