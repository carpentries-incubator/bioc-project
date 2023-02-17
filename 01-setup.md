---
source: Rmd
title: Introduction and setup
teaching: XX
exercises: XX
---



::::::::::::::::::::::::::::::::::::::: objectives

- Ensure that participants are using the correct version of R to reproduce exactly the contents of this lesson.
- Download the example files for this lesson.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- Am I using the correct version of R for this lesson?
- Why does my version of R matter?
- How do I obtain the files that are used in this lesson?

::::::::::::::::::::::::::::::::::::::::::::::::::

## Version of R

This lesson was developed and tested with R version 4.2.2 Patched (2022-11-10 r83330).

Take a moment to launch RStudio and verify that you are using R version `4.1.x`, with `x` being any patch version, e.g. `4.1.2`.


```r
R.version.string
```

```{.output}
[1] "R version 4.2.2 Patched (2022-11-10 r83330)"
```

This is important because Bioconductor uses the version of R running in the current session to determine the version of Bioconductor packages that can be installed in the R library associated with the current R session.
Using a different version of R while following this lesson may lead to unexpected results.

## Download files

Several episodes in this lesson rely on example files that participants need to download.

Run the code below programmatically create a folder called `data` in the current working directory, and download the lesson files in that folder.


```r
dir.create("data", showWarnings = FALSE)
download.file(
    url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/master/data/TrimmomaticAdapters/TruSeq3-PE-2.fa", 
    destfile = "data/TruSeq3-PE-2.fa"
)
download.file(
    url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/master/data/ActbGtf/actb.gtf", 
    destfile = "data/actb.gtf"
)
download.file(
    url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/master/data/ActbOrf/actb_orfs.fasta", 
    destfile = "data/actb_orfs.fasta"
)
```

:::::::::::::::::::::::::::::::::::::::::  callout

## Note

Ideally, participants might want to create a new [RStudio project][external-rstudio-project] and download the lesson files in a sub-directory of that project.

Using an RStudio project sets the working directory to the root directory of that project.
As a consequence, code is executed relative to that root directory, often avoiding the need for using absolute file paths to import/export data from/to files.


::::::::::::::::::::::::::::::::::::::::::::::::::

[external-rstudio-project]: https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects


:::::::::::::::::::::::::::::::::::::::: keypoints

- Participants will only be able to install the version of Bioconductor packages described in this lesson and reproduce their exact outputs if they use the correct version of R.
- The files used in this lesson should be downloaded in a local path that is easily accessible from an R session.

::::::::::::::::::::::::::::::::::::::::::::::::::


