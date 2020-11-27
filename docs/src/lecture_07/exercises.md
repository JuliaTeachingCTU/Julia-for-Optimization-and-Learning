# Exercises

!!! info "Homework: Newton's method"
    The Newton's method for solving equation ``g(x)`` is an iterative procedure which at every iteration ``x^k`` approximates the function ``g(x)`` by its first-order (linear) expansion ``g(x) \approx g(x^k) + \nabla g(x^k)(x-x^k)`` and finds the zero point of this approximation.

    The Newton's method for unconstrained optimization replaces the optimization problem by its optimality condition and solves the resulting equation.

    Implement the Newton's method to minimize
    ```math
    f(x) = \sin(x_1 + x_2) + \cos(x_1)^2
    ```
    with the starting point ``x^0=(0,-1)``.
    








!!! tip "Exercise 1"
    Show that the primal formulation is equivalent to the min-max formulation.

```@raw html
<details>
<summary>Solution:</summary>
<p>
```
???
```@raw html
</p>
</details>
```







!!! tip "Exercise 2"
    Derive the dual formulation for the linear programming.

```@raw html
<details>
<summary>Solution:</summary>
<p>
```
???
```@raw html
</p>
</details>
```







!!! tip "Exercise 3: Bisection method"
    ???

```@raw html
<details>
<summary>Solution:</summary>
<p>
```
???
```@raw html
</p>
</details>
```







!!! tip "Exercise 3: JuMP"
    The library to perform optimization is called ```JuMP```. Install it and use it to solve the linear optimization problem
    ```math
    \begin{aligned}
    \text{minimize}\qquad &x_1 + x_2 + x_5 \\
    \text{subject to}\qquad &x_1+2x_2+3x_3+4x_4+5x_5 = 8, \\
    &x_3+x_4+x_5 = 2, \\
    &x_1+x_2 = 2.
    \end{aligned}
    ```
    
```@raw html
<details>
<summary>Solution:</summary>
<p>
```
```@example optim
using JuMP
using GLPK

A = [1 2 3 4 5; 0 0 1 1 1; 1 1 0 0 0]
b = [8; 2; 2]
c = [1; 1; 0; 0; 1]
n = size(A, 2)

model = Model(GLPK.Optimizer)

@variable(model, x[1:n] >= 0)

@objective(model, Min, c'*x)
@constraint(model, A*x .== b)
optimize!(model)

x_val = value.(x)
```
```@raw html
</p>
</details>
```

The correct solution is
```@example optim
println(round.(x_val, digits=4)) # hide
```






!!! tip "Exercise 4: SQP method"
    Derive the SQP method for optimization problem with only equality constraints
    ```math
    \begin{aligned}
    \text{minimize}\qquad &f(x) \\
    \text{subject to}\qquad &h_j(x) = 0, j=1,\dots,J.
    \end{aligned}
    ```
    SQP writes the optimality (KKT) conditions and the applies the Newton's method to solve the resulting system of equations. 

    Apply the obtained algorithm to
    ```math
    \begin{aligned}
    \text{minimize}\qquad &\sum_{i=1}^{10} ix_i^4 \\
    \text{subject to}\qquad &\sum_{i=1}^{10} x_i = 1.
    \end{aligned}
    ``` 
    Verify that the numerically obtained solution is correct.

```@raw html
<details>
<summary>Solution:</summary>
<p>
```
The Lagrangian reads
```math
L(x,\mu) = f(x) + \sum_{j=1}^J\mu_j h_j(x).
```
Since there are no inequality constraints, the optimality conditions contain no complementarity and read
```math
\begin{aligned}
\nabla f(x) + \sum_{j=1}^J\mu_j \nabla h_j(x) &= 0,\\
h_j(x) &= 0,
\end{aligned}
```
The Newton method's at iteration ``k`` has some pair ``(x^k,\mu^k)`` and performs the update
```math
\begin{pmatrix} x^{k+1} \\ \mu^{k+1} \end{pmatrix} = \begin{pmatrix} x^{k} \\ \mu^{k} \end{pmatrix} - \begin{pmatrix} \nabla^2 f(x^k) + \sum_{j=1}^J \mu_j^k \nabla^2 h_j(x^k) & \nabla h(x^k) \\ \nabla h(x^k)^\top & 0 \end{pmatrix}^{-1} \begin{pmatrix} \nabla f(x^k) + \sum_{j=1}^J\mu_j^k \nabla h_j(x^k) \\ h(x^k) \end{pmatrix}. 
```

For the numerical implementation, we define functions ``f`` and ``h`` and their derivates and Hessians. The simplest way to create a diagonal matrix is ```Diagonal``` from the ```LinearAlgebra``` package. It can be of course done manually as well. 
```@example sqp 
using LinearAlgebra

n = 10
f(x) = sum((1:n) .* x.^4)
f_grad(x) = 4*(1:n)[:].*x.^3
f_hess(x) = 12*Diagonal((1:n)[:].*x.^2)
h(x) = sum(x) - 1
h_grad(x) = ones(n)
h_hess(x) = zeros(n,n)
nothing # hide
```
To implement SQP we first randomly generate initial ``x`` and ``\mu`` and then write the procedure derived above. Since we update ``x`` in a for loop, we need to define it as a ```global``` variables; otherwise, it will be a local variable and the global (outside of the loop) will not update. We can write ```inv(A)*b``` or the more efficient ```A\b```. To subtract from ``x``, we use the shortened notation ```x -= ?```, which is the same as ```x = x - ?```.
```@example sqp
x = randn(n)
μ = randn()
for i in 1:100
    global x, μ
    A = [f_hess(x) + μ*h_hess(x) h_grad(x); h_grad(x)' 0]
    b = [f_grad(x) + μ*h_grad(x); h(x)]
    step = A \ b
    x -= step[1:n]
    μ -= step[n+1] 
end
```
To validate we need to verify the optimality and the feasibility; both need to equal to zero. These are the same as the ```b``` variable. However, we cannot call ```b``` directly, as it is inside the for loop and therefore local only.
```@repl sqp
f_grad(x) + μ*h_grad(x)
h(x)
```
```@raw html
</p>
</details>
```
The correct solution is
```@example sqp
println(round.(x, digits=4)) # hide
```







!!! tip "Exercise 5"
    ??? gd with multiple stepsizes

```@raw html
<details>
<summary>Solution:</summary>
<p>
```
???
```@raw html
</p>
</details>
```