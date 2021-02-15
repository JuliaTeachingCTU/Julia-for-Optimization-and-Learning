# [Final project](@id project)

The second course requirement is to hand in a project. Your grade will be based on this project.
- *Deadline*: The project must be submitted before the end of the term.
- *Submission*: Via GitHub classroom. Download a repo (different than the one for homework)  by the procedure is the same as for [homework](@ref homeworks).
- *Structure*: The requirements for the structure are quite strict. The reason is that many students write all code in one script. This may be an ok practice for one-person projects but a horrible practice for team projects.


## Project types

There are two types of projects:
- *Own project*: Select your own project and work on it. The project can be connected with your bachelor or master thesis. 
- *Kaggle project*: [Kaggle](https://www.kaggle.com) is a popular website with public datasets and [competitions](https://www.kaggle.com/competitions). Select one competition and participate in it.


## Instructions for project

For both project types, certain requirements need to be satisfied. Download the `PkgTemplates` package and create a project in the empty repository by
```julia
julia> using PkgTemplates
```
then pressing `]` and generating the empty project by 
```julia
(project) pkg> generate FinalProject
```
The new project will have the following structure:
```
.
├── Project.toml
└── src
    └── FinalProject.jl
```
The file `Project.toml` includes the used packages, and the folder `src` includes the source code. Now manually add file `README.md` and folders `report`, `scripts` and `tests`. If you need, you can add additional folders.

The project *must* satisfy the following structural requirements:
- The content must be significant. It is not sufficient to choose a Kaggle competition and use a package to process data and run a classifier.
- The package needs to have the structure above.
- The file `README.md` should contain a brief description of the repository. It is written in [Markdown](https://www.markdownguide.org/getting-started/).
- The folder `report` should contain a report with key findings.
- The folder `src` should contain all source code. Individual functions should be grouped into files based on similar functionality.
- The folder `tests` should contain unit tests. 

The project *should* satisfy the following content requirements:
- A comparison with some baseline should be included. In the context of Kaggle competitions, the baseline can be logistic regression.
- An [ablation study](https://en.wikipedia.org/wiki/Ablation_(artificial_intelligence)) should be included. Usually, an algorithm consists of multiple steps, some of which can be removed. Ablation study says how performance changes when individual parts are removed. It is possible to present negative results: ideas which could work but turned out not to work. In these cases, some insight into why these ideas did not work should be presented.
