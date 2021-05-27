# Introduction to regression and classification

Regression and classification are a part of machine learning which predicts certain variables based on labelled data. Both regression and classification operate on several premises:
- We differentiate between datapoints ``x`` and labels ``y``. While data points are relatively simple to obtain, labels ``y`` are relatively hard to obtain.
- We consider some parameterized function ``\operatorname{predict}(w;x)`` and try to find an unknown variable ``w`` to correctly predict the labels from samples (data points)
```math
\operatorname{predict}(w;x) \approx y.
``` 
- We have a labelled datasets with ``n`` samples ``x_1,\dots,x_n`` and labels ``y_1,\dots,y_n``.
- We use the labelled dataset to train the weights ``w``.
- When an unlabelled sample arrives, we use the prediction function to predict its label.

The [MNIST](https://en.wikipedia.org/wiki/MNIST_database) dataset contains ``n=50000`` images of grayscale digits. Each image ``x_i`` from the dataset has the size ``28\times 28`` and was manually labelled by ``y_i\in\{0,\dots,9\}``. When the weights ``w`` of a prediction function ``\operatorname{predict}(w;x)`` are trained on this dataset, the prediction function can predict which digit appears on images it has- never seen before. This is an example where the images ``x`` are relatively simple to obtain, but the labels ``y`` are hard to obtain due to the need to do it manually.


## Regression and classification

The difference between regression and classification is simple:
- Regression predicts a continuous variable ``y`` (such as height based on weight).
- Classification predict a variable ``y`` with a finite number of states (such as cat/dog/none from images).

The body-mass index is used to measure fitness. It has a simple formula
```math
\operatorname{BMI} = \frac{w}{h^2},
```
where ``w`` is the weight and ``h`` is the height. If we do not know the formula, we may estimate it from data. We denote ``x=(w,h)`` the samples and ``y=\operatorname{BMI}`` the labels. Then *regression* considers the following data.

| ``x^1``   | ``x^2``           | ``y``                              |
| :--        | :--            | :--                                      |
| 94    | 1.8    | 29.0                        |
| 50    | 1.59   | 19.8                     |
| 70  | 1.7          | 24.2                  |
| 110    | 1.7         | 38.1                        |

The upper index denotes components while the lower index denotes samples. Sometimes it is not necessary to determine the exact BMI value but only whether a person is healthy, which is defined as any BMI value in the interval ``[18.5, 25]``. When we assign label ``0`` to underweight people, label ``1`` to normal people and label ``2`` to overweight people, then *classification* considers the following data.

| ``x^1``   | ``x^2``           | ``y``                              |
| :--        | :--            | :--                                      |
| 94    | 1.8    | 2                        |
| 50    | 1.59   | 1                     |
| 70  | 1.7          | 1                  |
| 110    | 1.7         | 2                        |


## Mathematical formulation

Recall that the samples are denoted ``x_i`` while the labels ``y_i``. Having ``n`` datapoints in the dataset, the training procedure finds weights ``w`` by solving
```math
\operatorname{minimize}_w\qquad \frac 1n \sum_{i=1}^n\operatorname{loss}\big(y_i, \operatorname{predict}(w;x_i)\big).
```
This minimizes the average discrepancy between labels and predictions. We need to specify the prediction function ``\operatorname{predict}`` and the loss function ``\operatorname{loss}``. This lecture considers linear predictions
```math
\operatorname{predict}(w;x) = w^\top x,
```
while non-linear predictions are considered in the following lecture.


```@raw html
<div class="admonition is-info">
<header class="admonition-header">Linear classifiers</header>
<div class="admonition-body">
```
We realize that
```math
w^\top x + b = (w, b)^\top \begin{pmatrix}x \\ 1\end{pmatrix}.
```
That means that if we add ``1`` to each sample ``x_i``, it is sufficient to consider the classifier in the form ``w^\top x`` without the bias (shift, intercept) ``b``. This allows for simpler implementation.
```@raw html
</div></div>
```



```@raw html
<div class="admonition is-compat">
<header class="admonition-header">BONUS: Data transformation</header>
<div class="admonition-body">
```
Linear models have many advantages, such as simplicity or guaranteed convergence for optimization methods. Sometimes it is possible to transform non-linear dependences into linear ones. For example, the body-mass index
```math
\operatorname{BMI} = \frac{w}{h^2}
```
is equivalent to the linear dependence
```math
\log \operatorname{BMI} = \log w - 2\log h
```
in logarithmic variables. We show the same table as for regression but with logarithmic variable values.

| ``\log x^1``   | ``\log x^2``           | ``\log y``                              |
| :--        | :--            | :--                                      |
| 4.54    | 0.59    | 3.37                        |
| 3.91    | 0.46   | 2.99                    |
| 4.25  | 0.53          | 3.19                  |
| 4.25    | 0.53         | 3.64                        |

It is not difficult to see the simple linear relation with coefficients ``1`` and ``-2``, namely ``\log y = \log x^1 - 2\log x^2.``
```@raw html
</div></div>
```
