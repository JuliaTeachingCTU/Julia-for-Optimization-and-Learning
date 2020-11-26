using Query, DataFrames, Statistics

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

x = @from i in df begin
    @where i.age > 50
    @collect DataFrame
end

df = DataFrame(name=repeat(["John", "Sally", "Kirk"],inner=[1],outer=[2]),
     age=vcat([10., 20., 30.],[10., 20., 30.].+3),
     children=repeat([3,2,2],inner=[1],outer=[2]),state=[:a,:a,:a,:b,:b,:b])

x = @from i in df begin
    @group i by i.state into g
    @select {group=key(g),mage=mean(g.age), oldest=maximum(g.age), youngest=minimum(g.age)}
    @collect DataFrame
end


df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,2,2])

x = @from i in df begin
    @let count = length(i.name)
    @let kids_per_year = i.children / i.age
    @where count > 4
    @select {Name=i.name, Count=count, KidsPerYear=kids_per_year}
    @collect DataFrame
end
