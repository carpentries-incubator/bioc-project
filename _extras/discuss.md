---
title: Discussion
---

## Bioconductor and CRAN

[Bioconductor][bioc-website] and [CRAN][cran-website] are two well-established repositories of R packages that are often compared in terms of practices with regard to package submission, review, and release cycles.

R packages can be obtained and installed from a number of repositories online, CRAN and Bioconductor being the two most prominent and well-established repositories.
Repositories often have different guidelines and procedures to manage and check the quality of packages that are distributed on their platforms.
This can be a source of considerable confusion for users, when searching for new packages and assessing their popularity and reliability before investing time in using them.

CRAN tends to host more general-purpose R packages, hosting more than 17,854 packages (July 2021; [source][cran-packages]).
It is also the oldest and main repository of R packages, established in 1997, and initially hosting 12 packages ([reference][cran-first-release]).

Rather, Bioconductor focuses on R packages related to bioinformatics tasks and workflows.
Biocondutor distinguishes packages from different types, including 2,042 software packages, 406 experiment data packages, 965 annotation packages, and 29 workflows (July 2021; [source][bioc-packages]).

Both repositories implement an initial review process for new package submissions.
However, the two review processes operate in noticeably different manners, including in the way packages are evaluated and deprecated after acceptance, as they consistently fail regular automated checks without action from package maintainers.
In particular, the release cycle of the Bioconductor project creates natural opportunities to regularly identify packages that consistently fail automated checks, triggering their deprecation during the following release cycle, and removal in the subsequent one.

Packages from Bioconductor and CRAN can be installed and used side-by-side.
They are all R packages and can often interoperate on standard R structures (e.g., `vector`, `matrix`, `data.frame`).
However, one common issue and challenge stems from the different implementations of S3 and S4 class and generic systems.
For instance, the `r BiocStyle::Biocpkg("AnnotationDbi")` and `r BiocStyle::CRANpkg("dplyr")` packages implement two versions of the `select()` method, using the S4 and S3 system, respectively.
When both packages are attached to the same R session, the `select()` method defined by the first package attached can only be accessed using the full syntax `package::function()` (e.g., `AnnotationDbi::select()`), as the method implemented by the latest package attached masks any other definition of the method in the active R session.
To date, there has been no solution to this issue, relying on users learning from experience to circumvent the issue using the full syntax to access individual methods explicitly.

The Bioconductor project labels and classifies packages using [biocViews][biocviews-site].
This controlled vocabulary provides a convenient solution to effectively browse and filter thematically-related packages.
The CRAN repository does not provide any comparable functionality, instead relying on search engines and word-of-mouth to identify packages suitable for specific tasks.

## Bioconductor package versions

### Format

Bioconductor packages use the standard format `MAJOR.MINOR.PATCH` to version packages (e.g., `1.13.2`).
The version number is stored in the `DESCRIPTION` file that is part of every R package.
Each of `MAJOR`, `MINOR`, and `PATCH` is an integer that is incremented to mark a new release of the corresponding package, following different rules for each field.

### Major version

Candidate packages in development should set the `MAJOR` field to `0` while the package is submitted for review.
When the package is accepted, `MAJOR` is automatically incremented by `1`, to mark its entry into the Bioconductor repository.

Following acceptance, `MAJOR` often remains the same for the lifetime of the package.
It should only be incremented by package developers to mark breaking changes that require the full attention of users who may need to update their workflow accordingly.

However, developers should never update the `MAJOR` field itself.
Instead, they should set `MINOR` to `99`.
During the preparation of the next Bioconductor release, this will automatically trigger an increment of `MAJOR` by `1` and reset `MINOR` to `0`.
For instance, a package at version `0.99.15` during the Bioconductor review process will appear at version `1.0.0` when accepted and added to the next release of the Bioconductor package repository.

### Minor version

The `MINOR` field is automatically updated every 6 months as part of the Bioconductor release process to mark the version of each package that will feature in the upcoming release.
Simultaneously, when the `MINOR` field is incremented for a new release cycle, the `PATCH` field is reset to `0`.
For instance, if a package was at version `1.3.5` for Bioconductor release `3.13`, it would be incremented to version `1.4.0` at the start of Bioconductor release `3.14`.

As described above, developers can set `MINOR` directly to `99` - skipping all values in-between - if they wish to trigger an increment of `MAJOR` for their package in the next release of Bioconductor.

### Patch version

The `PATCH` field is the field that package developers use most frequently to release updates within a release cycle.
Importantly, updates to packages are not deployed to users until the package version is incremented.
This is crucial to ensure that users cannot install different versions of a package that contain different source code.
For instance, a package at version `1.3.5` would be incremented to version `1.3.6` to deploy a new version of the package available to users on the Bioconductor repository.
{: .callout}

[bioc-website]: https://bioconductor.org
[cran-website]: https://cran.r-project.org
[cran-packages]: https://cran.r-project.org/web/packages/index.html
[bioc-packages]: https://bioconductor.org/news/bioc_3_13_release/
[cran-first-release]: https://stat.ethz.ch/pipermail/r-announce/1997/000001.html
[biocviews-site]: https://www.bioconductor.org/packages/release/BiocViews.html

{% include links.md %}
