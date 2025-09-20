# Build docs

Build locally with
```
julia --project=. make.jl
```
from the `/docs` folder or from the base directory with
```
julia --project=docs docs/make.jl
```

Don't forget to instantiate the `docs` environment. Julia v1.11 changed some of the error message functionality, therefore it is necessary to use Julia v1.11 to build this version of documentation.