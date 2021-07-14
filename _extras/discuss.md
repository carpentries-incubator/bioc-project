---
title: Discussion
---

## Bioconductor and CRAN

> ## Discussion points
>
> - Bioconductor and CRAN are both well-established and popular repositories of R packages.
> - Packages from Bioconductor and CRAN can be installed and used side-by-side.
> - They both involve an initial review of new packages submitted to the repository (though the process is slightly different).
> - CRAN is more general purpose in the scope of packages.
> - Bioconductor is more focused on packages related to the bioinformatics analysis and comprehension of 'omics data.
> - Bioconductor tests packages regularly, even when the code hasn't changed.
> - Bioconductor distinguishes types of packages (e.g., software, annotations, experiments, workflows).
>
{: .callout}

[Bioconductor][bioc-website] and [CRAN][cran-website] are two well-established repositories of R packages that are often compared in terms of practices with regard to package submission, review, and release cycles.

R packages can be obtained and installed from a number of repositories online.
Repositories often have different guidelines and procedures to manage and check the quality of packages that are distributed on their platforms.
This can be a source of great confusion for users, when searching for package and assessing their popularity and reliability before using them.

CRAN tends to host more general-purpose R packages, hosting more than 17,854 packages (July 2021; [source][cran-packages]).

Bioconductor instead focuses on R packages related to bioinformatics tasks and workflows.
Biocondutor distinguishes packages from different types, including 2,042 software packages, 406 experiment data packages, 965 annotation packages, and 29 workflows (July 2021; [source][bioc-packages]).

[bioc-website]: https://bioconductor.org
[cran-website]: https://cran.r-project.org
[cran-packages]: https://cran.r-project.org/web/packages/index.html
[bioc-packages]: https://bioconductor.org/news/bioc_3_13_release/

{% include links.md %}
