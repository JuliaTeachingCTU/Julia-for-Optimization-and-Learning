# [Final project](@id project)

The course second requirement is to hand in a project. Your grade will be based on this project.
- *Deadline*: The project must be submitted before the end of the examination period.
- *Submission*: Via GitHub classroom. Download a repo (different than the one for homework) by the same procedure as for [homework](@ref homeworks).
- *Structure*: The requirements for the structure are quite strict. The reason is that many students write all code in one script. This may be an ok practice for one-person projects but a horrible practice for team projects.


## Project types

There are two types of projects:
- *Own project*: Select your own project and work on it. The project can be connected with your bachelor or master thesis.
- *Kaggle project*: [Kaggle](https://www.kaggle.com) is a popular website with public datasets and [competitions](https://www.kaggle.com/competitions). Select one competition and participate in it.
Unless otherwise stated, each student works on a separate project.

## Kaggle projects

There are four possible competitions to participate in.

- [Facial Keypoints Detection](https://www.kaggle.com/c/facial-keypoints-detection) predict keypoint positions on face images of 96x96 pixels.
- [Titanic](https://www.kaggle.com/c/titanic) predict whether a passenger survived the sinking of Titanic based on personal data.
- [iWildcam 2021 - FGVC8](https://www.kaggle.com/c/iwildcam2021-fgvc8) is a *tough* large dataset to recognize animals in camera trap photos.
- [Herbarium 2021 - Half-Earth Challenge - FGVC8](https://www.kaggle.com/c/herbarium-2021-fgvc8) is a *tough* large dataset to recognize plant species in photos.

The first two datasets are recommended for most course participants. There are no restrictions on how to proceed. You can try both traditional techniques or neural networks. If you do not know what to do, check highly rated solutions in the competition `Code` tab.

The last two datasets are for those who are up to a challenge. Form a group of up to three people and amaze us with your skills. These two datasets contain around 100GB of data; we should be able to provide you with access to a server with GPUs.

If you have a particular reason to select any other competition, write us an email.


## Instructions for projects

For both project types, the package structure should roughly correspond to the [ImageInspector](@ref development) structure. We created a [Github repository](https://github.com/JuliaTeachingCTU/ImageInspector.jl) with this package as a sample submission.

The project *must* satisfy the following structural requirements:
- The content must be significant. It is not sufficient to choose a Kaggle competition and use a package to process data and run a classifier.
- The package root folder must contain `LICENSE`, `Project.toml` and `README.md` with a brief description of the repository written in [Markdown](https://www.markdownguide.org/getting-started/). Including `.gitignore` is recommended but not required.
- The folder `report` should contain a report with key findings. We recommend generating it by the [Literate](https://fredrikekre.github.io/Literate.jl/v2/) package, but uploading a pdf file is also acceptable.
- The folder `scripts` should contain scripts with examples for running the package.
- The folder `src` should contain all source code. Individual functions should be grouped into files based on similar functionality.
- The folder `tests` should contain unit tests.
Additional folders can be added.

The project *should* satisfy the following content requirements:
- A comparison with some baseline should be included. In the context of Kaggle competitions, the baseline can be logistic regression.
- An [ablation study](https://en.wikipedia.org/wiki/Ablation_(artificial_intelligence)) should be included. Usually, an algorithm consists of multiple steps, some of which can be removed. Ablation study says how performance changes when individual parts are removed. It is possible to present negative results: ideas that could work but turned out not to work. In these cases, some insight into why these ideas did not work should be presented.
