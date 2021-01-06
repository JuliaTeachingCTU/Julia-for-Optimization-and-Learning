```@setup theory
using Plots
```

# Theory of regression and classification

Regression and classification are a part of machine learning which try to predict certain variables based on labelled data.
- Regression predicts a continuous variable (such as height based on weight).
- Classification predict a variable with a finite number of states (such as cat/dog/none from images).

## Data representation

The dataset is usually stored in a matrix ``X\in\mathbb{R}^{n\times m}``. Each row of this matrix is one sample (observation). Each column is one feature (such as height, weight or age). Therefore, we have ``n`` samples, each with ``m`` features. Each sample ``x_i`` has a label ``y_i``. Labels are arranged into a vector ``y\in\mathbb{R}^n``. The goal of machine learning methods is to find a classifier ``f`` such that the prediction ``f(x_i)`` is a good approximation of the true label ``y_i``.

This lecture considers only linear classifiers in the form
```math
\tilde f(x) = w^\top x + b,
```
while the next one on neural network considers non-linear classifiers as well. 
The standard trick assumes that the first column of ``X`` contains all ones. Then we have
```math
f(x) = w^\top x = w_1 + \sum_{j=2}^m w_jx_j,
```
By this trick, we do not need to consider the intercept (bias, shift) ``b`` because it is contained in ``w_1``. In this case, the class of all considered classifiers is parameterized by a vector ``w``. The rest of this lecture shows how to write regression and classification problems to find the optimal weights ``w``.

## Linear regression

The linear regression uses the mean square error between the prediction and the label. This is
```math
(w^\top x_i - y_i)^2.
```
Since we are interested in average performance, we sum this error over all samples
```math
\operatorname{minimize}\qquad \sum_{i=1}^n (w^\top x_i - y_i)^2.
```
Many algorithms use average (mean) instead of sum. However, both these formulations are equivalent.

In this case, it is simpler to work in the matrix notation. It is not difficult to show that the previous problem is equivalent to
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
