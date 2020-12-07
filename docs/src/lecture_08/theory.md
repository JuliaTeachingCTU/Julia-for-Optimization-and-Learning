```@setup theory
using Plots
```

# Theory of regression and classification

## Data representation


??? WHAT is x


We will use a standard trick and assume that the first column of ``X`` contains all ones. Then we have
```math
f(w) = w^\top x = w_1 + \sum_{j=2}^m w_jX_{\cdot,j},
```
where ``X_{\cdot,j}`` is the ``j``-th column of ``X``. By this trick, we do not need to consider the intercept (shift) ``b`` because it is contained in ``w_1``.

## Linear regression

## Logistic regression

The name logistic regression is misleading because it is actually a classification problem. In its simplest form, it assumes binary labels ``y\in\{0,1\}``. It considers the linear classifier ``f(x)=w^\top x`` and predict the positive class with probability
```math
\mathbb{P}(y=1\mid x) = \sigma(f(w)) = \frac{1}{1+e^{-w^\top x}},
``` 
where ``\sigma`` is the sigmoid function. The probability of the negative class is then
```math
\mathbb{P}(y=0\mid x) = 1 - \sigma(f(w)) = \frac{e^{-w^\top x}}{1+e^{-w^\top x}}.
```
Denoting ``\hat y`` to equal the probabily of predicting ``1``, the loss function is the cross-entropy loss
```math
\operatorname{loss}(y,\hat y) = - y\log \hat y - (1-y)\log(1-\hat y).
```
It is not difficult to show that then the logistic regression problems reads
```math
\operatorname{minimize}\qquad \frac1n\sum_{i=1}^n\left(\log(1+e^{-w^\top x_i}) + (1-y_i)w^\top x_i \right).
```

#### Numerical method

Denoting the loss function ``L(w)``, its partial derivative equals to
```math
\begin{aligned}
\frac{\partial L}{\partial w_j}(w) &= \frac1n\sum_{i=1}^n\left(-\frac{1}{1+e^{-w^\top x_i}}e^{-w^\top x_i}x_{i,j} + (1-y_i)x_{i,j} \right) \\
&= \frac1n\sum_{i=1}^n\left(-\frac{1}{1+e^{w^\top x_i}}x_{i,j} + (1-y_i)x_{i,j} \right),
\end{aligned}
```
where ``x_{i,j}`` is the ``j``-th component of ``x_i``. The second partial derivative amounts to
```math
\frac{\partial^2 L}{\partial w_j \partial w_k}(w) = \frac1n\sum_{i=1}^n \frac{1}{(1+e^{w^\top x_i})^2}e^{w^\top x_i}x_{i,j}x_{i,k} = \frac1n\sum_{i=1}^n \hat y_i(1-\hat y_i)x_{i,j}x_{i,k}.
```
Now we will write it in a more compact notation. We have
```math
\begin{aligned}
\nabla L(w) &= \frac1n \sum_{i=1}^n \left((\hat y_i-1)x_i + (1-y_i)x_i \right) = \frac1n \sum_{i=1}^n (\hat y_i-y_i)x_i, \\ 
\nabla^2 L(w) &= \frac 1n \sum_{i=1}^n\hat y_i(1-\hat y_i)x_i x_i^\top.
\end{aligned}
```
Note that if the fit is perfect, ``y_i=\hat y_i``, then the Jacobian ``\nabla L(w)`` equals to zero which is precisely the optimality condition.

