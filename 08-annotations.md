---
source: Rmd
title: Working with gene annotations
teaching: XX
exercises: XX
---

---



::::::::::::::::::::::::::::::::::::::: objectives

- Explain how gene annotations are managed in the Bioconductor project.
- Identify Bioconductor packages and methods available to fetch and use gene annotations.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- What Bioconductor packages provides methods to efficiently fetch and use gene annotations?
- How can I use gene annotation packages to convert between different gene identifiers?

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

BiocManager::install(c("biomaRt", "org.Hs.eg.db"))
```

## Overview

Packages dedicated to query gene annotations exist in the 'Software' and
'Annotation' categories of the Bioconductor [biocViews][biocviews], according to
their nature.

In the 'Software' section, we find packages that do not actually contain gene
annotations, but rather dynamically _query_ them from online resources
(e.g.,[Ensembl BioMart][biomart-ensembl]).
One such Bioconductor package is *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)*.

Instead, in the 'Annotation' section, we find packages that do contain
annotations.
Examples include *[org.Hs.eg.db](https://bioconductor.org/packages/3.19/org.Hs.eg.db)*,
*[EnsDb.Hsapiens.v86](https://bioconductor.org/packages/3.19/EnsDb.Hsapiens.v86)*,
and *[TxDb.Hsapiens.UCSC.hg38.knownGene](https://bioconductor.org/packages/3.19/TxDb.Hsapiens.UCSC.hg38.knownGene)*.

In this episode, we will demonstrate the two approaches:

* Querying annotations from the Ensembl Biomart API using the *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* package.
* Querying annotations from the *[org.Hs.eg.db](https://bioconductor.org/packages/3.19/org.Hs.eg.db)* annotation package.

## Querying annotations from Ensembl BioMart

### Pros and cons

Pros:

* Automatically access the latest information
* Minimal storage footprint on the user's computer

Cons:

* Requires a live and stable internet connection throughout the analysis.
* Reproducibility may not be possible if the resource is updated without access
  to archives.
* Data may be organised differently in each resource.
* Custom code may be needed to access and retrieve data from each resource.

### The Ensembl BioMart

[Ensembl BioMart][biomart-ensembl] is a robust data mining tool designed to
facilitate access to the vast array of biological data available through the
Ensembl project.

The [BioMart web interface][biomart-ensembl] enables researchers to efficiently
query and retrieve data on genes, proteins, and other genomic features
across multiple species.
It allows users to filter, sort, and export data based on various attributes
such as gene IDs, chromosomal locations, and functional annotations.

### The Bioconductor `biomaRt` package

*[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* is a Bioconductor software package that
enables retrieval of large amounts of data from Ensembl BioMart tables
directly from an R session where those annotations can be used.

Let us first load the package:


``` r
library(biomaRt)
```

### Available marts

Ensembl BioMart organises its diverse biological information into four databases
also known as 'marts' or 'biomarts'.
Each mart focuses on a different type of data.

Users must select the mart corresponds to the type of data they are interested
in before they can query any information from it.

The function `listMarts()` can be used to display the names of those marts.
This is convenient as users do not need to memorise the name of the marts,
and the function will also return an updated list of names if any mart is
renamed, added, or removed.


``` r
listMarts()
```

``` output
               biomart                version
1 ENSEMBL_MART_ENSEMBL      Ensembl Genes 112
2   ENSEMBL_MART_MOUSE      Mouse strains 112
3     ENSEMBL_MART_SNP  Ensembl Variation 112
4 ENSEMBL_MART_FUNCGEN Ensembl Regulation 112
```

In this demonstration, we will use the biomart called `ENSEMBL_MART_ENSEMBL`,
which contains the Ensembl gene set.

Notably, the `version` columns also indicates the version of the biomart.
The Ensembl BioMart is updated regularly (multiple times per year).
By default, *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* functions access the latest
version of each biomart.
This is not ideal for reproducibility.

Thankfully, Ensembl BioMart archives past versions of its mars in a way that
is accessible both programmatically, and on its website.

The function `listEnsemblArchives()` can be used to display all the versions of
Ensembl Biomart accessible.


``` r
listEnsemblArchives()
```

``` output
             name     date                                 url version
1  Ensembl GRCh37 Feb 2014          https://grch37.ensembl.org  GRCh37
2     Ensembl 112 May 2024 https://may2024.archive.ensembl.org     112
3     Ensembl 111 Jan 2024 https://jan2024.archive.ensembl.org     111
4     Ensembl 110 Jul 2023 https://jul2023.archive.ensembl.org     110
5     Ensembl 109 Feb 2023 https://feb2023.archive.ensembl.org     109
6     Ensembl 108 Oct 2022 https://oct2022.archive.ensembl.org     108
7     Ensembl 107 Jul 2022 https://jul2022.archive.ensembl.org     107
8     Ensembl 106 Apr 2022 https://apr2022.archive.ensembl.org     106
9     Ensembl 105 Dec 2021 https://dec2021.archive.ensembl.org     105
10    Ensembl 104 May 2021 https://may2021.archive.ensembl.org     104
11    Ensembl 103 Feb 2021 https://feb2021.archive.ensembl.org     103
12    Ensembl 102 Nov 2020 https://nov2020.archive.ensembl.org     102
13    Ensembl 101 Aug 2020 https://aug2020.archive.ensembl.org     101
14    Ensembl 100 Apr 2020 https://apr2020.archive.ensembl.org     100
15     Ensembl 99 Jan 2020 https://jan2020.archive.ensembl.org      99
16     Ensembl 98 Sep 2019 https://sep2019.archive.ensembl.org      98
17     Ensembl 97 Jul 2019 https://jul2019.archive.ensembl.org      97
18     Ensembl 80 May 2015 https://may2015.archive.ensembl.org      80
19     Ensembl 77 Oct 2014 https://oct2014.archive.ensembl.org      77
20     Ensembl 75 Feb 2014 https://feb2014.archive.ensembl.org      75
21     Ensembl 54 May 2009 https://may2009.archive.ensembl.org      54
   current_release
1                 
2                *
3                 
4                 
5                 
6                 
7                 
8                 
9                 
10                
11                
12                
13                
14                
15                
16                
17                
18                
19                
20                
21                
```

In the output above, the key piece of information is the `url` column, which
provides the URL that *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* functions will need to
access data from the corresponding snapshot of the Ensembl BioMart.

At the time of writing, the current release is Ensembl 112, so let us use
the corresponding url `https://may2024.archive.ensembl.org` to ensure
reproducible results no matter when this lesson is delivered.

### Connecting to a biomart

The two pieces of information collected above -- the name of a biomart
and the URL of a snapshot -- is all that is needed to connect to a BioMart
database reproducibly.

The function `useMart()` can then be used to create a connection.
The connection is traditionally stored in an object called `mart`,
to be reused in subsequent steps for querying information from the online mart.


``` r
mart <- useMart(biomart = "ENSEMBL_MART_ENSEMBL", host = "https://may2024.archive.ensembl.org")
```

### Listing available data sets

Each biomart contains a number of data sets.

The function `listDatasets()` can be used to display the information about those
data sets.
This is convenient as users do not need to memorise the name of the data sets,
and the information returned by the function includes a short description of
each data set, as well as its version.

In the example below, we restrict the output table to the first few rows,
as the full table comprises 214 rows.


``` r
head(listDatasets(mart))
```

``` output
                       dataset                           description
1 abrachyrhynchus_gene_ensembl Pink-footed goose genes (ASM259213v1)
2     acalliptera_gene_ensembl      Eastern happy genes (fAstCal1.3)
3   acarolinensis_gene_ensembl       Green anole genes (AnoCar2.0v2)
4    acchrysaetos_gene_ensembl       Golden eagle genes (bAquChr1.2)
5    acitrinellus_gene_ensembl        Midas cichlid genes (Midas_v5)
6    amelanoleuca_gene_ensembl       Giant panda genes (ASM200744v2)
      version
1 ASM259213v1
2  fAstCal1.3
3 AnoCar2.0v2
4  bAquChr1.2
5    Midas_v5
6 ASM200744v2
```

In the output above, the key piece of information is the `dataset` column, which
provides the identifier that *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* functions will
need to access data from the corresponding biomart table.

In this demonstration, we will use the Ensembl gene set for Homo sapiens,
which is not visible in the output above.

Given the number of data sets available,
let us programmatically filter the table of information using pattern matching
rather than searching the table manually: 


``` r
subset(listDatasets(mart), grepl("sapiens", dataset))
```

``` output
                 dataset              description    version
80 hsapiens_gene_ensembl Human genes (GRCh38.p14) GRCh38.p14
```

From the output above, we identify the desired data set identifier as
`hsapiens_gene_ensembl`.

### Connecting to a data set

Having chosen the data set that we want to use, we need to call the function
`useMart()` again, this time specifying the selected data set.

Typically, one would copy paste the previous call to `useMart()` and edit as
needed.
It is also common practice to replace the `mart` object with the new connection.


``` r
mart <- useMart(
  biomart = "ENSEMBL_MART_ENSEMBL",
  dataset = "hsapiens_gene_ensembl",
  host = "https://may2024.archive.ensembl.org")
```

### Listing information available in a data set

BioMart tables contain many pieces of information also known as 'attributes'.
So many, in fact, that they have been grouped into categories also known as
'pages'.

The function `listAttributes()` can be used to display the information about
those attributes.
This is convenient as users do not need to memorise the name of the attributes,
and the information returned by the function includes a short description of
each attribute, as well as its page categorisation.

In the example below, we restrict the output table to the first few rows,
as the full table comprises 3157 rows.


``` r
head(listAttributes(mart))
```

``` output
                           name                  description         page
1               ensembl_gene_id               Gene stable ID feature_page
2       ensembl_gene_id_version       Gene stable ID version feature_page
3         ensembl_transcript_id         Transcript stable ID feature_page
4 ensembl_transcript_id_version Transcript stable ID version feature_page
5            ensembl_peptide_id            Protein stable ID feature_page
6    ensembl_peptide_id_version    Protein stable ID version feature_page
```

In the output above, the key piece of information is the `name` column, which
provides the identifier that *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* functions will
need to query that information from the corresponding biomart data set.

The choice of attributes to query now depends on what it is we wish to achieve.

For instance, let us imagine that we have a set of gene identifiers,
for which we wish to query:

* The gene symbol
* The name of the chromosome where the gene is located
* The start and end position of the gene on that chromosome
* The strand on which the gene is encoded

Users would often manually explore the full table of attributes to identify
the ones they wish to include in their query.
It is also possible to programmatically filter the table of attribute,
based on experience and intuition, to narrow down the search:


``` r
subset(listAttributes(mart), grepl("position", name) & grepl("feature", page))
```

``` output
             name     description         page
10 start_position Gene start (bp) feature_page
11   end_position   Gene end (bp) feature_page
```

### Querying information from a BioMart table

We have now all the information that we need to perform the actual query:

* A connection to a BioMart data set
* The list of attributes available in that data set

The function `getBM()` is the main *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* query
function.
Given a set of filters and corresponding values, it retrieves the attributes
requested by the user from the BioMart data set it is connected to.

In the example below, we manually create a vector or arbitrary gene identifiers
for our query.
In practice, the query will often originate from an earlier analysis
(e.g., differential gene expression).

The example below also queries attributes that we have not introduced yet.
In the previous section, we described how one may search the table of attributes
returned by `listAttributes()` to identify attributes to include in their query.


``` r
query_gene_ids <- c(
  "ENSG00000133101",
  "ENSG00000145386",
  "ENSG00000134057",
  "ENSG00000157456",
  "ENSG00000147082"
)
getBM(
  attributes = c(
    "ensembl_gene_id",
    "hgnc_symbol",
    "chromosome_name",
    "start_position",
    "end_position",
    "strand"
  ),
  filters = "ensembl_gene_id",
  values = query_gene_ids,
  mart = mart
)
```

``` output
  ensembl_gene_id hgnc_symbol chromosome_name start_position end_position
1 ENSG00000133101       CCNA1              13       36431520     36442870
2 ENSG00000134057       CCNB1               5       69167135     69178245
3 ENSG00000145386       CCNA2               4      121816444    121823883
4 ENSG00000147082       CCNB3               X       50202713     50351914
5 ENSG00000157456       CCNB2              15       59105126     59125045
  strand
1      1
2      1
3     -1
4      1
5      1
```

Note that we also included the filtering attribute `ensembl_gene_id` to the
attributes retrieved from the data set.
This is key to reliably match the newly retrieved attributes to those used
in the query.

[biocviews]: https://www.bioconductor.org/packages/release/BiocViews.html
[biomart-ensembl]: https://www.ensembl.org/biomart/martview