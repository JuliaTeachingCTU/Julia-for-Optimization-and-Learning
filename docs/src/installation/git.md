# Git

[Git](https://git-scm.com/) is a distributed version-control system for tracking changes in any set of files, designed for coordinating work among programmers cooperating on source code during software development. The whole Julia package system is based on git and the whole Julia project is hosted on [GitHub](https://github.com/) which providers Internet hosting for software development and version control using Git. In this section, we provide a basic tutorial on how to install and set git on Windows 10

Git installer can be download from the official [download page](https://git-scm.com/downloads).

![](gitinstall_1.png)

Download the proper installer, run it and follow the given instructions

![](gitinstall_2.png)

There is no need to change the default settings. However, we recommend changing the default editor used by Git to Visual Studio Code.

![](gitinstall_3.png)

After setting the editor used by Git, finish the installation with default settings.

```@raw html
<div class = "info-body">
<header class = "info-header">GitHub Account</header><p>
```

Create a GitHub account on the official [GitHub page](https://github.com/). Do not forget to verify your email address.

```@raw html
</p></div>
```

## User settings

Before using Git, we need to make basic settings. Type `cmd` into the search bar and open the `Command Prompt`.

![](juliapath_7.png)

In the `Command Prompt` type the following two commands

> `git config --global user.name "USERNAME"`
>
> `git config --global user.email "USEREMAIL"`

and press `Enter`. Do not forget to change `USERNAME` and `USEREMAIL`. Typically the username and email from GitHub are used.

![](gitsettings_1.png)

The commands above set the user name and email for Git. Because Git is designed for collaboration between multiple people, this information is used to track who made what changes.
