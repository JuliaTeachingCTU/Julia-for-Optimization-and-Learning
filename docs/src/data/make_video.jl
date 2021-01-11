ENV["MATLAB_HOME"] = "D:\\Matlab\\R2020b"
using MATLAB
using BSON

s = MSession()

X = BSON.load("data.bson")[:X]
X = mxarray(X)  
@mput X

eval_string(s, "MakeVideo(X, 30, \"Video.gif\");")
