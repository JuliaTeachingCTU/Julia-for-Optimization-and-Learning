```@setup theory
using Plots
```

# Theory of regression and classification

Regression and classification are a part of machine learning which try to predict certain variables based on labelled data.
- Regression predicts a continuous variable (such as height based on weight).
- Classification predict a variable with a finite number of states (such as cat/dog/none from images).

## Linear regression

Linear regression requires a dataset with data points (samples) ``x_i`` and labels ``y_i``. It uses a linear classifier to minimize the error between the prediction ``w^\top x_i`` and the label ``y_i``, that is
```math
(w^\top x_i - y_i)^2.
```
Since we are interested in average performance, we sum this (mean square) error over all samples
```math
\operatorname{minimize}\qquad \sum_{i=1}^n (w^\top x_i - y_i)^2.
```
Many algorithms use average (mean) instead of sum. However, both these formulations are equivalent.

In this case, it is simpler to work in the matrix notation, where we form a matrix ``X`` whose rows are the samples ``x_i``. It is not difficult to show that the previous problem is equivalent to
```math
\operatorname{minimize}\qquad \|Xw - y\|^2,
```
where the norm is the ``l_2`` norm. Since this is a convex quadratic problem, it is equivalent to its optimality conditions. Setting the derivative to zero yields
```math
2X^\top (Xw-y) = 0.
```
From here, we obtain the closed-form solution to the linear regression
```math
w = (X^\top X)^{-1}X^\top y.
```

```@raw html
<div class = "info-body">
<header class = "info-header">Closed-form solution</header><p>
```
Linear regression is probably the only machine learning model with a closed-form solution. All other models must be solved by iterative algorithms such as gradient descent. In some cases, it may be advantageous to use iterative algorithms even for linear regression. This includes, for example, the case of a large number of features ``m`` because then ``X^\top X`` is an ``m\times m`` matrix which may be difficult to invert.
```@raw html
</p></div>
```



```@raw html
<div class = "info-body">
<header class = "info-header">Linear classifiers</header><p>
```
We realize that
```math
w^\top x + b = (w, b)^\top \begin{pmatrix}x \\ 1\end{pmatrix}.
```
That means that if we add ``1`` to each sample ``x_i``, it is sufficient to consider the classifier in the form ``w^\top x`` without the bias (shift, intercept) ``b``. This allows for simpler implementation.
```@raw html
</p></div>
```




## Logistic regression

The name logistic regression is misleading because it is actually a classification problem. In its simplest form, it assumes binary labels ``y\in\{0,1\}``. It considers the linear classifier ``f(x)=w^\top x`` and predicts the positive class with probability
```math
\mathbb{P}(y=1\mid x) = \sigma(f(w)) = \frac{1}{1+e^{-w^\top x}},
``` 
where
```math
\sigma(z) = \frac{1}{1+e^{-z}} = \frac{e^z}{1+e^z}
```
is the sigmoid function. The probability of the negative class is then
```math
\mathbb{P}(y=0\mid x) = 1 - \sigma(f(w)) = \frac{e^{-w^\top x}}{1+e^{-w^\top x}}.
```
Denoting ``\hat y`` the probabily of predicting ``1``, the loss function is the cross-entropy loss
```math
\operatorname{loss}(y,\hat y) = - y\log \hat y - (1-y)\log(1-\hat y).
```
It is not difficult to show that then the logistic regression problems reads
```math
\operatorname{minimize}\qquad \frac1n\sum_{i=1}^n\left(\log(1+e^{-w^\top x_i}) + (1-y_i)w^\top x_i \right).
```

#### Numerical method

The logistic regression can be optimized by Newton's method. Denoting the loss function ``L(w)``, its partial derivative with respect to one component equals to
```math
\begin{aligned}
\frac{\partial L}{\partial w_j}(w) &= \frac1n\sum_{i=1}^n\left(-\frac{1}{1+e^{-w^\top x_i}}e^{-w^\top x_i}x_{i,j} + (1-y_i)x_{i,j} \right) \\
&= \frac1n\sum_{i=1}^n\left(-\frac{1}{1+e^{w^\top x_i}}x_{i,j} + (1-y_i)x_{i,j} \right),
\end{aligned}
```
where ``x_{i,j}`` is the ``j``-th component of ``x_i`` (it is also the ``(i,j)`` entry of matrix ``X``). The second partial derivative amounts to
```math
\frac{\partial^2 L}{\partial w_j \partial w_k}(w) = \frac1n\sum_{i=1}^n \frac{1}{(1+e^{w^\top x_i})^2}e^{w^\top x_i}x_{i,j}x_{i,k} = \frac1n\sum_{i=1}^n \hat y_i(1-\hat y_i)x_{i,j}x_{i,k}.
```
Now we will write it in a more compact notation (recall that ``x_i`` is a column vector). We have
```math
\begin{aligned}
\nabla L(w) &= \frac1n \sum_{i=1}^n \left((\hat y_i-1)x_i + (1-y_i)x_i \right) = \frac1n \sum_{i=1}^n (\hat y_i-y_i)x_i, \\ 
\nabla^2 L(w) &= \frac 1n \sum_{i=1}^n\hat y_i(1-\hat y_i)x_i x_i^\top.
\end{aligned}
```
If the fit is perfect, ``y_i=\hat y_i``, then the Jacobian ``\nabla L(w)`` is zero. Then the optimizer minimized the objective and satisfied the optimality condition.
