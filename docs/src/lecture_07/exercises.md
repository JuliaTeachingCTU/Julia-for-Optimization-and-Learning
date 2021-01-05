# Exercises

```@raw html
<div class = "homework-body">
<header class = "homework-header">Homework: Newton's method</header><p>
```
Newton's method for solving equation ``g(x)=0`` is an iterative procedure which at every iteration ``x^k`` approximates the function ``g(x)`` by its first-order (linear) expansion ``g(x) \approx g(x^k) + \nabla g(x^k)(x-x^k)`` and finds the zero point of this approximation.

Newton's method for unconstrained optimization replaces the optimization problem by its optimality condition and solves the resulting equation.

Implement Newton's method to minimize
```math
f(x) = \sin(x_1 + x_2) + \cos(x_1)^2
```
with the starting point ``x^0=(0,-1)``.
```@raw html
</p></div>
```   







```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1</header><p>
```
Show that the primal formulation for a problem with no inequalities is equivalent to the min-max formulation.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The primal problem with no inequalities reads
```math
\begin{aligned}
\text{minimize}\qquad &f(x) \\
\text{subject to}\qquad &h_j(x) = 0,\ j=1,\dots,J.
\end{aligned}
```
The Lagrangian has form
```math
L(x;\lambda,\mu) = f(x) + \sum_{j=1}^J \mu_j h_j(x).
```
Now consider the min-max formulation
```math
\operatorname*{minimize}_x\quad \operatorname*{maximize}_{\mu}\quad f(x) + \sum_{j=1}^J \mu_j h_j(x).
```
If ``h_j(x)\neq 0``, then it is simple to choose ``\mu_j``so that the inner maximization problem has the optimal value ``+\infty``. However, since the outer problem minimizes the objective, the value of ``+\infty`` is irrelevant. Therefore, we can ignore all points with ``h_j(x)\neq 0`` and prescribe ``h_j(x)=0`` as a hard constraint. That is precisely the primal formulation.
```@raw html
</p></details>
```







```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 2</header><p>
```
Derive the dual formulation for the linear programming.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The linear program
```math
\begin{aligned}
\text{minimize}\qquad &c^\top x \\
\text{subject to}\qquad &Ax=b, \\
&x\ge 0
\end{aligned}
```
has the Lagrangian
```math
L(x;\lambda,\mu) = c^\top x - \lambda^\top x + \mu^\top (b-Ax) = (c - \lambda - A^\top\mu)^\top x + b^\top \mu.
```
We need to have ``- \lambda^\top x`` because we require constraints ``g(x)\le 0`` or in other words ``-x\le 0``. The dual problem from its definition reads
```math
\operatorname*{maximize}_{\lambda\ge0, \mu} \quad \operatorname*{minimize}_x \quad (c - \lambda - A^\top\mu)^\top x + b^\top \mu.
```
Since the minimization with respect to ``x`` is unconstrained, the same arguments as the previous exercise imply the hard constraint ``c - \lambda - A^\top\mu=0``. Then we may simplify the dual problem into
```math
\begin{aligned}
\text{maximize}\qquad &b^\top \mu \\
\text{subject to}\qquad &c - \lambda - A^\top\mu = 0, \\
&\lambda\ge 0.
\end{aligned}
```
From this formulation, we may remove ``\lambda`` and obtain ``A^\top \mu\le c``. This is the desired dual formulation.
```@raw html
</p></details>
```






```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 3: Bisection method</header><p>
```
Similarly to Newton's method, the bisection method is primarily designed to solve equations by finding their zero points. It is only able to solve equations ``f(x)=0`` where ``f:\mathbb{R}\to\mathbb{R}``. It starts with an interval ``[a,b]`` where ``f`` has opposite values ``f(a)f(b)<0``. Then it selects the middle point on ``[a,b]`` and halves the interval so that the new interval again satisfies the constraint on opposite signs ``f(a)f(b)<0``. This is repeated until the function value is small or until the interval has a small length.

Implement the bisection method and use it to minimize ``f(x) = x^2 - x`` on ``[-1,1]``. During the implementation, do not evaluate ``f`` unless necessary.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
First, we write the bisection method. We initialize it with arguments ``f`` and the initial interval ``[a,b]``. We also specify the optional tolerance. First, we save the function value ```fa = f(a)``` to not need to recompute it every time. The syntax ```fa == 0 && return a``` is a bit complex. Since ```&&``` is the "and" operator, this first checks whether ```fa == 0``` is satisfied and if so, it evaluates the second part. However, the second part exits the function and returns ```a```. Since we need to have ``f(a)f(b)<0``, we check this condition, and if it is not satisfied, we return an error message. Finally, we run the while loop, where every iteration halves the interval. The condition on opposite signs is enforced in the if condition inside the loop.
```@example bisec
function bisection(f, a, b; tol=1e-6)
    fa = f(a)
    fb = f(b)
    fa == 0 && return a
    fb == 0 && return b
    fa*fb > 0 && error("Wrong initial values for bisection")
    while b-a > tol
        c = (a+b)/2
        fc = f(c)
        fc == 0 && return c
        if fa*fc > 0
            a = c
            fa = fc
        else
            b = c
            fb = fc
        end
    end
    return (a+b)/2
end
nothing # hide
```
This implementation is efficient in the way that only one function evaluation is neededper iteration. The price to pay are additional variables ```fa```, ```fb``` and ```fc```.

To use the bisection method to minimize a function ``f(x)``, we use it find the solution of the optimality condition ``f'(x)=0``.
```@example bisec
f(x) = x^2 - x
g(x) = 2*x - 1
x_opt = bisection(g, -1, 1)
nothing # hide
```
```@raw html
</p></details>
```
The correct solution is
```@example bisec
println(round(x_opt, digits=4)) # hide
```





```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 4: JuMP</header><p>
```
The library to perform optimization is called ```JuMP```. Install it, go briefly through its documentation, and use it to solve the linear optimization problem
```math
\begin{aligned}
\text{minimize}\qquad &x_1 + x_2 + x_5 \\
\text{subject to}\qquad &x_1+2x_2+3x_3+4x_4+5x_5 = 8, \\
&x_3+x_4+x_5 = 2, \\
&x_1+x_2 = 2.
\end{aligned}
```    
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The best start is the official documentation of the [JuMP package](https://jump.dev/JuMP.jl/stable/quickstart/). Since ```JuMP``` is only an interface for solvers, we need to include an actual solver as well. For linear programs, we can use ```using GLPK```, for non-linear ones, we would need to use ```using Ipopt```. We specify the constraints in a matrix form. It is possible to write them directly via ```@constraint(model, x[1] + x[2] == 2)```. This second way is more pleasant for complex constraints. Since ```x``` is a vector, we need to use ```value.(x)``` instead of the wrong ```value(x)```.
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
nothing # hide
```
```@raw html
</p></details>
```

The correct solution is
```@example optim
println(round.(x_val, digits=4)) # hide
```





```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 5: SQP method</header><p>
```
Derive the SQP method for optimization problem with only equality constraints
```math
\begin{aligned}
\text{minimize}\qquad &f(x) \\
\text{subject to}\qquad &h_j(x) = 0, j=1,\dots,J.
\end{aligned}
```
SQP writes the optimality (KKT) conditions and then applies Newton's method to solve the resulting system of equations. 

Apply the obtained algorithm to
```math
\begin{aligned}
\text{minimize}\qquad &\sum_{i=1}^{10} ix_i^4 \\
\text{subject to}\qquad &\sum_{i=1}^{10} x_i = 1.
\end{aligned}
``` 
Verify that the numerically obtained solution is correct.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
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

We define functions ``f`` and ``h`` and their derivates and Hessians for the numerical implementation. The simplest way to create a diagonal matrix is ```Diagonal``` from the ```LinearAlgebra``` package. It can be, of course, done manually as well. 
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
To implement SQP, we first randomly generate initial ``x`` and ``\mu`` and then write the procedure derived above. Since we update ``x`` in a for loop, we need to define it as a ```global``` variables; otherwise, it will be a local variable, and the global (outside of the loop) will not update. We can write ```inv(A)*b``` or the more efficient ```A\b```. To subtract from ``x``, we use the shortened notation ```x -= ?```, which is the same as ```x = x - ?```.
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
The need to differentiate global and local variables in scripts are one of the reasons why functions should be used as much as possible.

To validate, we need to verify the optimality and the feasibility; both need to equal to zero. These are the same as the ```b``` variable. However, we cannot call ```b``` directly, as it is inside the for loop and therefore local only.
```@repl sqp
f_grad(x) + μ*h_grad(x)
h(x)
```
```@raw html
</p></details>
```
The correct solution is
```@example sqp
println(round.(x, digits=4)) # hide
```




