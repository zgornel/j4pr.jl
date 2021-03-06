# Tests for distances
function t_ppca()


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
			Wppca = tr |> j4pr.ppca(maxoutdim=1)
			Wppcar = j4pr.ppcar(Wppca)
			ts |> Wppca 
			(ts |> Wppca) |> Wppcar
			true
		catch 
			false
		end
	end
end

# Short test for ppcar on vector data
Test.@test try 
	Wppca = A01 |> j4pr.ppca(maxoutdim=1)
	Wppcar = j4pr.ppcar(Wppca)
	(A01 |> Wppca) |> Wppcar
	true
catch 
	false
end

for tr in [A04, A05, A06, matrixdata]
	for ts in [A04, A05, A06, matrixdata]
		Test.@test try
			Wppca = tr |> j4pr.ppca()
			Wppcar = j4pr.ppcar(Wppca)
			ts |> Wppca 
			(ts |> Wppca) |> Wppcar
			true
		catch 
			false
		end
	end
end

end

