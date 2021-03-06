# Test core utility functions
function t_coreutils()
	Xv = [0,1,2,3]
	Xm=[0 0 1 1; 1 1 2 2]
	y = [1,1,2,2]
	y2= [1 1 2 2;0 0 1 1]

	f=x->x

	D = j4pr.datacell(Xv,y)
	Du = j4pr.datacell(Xv)
	W = j4pr.functioncell(f)

	Test.@test j4pr.getx(D) == Xv
	Test.@test !(j4pr.getx(D) === Xv)
	Test.@test j4pr.getx!(D) == Xv
	Test.@test j4pr.getx!(D) === Xv
	
	Test.@test j4pr.gety(D) == y
	Test.@test !(j4pr.gety(D) === y)
	Test.@test j4pr.gety!(D) == y
	Test.@test j4pr.gety!(D) === y

	Test.@test j4pr.getf(W) == f
	Test.@test j4pr.getf(W) === f
	Test.@test j4pr.getf!(W) == f
	Test.@test j4pr.getf!(W) === f

	Test.@test j4pr.nvars(Xv) == 1
	Test.@test j4pr.nvars(Xm) == 2
	Test.@test j4pr.nvars(D) == 1

	Test.@test j4pr.strip(D) == (Xv,y)
	Test.@test j4pr.strip(Du) == Xv
	Test.@test j4pr.size(nothing) == 0
	Test.@test j4pr.size(nothing,rand(Int)) == 0
	Test.@test j4pr.size(D) ==j4pr.size(Xv)
	Test.@test j4pr.size(D,1) == j4pr.size(Xv,1)
	Test.@test j4pr.ndims(D) == 1

	Test.@test j4pr.isnan(nothing) == false
	Test.@test j4pr.isnan(randstring()) == false
	Test.@test j4pr.isnan([randstring() for i in 1:3]) == falses(3)
	Test.@test j4pr.isnan(DataArrays.data([randstring() for i in 1:3])) == falses(3)
	Test.@test j4pr.isnan([1,NaN,2]) == j4pr.isnan.([1,NaN,2])
	Test.@test j4pr.isvoid(nothing) == true
	Test.@test j4pr.isvoid(Any[1]) == false
	
	Test.@test j4pr.classsizes(Du) == DataStructures.SortedDict("unlabeled"=>4) 
	Test.@test j4pr.classsizes(D) == DataStructures.SortedDict(1=>2,2=>2)
	Test.@test j4pr.classsizes(j4pr.datacell(Xv,y2)) == [DataStructures.SortedDict(1=>2,2=>2),DataStructures.SortedDict(0=>2,1=>2)]
	Test.@test j4pr.nclasssizes(Du) == DataStructures.SortedDict("unlabeled"=>1) 
	Test.@test j4pr.nclasssizes(D) == DataStructures.SortedDict(1=>0.5,2=>0.5)
	Test.@test j4pr.nclasssizes(j4pr.datacell(Xv,y2)) == [DataStructures.SortedDict(1=>0.5,2=>0.5),DataStructures.SortedDict(0=>0.5,1=>0.5)]
	Test.@test j4pr.countmapn([1,2]) == DataStructures.SortedDict(1=>0.5,2=>0.5)
	Test.@test j4pr.countmapn(nothing) == DataStructures.SortedDict()
	Test.@test j4pr.classnames(Du) == []
	Test.@test j4pr.classnames(D) == [1,2]
	Test.@test j4pr.classnames(j4pr.datacell(Xv,y2)) == [[1,2],[0,1]]
	Test.@test j4pr.nclass(Du) == 0
	Test.@test j4pr.nclass(D) == 2
	Test.@test j4pr.nclass(j4pr.datacell(Xv,y2)) == [2,2]

end
