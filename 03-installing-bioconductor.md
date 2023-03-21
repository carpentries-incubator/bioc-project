---
source: Rmd
title: Installing Bioconductor packages
teaching: XX
exercises: XX
---



::::::::::::::::::::::::::::::::::::::: objectives

- Install BiocManager.
- Install Bioconductor packages.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- How do I install Bioconductor packages?
- How do I check if newer versions of my installed packages are available?
- How do I update Bioconductor packages?
- How do I find out the name of packages available from the Bioconductor repositories?

::::::::::::::::::::::::::::::::::::::::::::::::::

## BiocManager

The *[BiocManager](https://bioconductor.org/packages/3.16/BiocManager)* package is the entry point into the Bioconductor package repository.
Technically, this is the only Bioconductor package distributed on the CRAN repository.

It provides functions to safely install Bioconductor packages and check for available updates.

Once the package is installed, the function `BiocManager::install()` can be used to install packages from the Bioconductor repository.
The function is also capable of installing packages from other repositories (e.g., CRAN), if those packages are not found in the Bioconductor repository first.

![](fig/bioc-install.svg){alt='The package BiocManager is available from the CRAN repository and used to install packages from the Bioconductor repository.'}

**The package BiocManager is available from the CRAN repository and used to install packages from the Bioconductor repository.**
The function `install.packages()` from the base R package `utils` can be used to install the *[BiocManager](https://bioconductor.org/packages/3.16/BiocManager)* package distributed on the CRAN repository.
In turn, the function `BiocManager::install()` can be used to install packages available on the Bioconductor repository.
Notably, the `BiocManager::install()` function will fall back on the CRAN repository if a package cannot be found in the Bioconductor repository.

Install the package using the code below.


```r
install.packages("BiocManager")
```

```output
trying URL 'https://cran.rstudio.com/bin/macosx/contrib/4.1/BiocManager_1.30.16.tgz'
Content type 'application/x-gzip' length 322920 bytes (315 KB)
==================================================
downloaded 315 KB


The downloaded binary packages are in
	/var/folders/51/nz__2dx10yzd75rylr5cg2zc0000gq/T//RtmpeS8MHV/downloaded_packages
```

:::::::::::::::::::::::::::::::::::::::::  callout

### Going further

A number of packages that are not part of the base R installation also provide functions to install packages from various repositories.
For instance:

- `devtools::install()`
- `remotes::install_bioc()`
- `remotes::install_bitbucket()`
- `remotes::install_cran()`
- `remotes::install_dev()`
- `remotes::install_github()`
- `remotes::install_gitlab()`
- `remotes::install_git()`
- `remotes::install_local()`
- `remotes::install_svn()`
- `remotes::install_url()`
- `renv::install()`

Those functions are beyond the scope of this lesson, and should be used with caution and adequate knowledge of their specific behaviors.
The general recommendation is to use `BiocManager::install()` over any other installation mechanism because it ensures proper versioning of Bioconductor packages.


::::::::::::::::::::::::::::::::::::::::::::::::::

## Bioconductor releases and current version

Once the *[BiocManager](https://bioconductor.org/packages/3.16/BiocManager)* package is installed, the `BiocManager::version()` function displays the version (i.e., release) of the Bioconductor project that is currently active in the R session.


```r
BiocManager::version()
```

```{.output}
[1] '3.16'
```

Using the correct version of R and Bioconductor packages is a key aspect of reproducibility.
The *[BiocManager](https://bioconductor.org/packages/3.16/BiocManager)* packages uses the version of R running in the current session to determine the version of Biocondutor packages that can be installed in the current R library.

The Bioconductor project produces two releases each year, one around April and another one around October.
The April release of Bioconductor coincides with the annual release of R.
The October release of Bioconductor continues to use the same version of R for that annual cycle (i.e., until the next release, in April).

![](fig/bioc-release-cycle.svg){alt='Timeline of release dates for selected Bioconductor and R versions.'}

**Timeline of release dates for selected Bioconductor and R versions.**
The upper section of the timeline indicates versions and approximate release dates for the R project.
The lower section of the timeline indicates versions and release dates for the Bioconductor project.
Source: [Bioconductor][bioc-release-dates].

During each 6-month cycle of package development, Bioconductor tests packages for compatibility with the version of R that will be available for the next release cycle.
Then, each time a new Bioconductor release is produced, the version of every package in the Bioconductor repository is incremented, including the package *[BiocVersion](https://bioconductor.org/packages/3.16/BiocVersion)* which determines the version of the Bioconductor project.


```r
packageVersion("BiocVersion")
```

```{.error}
Error in packageVersion("BiocVersion"): there is no package called 'BiocVersion'
```

This is the case for every package, even those which have not been updated at all since the previous release.
That new version of each package is earmarked for the corresponding version of R;
in other words, that version of the package can only be installed and accessed in an R session that uses the correct version of R.
This version increment is essential to associate a each version of a Bioconductor package with a unique release of the Bioconductor project.

Following the April release, this means that users must install the new version of R to access the newly released versions of Bioconductor packages.

Instead, in October, users can continue to use the same version of R to access the newly released version of Bioconductor packages.
However, to update an R library from the April release to the October release of Bioconductor, users need to call the function `BiocManager::install()` specifying the correct version of Bioconductor as the `version` option, for instance:


```r
BiocManager::install(version = "3.14")
```

This needs to be done only once, as the *[BiocVersion](https://bioconductor.org/packages/3.16/BiocVersion)* package will be updated to the corresponding version, indicating the version of Bioconductor in use in this R library.

:::::::::::::::::::::::::::::::::::::::::  callout

### Going further

The [Discussion][discuss-release-cycle] article of this lesson includes a section discussing the release cycle of the Bioconductor project.

::::::::::::::::::::::::::::::::::::::::::::::::::

## Check for updates

The `BiocManager::valid()` function inspects the version of packages currently installed in the user library, and checks whether a new version is available for any of them on the Bioconductor repository.

If everything is up-to-date, the function will simply print `TRUE`.


```r
BiocManager::valid()
```

```{.warning}
Warning: 14 packages out-of-date; 0 packages too new
```

```{.output}

* sessionInfo()

R version 4.2.2 Patched (2022-11-10 r83330)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 22.04.2 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.10.0
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.10.0

locale:
 [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
 [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
 [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
[10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] BiocStyle_2.26.0

loaded via a namespace (and not attached):
 [1] BiocManager_1.30.19 compiler_4.2.2      fastmap_1.1.0      
 [4] cli_3.6.0           htmltools_0.5.4     tools_4.2.2        
 [7] yaml_2.3.7          rmarkdown_2.20      knitr_1.42         
[10] digest_0.6.31       xfun_0.37           rlang_1.0.6        
[13] renv_0.17.2         evaluate_0.20      

Bioconductor version '3.16'

  * 14 packages out-of-date
  * 0 packages too new

create a valid installation with

  BiocManager::install(c(
    "BiocManager", "BiocParallel", "bookdown", "cachem", "fastmap", "fs",
    "GenomicAlignments", "httr", "openssl", "renv", "rlang", "S4Vectors",
    "vctrs", "XML"
  ), update = TRUE, ask = FALSE, force = TRUE)

more details: BiocManager::valid()$too_new, BiocManager::valid()$out_of_date
```

Conveniently, if any package can be updated, the function generates and displays the command needed to update those packages.
Users simply need to copy-paste and run that command in their R console.

:::::::::::::::::::::::::::::::::::::::::  callout

### Example of out-of-date package library

In the example below, the `BiocManager::valid()` function did not return `TRUE`.
Instead, it includes information about the active user session, and displays the exact call to `BiocManager::install()` that the user should run to replace all the outdated packages detected in the user library with the latest version available in CRAN or Bioconductor.

```
> BiocManager::valid()

* sessionInfo()

R version 4.1.0 (2021-05-18)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS Big Sur 11.6

Matrix products: default
LAPACK: /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRlapack.dylib

locale:
[1] en_GB.UTF-8/en_GB.UTF-8/en_GB.UTF-8/C/en_GB.UTF-8/en_GB.UTF-8

attached base packages:
[1] stats     graphics  grDevices datasets  utils     methods   base     

loaded via a namespace (and not attached):
[1] BiocManager_1.30.16 compiler_4.1.0      tools_4.1.0         renv_0.14.0        

Bioconductor version '3.13'

  * 18 packages out-of-date
  * 0 packages too new

create a valid installation with

  BiocManager::install(c(
    "cpp11", "data.table", "digest", "hms", "knitr", "lifecycle", "matrixStats", "mime", "pillar", "RCurl",
    "readr", "remotes", "S4Vectors", "shiny", "shinyWidgets", "tidyr", "tinytex", "XML"
  ), update = TRUE, ask = FALSE)

more details: BiocManager::valid()$too_new, BiocManager::valid()$out_of_date

Warning message:
18 packages out-of-date; 0 packages too new 
```

Specifically, in this example, the message tells the user to run the following command to bring their installation up to date:

```
  BiocManager::install(c(
    "cpp11", "data.table", "digest", "hms", "knitr", "lifecycle", "matrixStats", "mime", "pillar", "RCurl",
    "readr", "remotes", "S4Vectors", "shiny", "shinyWidgets", "tidyr", "tinytex", "XML"
  ), update = TRUE, ask = FALSE)
```

::::::::::::::::::::::::::::::::::::::::::::::::::

## Exploring the package repository

The Bioconductor [biocViews][glossary-biocviews], demonstrated in the earlier episode [Introduction to Bioconductor][crossref-intro-biocviews], are a great way to discover new packages by thematically browsing the hierarchical classification of Bioconductor packages.

In addition, the `BiocManager::available()` function returns the complete list of package names that are can be intsalled from the Bioconductor and CRAN repositories.
For instance the total number of numbers that could be installed using *[BiocManager](https://bioconductor.org/packages/3.16/BiocManager)*


```r
length(BiocManager::available())
```

```{.output}
[1] 22836
```

Specifically, the current Bioconductor and CRAN repositories can be displayed as follows.


```r
BiocManager::repositories()
```

```{.output}
                                                BioCsoft 
           "https://bioconductor.org/packages/3.16/bioc" 
                                                 BioCann 
"https://bioconductor.org/packages/3.16/data/annotation" 
                                                 BioCexp 
"https://bioconductor.org/packages/3.16/data/experiment" 
                                           BioCworkflows 
      "https://bioconductor.org/packages/3.16/workflows" 
                                               BioCbooks 
          "https://bioconductor.org/packages/3.16/books" 
                                             carpentries 
                    "https://carpentries.r-universe.dev" 
                                     carpentries_archive 
                    "https://carpentries.github.io/drat" 
                                                    CRAN 
                              "https://cran.rstudio.com" 
```

Each repository URL can be accessed in a web browser, displaying the full list of packages available from that repository.
For instance, navigate to [https://bioconductor.org/packages/3.14/bioc](https://bioconductor.org/packages/3.14/bioc).

:::::::::::::::::::::::::::::::::::::::::  callout

### Going further

The function `BiocManager::repositories()` can be combined with the base function `available.packages()` to query packages available specifically from any package repository, e.g. the Bioconductor [software package][glossary-software-package] repository.

```
> db = available.packages(repos = BiocManager::repositories()["BioCsoft"])
> dim(db)
[1] 1948   17
> head(rownames(db))
[1] "a4"          "a4Base"      "a4Classif"   "a4Core"      "a4Preproc"
[6] "a4Reporting"
```

::::::::::::::::::::::::::::::::::::::::::::::::::

Conveniently, `BiocManager::available()` includes a `pattern=` argument, particularly useful to navigate annotation resources (the original use case motivating it).
For instance, a range of [Annotation data packages][glossary-annotation-package] available for the mouse model organism can be listed as follows.


```r
BiocManager::available(pattern = "*Mmusculus")
```

```{.output}
 [1] "BSgenome.Mmusculus.UCSC.mm10"        "BSgenome.Mmusculus.UCSC.mm10.masked"
 [3] "BSgenome.Mmusculus.UCSC.mm39"        "BSgenome.Mmusculus.UCSC.mm8"        
 [5] "BSgenome.Mmusculus.UCSC.mm8.masked"  "BSgenome.Mmusculus.UCSC.mm9"        
 [7] "BSgenome.Mmusculus.UCSC.mm9.masked"  "EnsDb.Mmusculus.v75"                
 [9] "EnsDb.Mmusculus.v79"                 "PWMEnrich.Mmusculus.background"     
[11] "TxDb.Mmusculus.UCSC.mm10.ensGene"    "TxDb.Mmusculus.UCSC.mm10.knownGene" 
[13] "TxDb.Mmusculus.UCSC.mm39.refGene"    "TxDb.Mmusculus.UCSC.mm9.knownGene"  
```

## Installing packages

The `BiocManager::install()` function is used to install or update packages.

The function takes a character vector of package names, and attempts to install them from the Bioconductor repository.


```r
BiocManager::install(c("S4Vectors", "BiocGenerics"))
```

However, if any package cannot be found in the Bioconductor repository, the function also searches for those packages in repositories listed in the global option `repos`.

:::::::::::::::::::::::::::::::::::::::::  callout

### Contribute !

Add an example of non-Bioconductor package that can be installed using BioManager.
Preferably, a package that will be used later in this lesson.


::::::::::::::::::::::::::::::::::::::::::::::::::

## Uninstalling packages

Bioconductor packages can be removed from the R library like any other R package, using the base R function `remove.packages()`.
In essence, this function simply removes installed packages and updates index information as necessary.
As a result, it will not be possible to attach the package to a session or browse the documentation of that package anymore.


```r
remove.packages("S4Vectors")
```

[bioc-release-dates]: https://bioconductor.org/about/release-announcements/
[discuss-release-cycle]: discuss.html#the-bioconductor-release-cycle
[glossary-biocviews]: reference.html#biocviews
[crossref-intro-biocviews]: https://carpentries-incubator.github.io/bioc-project/02-introduction-to-bioconductor/index.html#package-classification-using-biocviews
[glossary-software-package]: reference.html#software-package
[glossary-annotation-package]: reference.html#annotationdata-package


:::::::::::::::::::::::::::::::::::::::: keypoints

- The BiocManager package is available from the CRAN repository.
- `BiocManager::install()` is used to install and update Bioconductor packages (but also from CRAN and GitHub).
- `BiocManager::valid()` is used to check for available package updates.
- `BiocManager::version()` reports the version of Bioconductor currently installed.
- `BiocManager::install()` can also be used to update an entire R library to a specific version of Bioconductor.

::::::::::::::::::::::::::::::::::::::::::::::::::


