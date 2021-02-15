# [Homeworks](@id homeworks)

A course requirement is to hand in three homework successfully. Each homework is a small project that should not take more than one hour.
- *Deadline*: The homework must be submitted before the beginning of the examination period.
- *Submission*: Via GitHub classroom (more instructions below). Submissions via email will be ignored.


## GitHub classroom

To submit the homework, check MS Teams for an invitation to the [Github classroom](https://classroom.github.com/). Accept the invitation and refresh the page. This will create your repo
```
https://github.com/JuliaTeachingCTU/homeworks-sadda
```
where `sadda` is replaced with your Github username. Clone the repository, write the homework and commit it back to Github. We will be able to download it. 


## Instructions for homework

All three homework are connected with optimization and machine learning, and they sightly extend the topics from the corresponding lectures.
- [Homework 1](@ref l7-exercises) is a simple implementation of Newton's method. 
- [Homework 2](@ref l8-exercises) analyzes linear and logistic regression. Students should write a summary report.
- [Homework 3](@ref l9-exercises) analyzes neural networks. Students should write a summary report.

Try to follow basic procedures such as
- Your results should be reproducible by running `homework.jl`.
- If you use many small functions, it may be a good idea to `include` them in a separate file.
- Use comments `#` to briefly describe the code.
- For Homeworks 2 and 3, write the summary into `report/homework.pdf`. Even though the report is important, it should be clear how these results were obtained from running `homework.jl`.
- Add packages should be installed properly via
  ```julia
  (homework_01) pkg> add LinearAlgebra 
  ```
