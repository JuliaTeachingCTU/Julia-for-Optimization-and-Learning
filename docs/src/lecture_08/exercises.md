# Exercises

```@raw html
<div class = "homework-body">
<header class = "homework-header">Homework: ???</header><p>
```
???
```@raw html
</p></div>
```   





```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1</header><p>
```
Show the details for the derivation of the logistic regression.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Since ``\hat y`` equals the probability of predicting ``1``, we have
```math
\hat y = \frac{1}{1+e^{-w^\top x}}
``` 
Then the cross-entropy loss reduces to
```math
\begin{aligned}
\operatorname{loss}(y,\hat y) &= - y\log \hat y - (1-y)\log(1-\hat y) \\
&= y\log(1+e^{-w^\top x}) - (1-y)\log(e^{-w^\top x}) + (1-y)\log(1+e^{-w^\top x}) \\
&= \log(1+e^{-w^\top x}) + (1-y)w^\top x.
\end{aligned}
```
Then it remains to sum this term over all samples.
```@raw html
</p></details>
```







```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1</header><p>
```
Show that if the Newton's method converge for the logistic regression, then it found a point globally minimizing the logistic loss. 
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Since ``\hat y`` equals the probability of predicting ``1``, we have
```math
\hat y = \frac{1}{1+e^{-w^\top x}}
``` 
Then the cross-entropy loss reduces to
```math
\begin{aligned}
\operatorname{loss}(y,\hat y) &= - y\log \hat y - (1-y)\log(1-\hat y) \\
&= y\log(1+e^{-w^\top x}) - (1-y)\log(e^{-w^\top x}) + (1-y)\log(1+e^{-w^\top x}) \\
&= \log(1+e^{-w^\top x}) + (1-y)w^\top x.
\end{aligned}
```
Then it remains to sum this term over all samples.
```@raw html
</p></details>
```




LOGISTIC REGRESSION FAIL FROM A DIFFERENT POINT