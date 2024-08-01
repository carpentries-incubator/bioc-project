---
source: Rmd
title: The SummarizedExperiment class
teaching: XX
exercises: XX
---

---



::::::::::::::::::::::::::::::::::::::: objectives

- Describe how both experimental data and metadata can be stored in a single object.
- Explain why this is crucial to keep data and metadata synchronised throughout analyses.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- How is information organized in SummarizedExperiment objects?
- How can that information be added, edited, and accessed?

::::::::::::::::::::::::::::::::::::::::::::::::::





## Install packages

Before we can proceed into the following sections, we install some Bioconductor
packages that we will need.
First, we check that the *[BiocManager](https://bioconductor.org/packages/3.19/BiocManager)* package is
installed before trying to use it; otherwise we install it.
Then we use the `BiocManager::install()` function to install the necessary
packages.


``` r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(c("SummarizedExperiment"))
```

## Motivation

Experiments are multifaceted data sets typically composed of at least two key
pieces of information necessary for any analysis:

- Assay data, typically a matrix representing measurements of a set of features
  in a set of samples
  (e.g., RNA-sequencing).
- Sample metadata, typically a `data.frame` of metadata representing information
  about samples
  (e.g., treatment group).

All those pieces of information must be kept synchronised -- same samples,
same order -- for downstream analyses to accurately process the information
and produce reliable results.

It is also very common for analytical workflows to analyse subsets of samples or
identify outliers that need to be removed to allow for more accurate downstream
analyses.
In such cases, all aspects of the experiments must be subsetted to the same set
of samples -- in the same order -- to preserve consistency in the data set
and correct results.

The `SummarizedExperiment` -- implemented in the
*[SummarizedExperiment](https://bioconductor.org/packages/3.19/SummarizedExperiment)* package -- provides a container
that accommodates those essential aspects of individual experiments into a
single object coordinates data and metadata during subsetting and reordering
operations.
Its flexibility accommodating many biological data types
and comprehensive set of features make it a popular data
structure re-used throughout the Bioconductor and a key part of the Bioconductor
ecosystem.
For instance, familiarity with the `SummarizedExperiment` is a prerequisite
for working with the *[DESeq2](https://bioconductor.org/packages/3.19/DESeq2)* package for differential
expression analysis, and the *[SingleCellExperiment](https://bioconductor.org/packages/3.19/SingleCellExperiment)*
extension class for single-cell analyses.

## Class structure

`SummarizedExperiment` is a matrix-like container where rows represent features of
interest (e.g. genes, transcripts, exons, etc.) and columns represent samples.

The objects can contain one or more assays, each represented by a matrix-like
object, as long as they be of the same dimensions.

Information about the features is stored in a `DataFrame` object,
nested within the `SummarizedExperiment` object,
and accessible using the function `rowData()`.
Each row of the `DataFrame` provides information on the feature in the
corresponding row of the SummarizedExperiment object.
That information may include annotations independent of the experiment
(e.g., gene identifier) as well as quality control metrics computed from
assay data during workflows.

Similarly, information about the samples is stored in another `DataFrame` object,
also nested within the `SummarizedExperiment` object,
and accessible using the function `colData()`.

The following graphic displays the class geometry and highlights the
vertical (column) and horizontal (row) relationships.
It was obtained from the vignette of the
*[SummarizedExperiment](https://bioconductor.org/packages/3.19/SummarizedExperiment)* package.

![](fig/summarizedexperiment.svg){alt='Schematic representation of the SummarizedExperiment class.'}

## Creating a SummarizedExperiment object

Let us first load the package:


``` r
library(SummarizedExperiment)
```

Then, let us import assay data from a file that we downloaded during the lesson
setup.

The file is a simple text file in which
the first column contains made-up feature identifiers
and all other columns contain simulated data for made-up samples.
As such, we can use the base R function `read.csv` to parse the file
into a `data.frame` object.

In the example below, we indicate that the row names can be found in the first
column, so that the function immediately sets the row names accordingly
in the output object.
Hadn't we specified it, the function would have parsed it as a regular column
and left the row names to the default integer indexing.


``` r
count_data <- read.csv("data/counts.csv", row.names = 1)
```

``` warning
Warning in file(file, "rt"): cannot open file 'data/counts.csv': No such file
or directory
```

``` error
Error in file(file, "rt"): cannot open the connection
```

``` r
count_data
```

``` error
Error in eval(expr, envir, enclos): object 'count_data' not found
```

One assay data matrix is enough to create a `SummarizedExperiment` object,
although without sample metadata, only unsupervised analyses -- that do not
require information about the samples -- are possible.

In the example below, we create a `SummarizedExperiment` object in which we
store the matrix of count data under the name 'counts'.
Note that the argument 'assays=' (plural) can accept more than one assay
-- as discussed above -- which is why we encapsulate our only assay matrix
in a named `list` that also gives us the opportunity to assign a name to the
assay.
Naming assays becomes crucial during workflows that contain multiple assays,
in order to identify and retrieve individual assays unambiguously.


``` r
se <- SummarizedExperiment(
  assays = list(counts = count_data)
)
```

``` error
Error in eval(expr, envir, enclos): object 'count_data' not found
```

``` r
se
```

``` error
Error in eval(expr, envir, enclos): object 'se' not found
```

In the output above, the summary view of the object reminds us that the assay
-- and thus the overall `SummarizedExperiment` object -- contains information
for 25 features in 4 samples,
it contains a single assay named 'counts',
the features seem to be named from 'gene_1' to 'gene_25'
(only the first and last ones are shown),
and the samples are named from `sample_1` to `sample_4`.
The object does not contain any row metadata nor column metadata.

To create a more comprehensive `SummarizedExperiment` object,
let us import gene metadata and sample metadata for another two files 
that we downloaded during the lesson setup.

The files are formatted similarly to the count data,
so we use again the base R function `read.csv()` to parse them into `data.frame`
objects.


``` r
sample_metadata <- read.csv("data/sample_metadata.csv", row.names = 1)
```

``` warning
Warning in file(file, "rt"): cannot open file 'data/sample_metadata.csv': No
such file or directory
```

``` error
Error in file(file, "rt"): cannot open the connection
```

``` r
sample_metadata
```

``` error
Error in eval(expr, envir, enclos): object 'sample_metadata' not found
```


``` r
gene_metadata <- read.csv("data/gene_metadata.csv", row.names = 1)
```

``` warning
Warning in file(file, "rt"): cannot open file 'data/gene_metadata.csv': No such
file or directory
```

``` error
Error in file(file, "rt"): cannot open the connection
```

``` r
gene_metadata
```

``` error
Error in eval(expr, envir, enclos): object 'gene_metadata' not found
```

We can re-create the `SummarizedExperiment` object, this time including
the gene and sample metadata:


``` r
se <- SummarizedExperiment(
  assays = list(counts = count_data),
  colData = sample_metadata,
  rowData = gene_metadata
)
```

``` error
Error in eval(expr, envir, enclos): object 'count_data' not found
```

``` r
se
```

``` error
Error in eval(expr, envir, enclos): object 'se' not found
```

Comparing the output above with the previous 'assay-only' version of the
`SummarizedExperiment` object, we can see that the `rowData` and `colData`
components now contain 1 and 4 metadata, respectively.

## Accessing information

A number of functions give access to the various components of
`SummarizedExperiment` objects.

The `assays()` function returns the list of assays stored in the object.
The output is always a `List`, event if the object contains a single assay.


``` r
assays(se)
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'assays': object 'se' not found
```

The `assayNames()` function returns a character vector of the assay names.
This is most useful when the object contains larger numbers of assays,
as the `assays()` function (see above) may not display all of them.
Knowing the names of the various assays is key to accessing any individual
assay.


``` r
assayNames(se)
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'assayNames': object 'se' not found
```

The `assay()` function can be used to retrieve a single assay from the object.
For this, the function should be given the name or the integer position of the
desired assay.
If unspecified, the function automatically returns the first assay in the
object.


``` r
head(assay(se, "counts"))
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'head': error in evaluating the argument 'x' in selecting a method for function 'assay': object 'se' not found
```

The `colData()` and `rowData()` functions can be used to retrieve 
sample metadata and row metadata, respectively.


``` r
colData(se)
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'colData': object 'se' not found
```


``` r
rowData(se)
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rowData': object 'se' not found
```

Separately, the `$` operator can be used to access a single column of sample
metadata.
A useful feature of this operator is the autocompletion that is triggered
automatically in RStudio or using the tabulation key in terminal applications.


``` r
se$batch
```

``` error
Error in eval(expr, envir, enclos): object 'se' not found
```

Notably, there is no operator for accessing a single column of feature metadata.
For this, users need to first access the full `DataFrame` returned by
`rowData()` before accessing a column using the standard `$` or `[[` operators,
e.g.


``` r
rowData(se)[["chromosome"]]
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rowData': object 'se' not found
```

### Adding and editing information

Information can be added to `SummarizedExperiment` after their creation.
In fact, this is the basis for workflows that compute normalised assay values --
adding those to the list of assays --, and
quality control metrics for either features or samples -- adding those to the
`rowData` and `colData` components, as appropriate -- progressively growing
the amount of information stored within the overall object.

Most of the functions for accessing information, described in the previous
section, have a counterpart function for adding new values or editing existing
ones.
Note that editing is merely the result of adding values under a name already in
use, which has the effect of replacing existing values.

In the example below, we add an assay named 'logcounts' which is the result
of applying a log-transformation to the 'counts' assay after adding a
pseucocount of one:


``` r
assay(se, "logcounts") <- log1p(assay(se, "counts"))
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'assay': object 'se' not found
```

``` r
se
```

``` error
Error in eval(expr, envir, enclos): object 'se' not found
```

In the output above, we see that the object now contains two assays:
the 'counts' assay included in the object when it was first created,
and the 'logcounts' assay added just now.

Similarly, the `colData()` and `rowData()` functions -- as well as the `$`
operator -- can be used to add and edit values in the corresponding components.

In the example below, we compute the sum of counts for each sample,
and store the result in the sample metadata table under the new name
'sum_counts'.


``` r
colData(se)[["sum_counts"]] <- colSums(assay(se, "counts"))
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'colSums': error in evaluating the argument 'x' in selecting a method for function 'assay': object 'se' not found
```

``` r
colData(se)
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'colData': object 'se' not found
```

In this next example, we compute the average count for each feature,
and store the result in the feature metadata table under the new name
'mean_counts'.


``` r
rowData(se)[["mean_counts"]] <- rowSums(assay(se, "counts"))
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rowSums': error in evaluating the argument 'x' in selecting a method for function 'assay': object 'se' not found
```

``` r
rowData(se)
```

``` error
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'rowData': object 'se' not found
```

:::::::::::::::::::::::::::::::::::::::: keypoints

- The `SummarizedExperiment` class provides a single container for storing both
  assay data and metadata.
- Assay data and metadata are kept synchronised through subsetting and
  reordering operations.
- A comprehensive set of functions are available to access, add, and edit
  information stored in the various components of the `SummarizedExperiment`
  objects.

::::::::::::::::::::::::::::::::::::::::::::::::::
[biocviews]: https://www.bioconductor.org/packages/release/BiocViews.html
[biomart-ensembl]: https://www.ensembl.org/biomart/martview
