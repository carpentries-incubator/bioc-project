---
title: Setup
---

Ensure that you have the most recent versions of R and RStudio installed on your computer. 
For detailed instructions on how to do this, you can refer to the section "If you already have R and RStudio installed" 
in the [Introduction to R](https://carpentries-incubator.github.io/bioc-intro/#r-and-rstudio)
episode of the [Introduction to data analysis with R and Bioconductor](https://carpentries-incubator.github.io/bioc-intro) lesson.

Additionally, you will also need to install the following packages that will be used throughout the lesson. 

```r
install.packages(c("BiocManager", "remotes"))
BiocManager::install(c(
  "S4Vectors", "Biostrings", "BSgenome", "BSgenome.Hsapiens.UCSC.hg38.masked",
  "GenomicRanges", "rtracklayer", "biomaRt"))
```

*If you are attending a workshop, please complete all of the above before the workshop. Should you need help, an instructor will be available 30 minutes before the workshop commences to assist.*
