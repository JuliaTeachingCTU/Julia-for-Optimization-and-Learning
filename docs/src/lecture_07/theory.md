```@setup optim
using Plots
```

# Theory of continuous optimization

Optimization problems optimize (minimize or maximize) given function on a given set. There are many applications in the world:
- Maximize profit under market forecasts.
- Given a set of points, find a visiting order which minimizes the distance. This includes various tasks ranging from delivery services to snow ploughing. 
- Make a prediction based on known data. Specific examples are whether a client gets a loan or whether an autonomous vehicle sees a pedestrian. Almost all tasks in machine learning minimize the difference between a prediction and a label.
- Find the optimal shape of a machine such a criterion is maximized. This includes designing planes with minimal drag or optimizing engines to maximize power under a reasonable oil consumption. 

These applications are very different in what they assume about the world, and in the form in which they are written and subsequently solved.
- Maximization of profits will need to model future uncertainty. The formulation will probably contain the expected value of chance constraints. The variables will be usually continuous. 
- Finding the minimal way is often reformulated as finding the shortest way in a graph. Problems like this operate typically with only binary variables and with no uncertainty.  
- Machine learning needs loads of data and usually ignores any physical models. Due to the abundance of data, the evaluation of the objective function is lengthy. Then a special algorithm for speed-ups needs to be developed.
- Topology optimization is usually based on complicated physical models. Since these are in a black-box form, additional information such as gradient is often not available. Moreover, conflicting criteria (such as speed and consumption) need to be considered. 

This short analysis implies that there is not a single "optimization topic". The theory of optimization contains many different subfields. In the following four lectures, we will study the continuous optimization, which assumes that all functions are (sub)differentiable, and all variables are continuous. This includes most machine learning applications, to which we dedicate three lectures.

## Problem definition

The goal of an optimization problem is to minimize of maximize a function ``f`` over a set ``X``. Namely
```math
    \begin{aligned}
    \text{minimize}\qquad &f(x) \\
    \text{subject to}\qquad &x\in X.
    \end{aligned}
```
Should we consider both minimization and maximization problems? No. Because
```math
    \text{maximize}\qquad f(x)
```
is equivalent to 
```math
    -\text{minimize}\qquad -f(x).
```
Therefore, it suffices to consider minimization problems.

## Gradients

As we will see later, gradients are crucial to optimization. For a function ``f:\mathbb{R}\to \mathbb{R}`` it is defined by
```math
f'(x) = \lim_{h\to 0}\frac{f(x+h)-f(x)}{h}.
```
For a mapping  ``f:\mathbb{R}^n\to \mathbb{R}^m``, the Jacobian is a matrix ``\nabla f(x)`` of size ``m\times n`` which satisfies
```math
    \lim_{h\to 0}\frac{\|f(x+h)-f(x) - \nabla f(x)h \|}{\|h\|} = 0.
```
If a function ``f=(f_1,\dots,f_m)`` is differentiable, then
```math
(\nabla f(x))_{i,j} = \frac{\partial f_i}{\partial x_j}(x) = \lim_{h\to 0}\frac{f_i(x_1,\dots,x_{j-1},x_j+h,x_{j+1},\dots,x_n)-f(x_1,\dots,x_n)}{h}
```

```@raw html
<div class = "info-body">
<header class = "info-header">Confusion</header><p>
```
Gradient ``\nabla f(x)`` of a function ``f:\mathbb{R}^n\to\mathbb{R}`` should be of size  ``1\times n`` but it is commonly considered as ``n\times 1``.
```@raw html
</p></div>
```

To compute the gradient, the chain rule is crucial.

```@raw html
<div class = "theorem-body">
<header class = "theorem-header">Theorem: Chain</header><p>
```
Consider two differentiable functions ``f:\mathbb{R}^m\to\mathbb{R}^s`` and ``g:\mathbb{R}^n\to\mathbb{R}^m``. Then its composition ``h(x) := f(g(x))`` is differentiable with Jacobian
```math
\nabla h(x) = \nabla f(g(x))\nabla g(x).
```
```@raw html
</p></div>
```

## Unconstrained optimization

What do we look for when we minimize a function ``f`` over some ``X``? The optimal point would be a global minimum, which is a point ``x\in X`` which satisfies
```math
f(x) \le f(y) \text{ for all }y\in X.
```
This point is often very difficult to find. Sometimes we are able to find a local minimum, which is a global minimum on some small neighbourhood of ``x``.

```@raw html
<div class = "theorem-body">
<header class = "theorem-header">Theorem: Connection between optimization problems and gradients</header><p>
```
Consider a differentiable function ``f`` over ``X=\mathbb{R}^n``. If ``x`` is its local minimum, then ``\nabla f(x)=0``. Conversely, if ``f`` is convex, then every point ``x`` with ``\nabla f(x)=0`` is a global minimum of ``f``.
```@raw html
</p></div>
```

Points with ``\nabla f(x)=0`` are known as stationary points. Optimization algorithms often try to find them with the hope that they minimize the function ``f``.

![](minmax.svg)


```@raw html
<div class = "info-body">
<header class = "info-header">Take care</header><p>
```
This theorem does not hold if ``X`` is not the whole space.
```@raw html
</p></div>
```

## Constrained optimization

The usual formulation of constrained optimization is in the form
```math
\tag{P}
\begin{aligned}
\text{minimize}\qquad &f(x) \\
\text{subject to}\qquad &g_i(x) \le 0,\ i=1,\dots,I, \\
&h_j(x) = 0,\ j=1,\dots,J.
\end{aligned}
```
This optimization problem is also called the primal formulation. It is closely connected with the Lagrangian
```math
L(x;\lambda,\mu) = f(x)  + \sum_{i=1}^I \lambda_i g_i(x) + \sum_{j=1}^J \mu_j h_j(x).
```
Namely, it is simple to show that the primal formulation (P) is equivalent to
```math
\operatorname*{minimize}_x\quad \operatorname*{maximize}_{\lambda\ge 0,\mu}\quad L(x;\lambda,\mu).
```
The dual problem then switches the minimize and maximize operators to arrive at
```math
\tag{D} \operatorname*{maximize}_{\lambda\ge 0,\mu} \quad\operatorname*{minimize}_x\quad L(x;\lambda,\mu).
```

```@raw html
<div class = "info-body">
<header class = "info-header">Linear programming</header><p>
```
The linear program
```math
\begin{aligned}
\text{minimize}\qquad &c^\top x \\
\text{subject to}\qquad &Ax=b, \\
&x\ge 0
\end{aligned}
```
is equivalent to
```math
\begin{aligned}
\text{maximize}\qquad &b^\top \mu \\
\text{subject to}\qquad &A^\top \mu\le c.
\end{aligned}
```
We can observe several things:
1. Primal and dual problems switch minimization and maximization.
2. Primal and dual problems switch variables and constraints.
```@raw html
</p></div>
```

The optimality conditions for constrained optimization take a more complex form.

```@raw html
<div class = "theorem-body">
<header class = "theorem-header">Theorem: Karush-Kuhn-Tucker conditions</header><p>
```
Let ``f``, ``g_i`` and ``h_j`` be differentiable function and let a constraint qualification hold. If ``x`` is a local minimum of the primal problem (P), then there are $\lambda\ge 0$ and $\mu$ such that
```math
    \begin{aligned}
    &\text{Optimality:} && \nabla_x L(x;\lambda,\mu) = 0, \\
    &\text{Feasibility:} && \nabla_\lambda L(x;\lambda,\mu)\le 0,\ \nabla_\mu L(x;\lambda,\mu) = 0, \\
    &\text{Complementarity:} && \lambda^\top g(x) = 0.
    \end{aligned}
```
If $f$ and $g$ are convex and $h$ is linear, then every stationary point is a global minimum of (P).
```@raw html
</p></div>
```