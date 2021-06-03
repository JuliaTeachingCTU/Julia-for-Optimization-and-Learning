# Introduction to continuous optimization

Optimization problems optimize (minimize or maximize) a given function on a given set. There are many applications:
- Maximize profit under market forecasts.
- Given a set of points, find a visiting order which minimizes the distance. This application includes various tasks ranging from delivery services to snow ploughing. 
- Make a prediction based on known data. Specific examples are whether a client gets a loan or whether an autonomous vehicle sees a pedestrian. Almost all tasks in machine learning minimize the difference between a prediction and a label.
- Find the optimal shape of a machine so that a criterion is maximized. Specific examples are designing planes with minimal drag or optimizing engines to maximize power under a reasonable oil consumption. 

These applications are very different from each other. They differ in their assumptions about the world, in their formulation and solution way.
- Profit maximization needs to model future uncertainty. The formulation will probably contain expectations and chance constraints, while the variables will be continuous. 
- Finding the minimal way is often reformulated as finding the shortest path in a graph. Problems like this operate typically with binary variables and no uncertainty.  
- Machine learning requires loads of data and usually ignores any physical models. Due to the abundance of data, the objective function evaluations are lengthy, and specially designed optimization algorithms are used.
- Topology optimization is based on complicated physical models. Since these often come in a black-box form, additional information such as gradient is often not available. Moreover, the optimizer needs to consider conflicting criteria such as speed and consumption.

This short analysis implies that there is no single "optimization topic", and the theory of optimization contains many different subfields. In the following four lectures, we will study the field of continuous optimization, which assumes that all functions are (sub)differentiable and all variables are continuous. This includes most machine learning applications, to which we dedicate three lectures.

## Problem definition

The goal of an optimization problem is to minimize or maximize a function ``f`` over a set ``X``:

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

This trick has a neat consequence: All numerical and theoretical results are derived only for minimization problems. If we deal with a maximization problem, we convert it first to an optimization problem and then use the known results.
