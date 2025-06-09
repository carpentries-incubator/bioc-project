---
source: Rmd
title: Working with annotations
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

## Online resources or Bioconductor annotation packages?

### Accessing the latest information

Bioconductor's 6-month release cycle implies that packages available from the
latest stable release branch will not be updated for six months
(only bugfixes are allowed, not functional updates).
As a result, annotation packages may contain information that is out-of-date
by up to six months.

Instead, independent online resources often have different policies driving
the release of updated information.
Some databases are frequently updated, while others may not have been updated
in years.

Accessing up-to-date information must also be balanced with reproducibility.
Having downloaded the 'latest' information at one point is time is no good if
one hasn't recorded at least *when* that information was downloaded.

### Storage requirements

By nature, Bioconductor annotation packages are larger than software packages.
Just like any other R package, annotation packages must be installed on the
user's computer before they can be used.
This can rapidly use add up to using an amount of disk space that is not
negligible.

Conversely, online resources are generally accessed programmatically, and
generally only require users to record code to replicate analyses reproducibly.

### Internet connectivity

When using online resources, it is often a good idea to write annotations
ownloaded from online resources to a local file,
and refer to that local file during analyses.

If online resources were to become unavailable for any reason
(e.g., downtime, loss of internet connection), analyses that use local files
can carry on while those that rely on those online resources cannot.

In contrast, Bioconductor annotation packages only require internet connectivity
at the time of installation.
Once installed, they do not require internet connectivity, as they rely on
information stored locally.

### Reproducibility

Bioconductor annotation packages are naturally versioned, meaning that users
can confidently report the version of the package used in their analysis.
Just like software packages, users control if and when annotation packages
should be updated on their computer.

Online resources have different policies to facilitate reproducible analyses.
Some online resources keep archived versions of their annotations, allowing
users to consistently access the same information over time.
When this is not the case, it may be necessary to download a copy of the
annotation at one point in time, and preciously keep that copy throughout
the lifetime of the project to ensure the use of a consistent set of
annotations.

### Consistency

As we will see in the practical examples of this episode,
Bioconductor annotation packages generally re-use a consistent set of data
structures.
This allows users familiar with one annotation package to rapidly get started
with others.

Independent online resources often organise their data in different ways,
which requires users to write custom code to access, retrieve, and process
their respective data.

## Querying annotations from Ensembl BioMart

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

### Listing available marts

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
1 ENSEMBL_MART_ENSEMBL      Ensembl Genes 114
2   ENSEMBL_MART_MOUSE      Mouse strains 114
3     ENSEMBL_MART_SNP  Ensembl Variation 114
4 ENSEMBL_MART_FUNCGEN Ensembl Regulation 114
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
2     Ensembl 114 May 2025 https://may2025.archive.ensembl.org     114
3     Ensembl 113 Oct 2024 https://oct2024.archive.ensembl.org     113
4     Ensembl 112 May 2024 https://may2024.archive.ensembl.org     112
5     Ensembl 111 Jan 2024 https://jan2024.archive.ensembl.org     111
6     Ensembl 110 Jul 2023 https://jul2023.archive.ensembl.org     110
7     Ensembl 109 Feb 2023 https://feb2023.archive.ensembl.org     109
8     Ensembl 108 Oct 2022 https://oct2022.archive.ensembl.org     108
9     Ensembl 107 Jul 2022 https://jul2022.archive.ensembl.org     107
10    Ensembl 106 Apr 2022 https://apr2022.archive.ensembl.org     106
11    Ensembl 105 Dec 2021 https://dec2021.archive.ensembl.org     105
12    Ensembl 104 May 2021 https://may2021.archive.ensembl.org     104
13    Ensembl 103 Feb 2021 https://feb2021.archive.ensembl.org     103
14    Ensembl 102 Nov 2020 https://nov2020.archive.ensembl.org     102
15    Ensembl 101 Aug 2020 https://aug2020.archive.ensembl.org     101
16    Ensembl 100 Apr 2020 https://apr2020.archive.ensembl.org     100
17     Ensembl 99 Jan 2020 https://jan2020.archive.ensembl.org      99
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

The function `listDatasets()` can be used to display information about those
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

The function `listAttributes()` can be used to display information about
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

In the example below, we manually create a vector of arbitrary gene identifiers
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

``` error
Error in .processResults(postRes, mart = mart, hostURLsep = sep, fullXmlQuery = fullXmlQuery, : Query ERROR: caught BioMart::Exception::Database: Error during query execution: Table 'ensembl_mart_112.hsapiens_gene_ensembl__ox_hgnc__dm' doesn't exist
```

Note that we also included the filtering attribute `ensembl_gene_id` to the
attributes retrieved from the data set.
This is key to reliably match the newly retrieved attributes to those used
in the query.

## Querying annotations from annotation packages

### Families of annotation packages

To balance the need for comprehensive information
while maintaining reasonable package sizes,
Bioconductor annotation packages are organised by release, data type, and
species.

The major families of Bioconductor annotation packages are:

* `OrgDb` packages provide mapping between various types of gene identifiers
  and pathway information.
* `EnsDb` packages provide individual releases of Ensembl annotations.
* `TxDb` packages provide individual releases of UCSC annotations.

All those families of annotations derive from the `AnnotationDb` base class
defined in the *[AnnotationDbi](https://bioconductor.org/packages/3.19/AnnotationDbi)* package.
As a result, any of those annotation packages can be accessed using the same set
of R functions, as demonstrated in the following sections.

### Using an OrgDb package

In this example, we will use the *[org.Hs.eg.db](https://bioconductor.org/packages/3.19/org.Hs.eg.db)*
package to demonstrate the use of gene annotations for the human species.

Let us first load the package:


``` r
library(org.Hs.eg.db)
```

Each `OrgDb` package contains an object named identically to the package itself.
That object contains the annotations that the package is meant to disseminate.

Aside from querying information, the whole object can be called to print
information about the annotations it contains, including the date at which
the snapshots of annotations that it contains were made.


``` r
org.Hs.eg.db
```

``` output
OrgDb object:
| DBSCHEMAVERSION: 2.1
| Db type: OrgDb
| Supporting package: AnnotationDbi
| DBSCHEMA: HUMAN_DB
| ORGANISM: Homo sapiens
| SPECIES: Human
| EGSOURCEDATE: 2024-Mar12
| EGSOURCENAME: Entrez Gene
| EGSOURCEURL: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
| CENTRALID: EG
| TAXID: 9606
| GOSOURCENAME: Gene Ontology
| GOSOURCEURL: http://current.geneontology.org/ontology/go-basic.obo
| GOSOURCEDATE: 2024-01-17
| GOEGSOURCEDATE: 2024-Mar12
| GOEGSOURCENAME: Entrez Gene
| GOEGSOURCEURL: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
| KEGGSOURCENAME: KEGG GENOME
| KEGGSOURCEURL: ftp://ftp.genome.jp/pub/kegg/genomes
| KEGGSOURCEDATE: 2011-Mar15
| GPSOURCENAME: UCSC Genome Bioinformatics (Homo sapiens)
| GPSOURCEURL: 
| GPSOURCEDATE: 2024-Feb29
| ENSOURCEDATE: 2023-Nov22
| ENSOURCENAME: Ensembl
| ENSOURCEURL: ftp://ftp.ensembl.org/pub/current_fasta
| UPSOURCENAME: Uniprot
| UPSOURCEURL: http://www.UniProt.org/
| UPSOURCEDATE: Thu Apr 18 21:39:39 2024
```

``` output

Please see: help('select') for usage information
```

That same object is the one that needs to be supplied to
*[AnnotationDbi](https://bioconductor.org/packages/3.19/AnnotationDbi)* functions for running queries and
retrieving annotations.

### Listing information available in an annotation package

The function `columns()` can be used to display the annotations available
in the object.

Here, the word 'column' refers to columns of tables used to store information in
database, the very same concept as 'attributes' in BioMart.
In other words, columns represent all the types of annotations that may be
retrieved from the object.

This is convenient as users do not need to memorise the names of the columns of
annotations available in the package.


``` r
columns(org.Hs.eg.db)
```

``` output
 [1] "ACCNUM"       "ALIAS"        "ENSEMBL"      "ENSEMBLPROT"  "ENSEMBLTRANS"
 [6] "ENTREZID"     "ENZYME"       "EVIDENCE"     "EVIDENCEALL"  "GENENAME"    
[11] "GENETYPE"     "GO"           "GOALL"        "IPI"          "MAP"         
[16] "OMIM"         "ONTOLOGY"     "ONTOLOGYALL"  "PATH"         "PFAM"        
[21] "PMID"         "PROSITE"      "REFSEQ"       "SYMBOL"       "UCSCKG"      
[26] "UNIPROT"     
```

### Listing keys and key types

In database terminology, *keys* are the values by which information may be
queried from a database table.

Information being organised in columns, *key types* are the names of the columns
in which the key values are stored.

Given the variable number of columns in database tables, some tables may allow
information to be queried by more than one key.
As a result, it is crucial to specify both the keys and the type of key as part
of the query.

The function `keytypes()` can be used to display the names of the columns that
may be used to query information from the object.


``` r
keytypes(org.Hs.eg.db)
```

``` output
 [1] "ACCNUM"       "ALIAS"        "ENSEMBL"      "ENSEMBLPROT"  "ENSEMBLTRANS"
 [6] "ENTREZID"     "ENZYME"       "EVIDENCE"     "EVIDENCEALL"  "GENENAME"    
[11] "GENETYPE"     "GO"           "GOALL"        "IPI"          "MAP"         
[16] "OMIM"         "ONTOLOGY"     "ONTOLOGYALL"  "PATH"         "PFAM"        
[21] "PMID"         "PROSITE"      "REFSEQ"       "SYMBOL"       "UCSCKG"      
[26] "UNIPROT"     
```

The function `keys()` can be used to display all the possible values for a given
key type.

It is generally better practice to specify the type of key being queried
(to avoid ambiguity), although database tables typically have a 'primary key'
used if users do not specify a type themselves.

In the example below, we restrict the list of gene symbol keys to the first few
values,
as the full set comprises 193279
values.


``` r
head(keys(org.Hs.eg.db, keytype = "SYMBOL"))
```

``` output
[1] "A1BG"  "A2M"   "A2MP1" "NAT1"  "NAT2"  "NATP" 
```

### Querying information from an annotation package

The function `select()` is the main *[AnnotationDbi](https://bioconductor.org/packages/3.19/AnnotationDbi)*
query function.
Given an `AnnotationDb` object, key values, and columns
(and optionally the type of key supplied if not the primary key),
it retrieves the columns requested by the user from the annotation object.

In the example below, we re-use the vector of arbitrary gene identifiers
used in the BioMart example a few sections above.

As you can see from the output of the `columns()` function, the annotation
object does not contain some of the attributes that we queried in the Biomart
example.
In this case, let us query:

* the gene symbol
* the gene name
* the gene type


``` r
select(
  x = org.Hs.eg.db,
  keys = query_gene_ids,
  columns = c(
    "SYMBOL",
    "GENENAME",
    "GENETYPE"
  ),
  keytype = "ENSEMBL"
)
```

``` output
'select()' returned 1:1 mapping between keys and columns
```

``` output
          ENSEMBL SYMBOL  GENENAME       GENETYPE
1 ENSG00000133101  CCNA1 cyclin A1 protein-coding
2 ENSG00000145386  CCNA2 cyclin A2 protein-coding
3 ENSG00000134057  CCNB1 cyclin B1 protein-coding
4 ENSG00000157456  CCNB2 cyclin B2 protein-coding
5 ENSG00000147082  CCNB3 cyclin B3 protein-coding
```

One small but notable difference with *[biomaRt](https://bioconductor.org/packages/3.19/biomaRt)* is that
the output of `select()` automatically contains the column that correspond to
the key type used in the query.
In other words, there is no need to specify the key type(s) again in the
column(s) to retrieve.

### Vectorized 1:1 mapping

It is sometimes possible for annotations to display 1-to-many relationships.
For instance, individual genes typically have a unique Ensembl gene identifier,
while they may be known under multiple gene name aliases.

The `select()` function demonstrated in the previous section automatically
returns *all* values in the columns requested, for the key specified.
This is possible thanks to the tabular format in which annotations are returned;
rows are added, repeating values as necessary to display them on the same row
as every other values they are associated with.

In some cases, that behaviour is not desirable.
Instead, users may wish to retrieve a single value for each key that they input.
One common scenario arises during differential gene expression (DGE),
where gene identifiers are used to uniquely identify genes throughout the
analysis, while gene symbols are added to the final table of DGE statistics,
to provide more readable human-friendly gene identifiers.
However, it is not desirable to duplicate rows of DGE statistics, and thus
only a single gene symbol is required to annotate each gene.

The function `mapIds()` can be used for this purpose.
A major difference between the functions `mapIds()` and `select()`
are their arguments `column` (singular) and `columns` (plural), respectively.
The function `mapIds()` accepts a single column name and returns a named
character vector where names are the input query values, and values are the
corresponding values in the requested column.

To deal with 1-to-many relationships, the function `mapIds()` has an argument
`multiVals` which can be used to specify how the function should handle multiple
values.
The default is to take the first value and ignore any other value.

In the example below, we query the gene symbol for a set of Ensembl gene
identifiers.


``` r
mapIds(
  x = org.Hs.eg.db,
  keys = query_gene_ids,
  column = "SYMBOL",
  keytype = "ENSEMBL"
)
```

``` output
'select()' returned 1:1 mapping between keys and columns
```

``` output
ENSG00000133101 ENSG00000145386 ENSG00000134057 ENSG00000157456 ENSG00000147082 
        "CCNA1"         "CCNA2"         "CCNB1"         "CCNB2"         "CCNB3" 
```

:::::::::::::::::::::::::::::::::::::::  challenge

### Challenge

Load the packages *[EnsDb.Hsapiens.v86](https://bioconductor.org/packages/3.19/EnsDb.Hsapiens.v86)* and
*[TxDb.Hsapiens.UCSC.hg38.knownGene](https://bioconductor.org/packages/3.19/TxDb.Hsapiens.UCSC.hg38.knownGene)*.
Then, display the columns of annotations available in those packages.

:::::::::::::::  solution

### Solution


``` r
library(EnsDb.Hsapiens.v86)
columns(EnsDb.Hsapiens.v86)
```

``` output
 [1] "ENTREZID"            "EXONID"              "EXONIDX"            
 [4] "EXONSEQEND"          "EXONSEQSTART"        "GENEBIOTYPE"        
 [7] "GENEID"              "GENENAME"            "GENESEQEND"         
[10] "GENESEQSTART"        "INTERPROACCESSION"   "ISCIRCULAR"         
[13] "PROTDOMEND"          "PROTDOMSTART"        "PROTEINDOMAINID"    
[16] "PROTEINDOMAINSOURCE" "PROTEINID"           "PROTEINSEQUENCE"    
[19] "SEQCOORDSYSTEM"      "SEQLENGTH"           "SEQNAME"            
[22] "SEQSTRAND"           "SYMBOL"              "TXBIOTYPE"          
[25] "TXCDSSEQEND"         "TXCDSSEQSTART"       "TXID"               
[28] "TXNAME"              "TXSEQEND"            "TXSEQSTART"         
[31] "UNIPROTDB"           "UNIPROTID"           "UNIPROTMAPPINGTYPE" 
```


``` r
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
columns(TxDb.Hsapiens.UCSC.hg38.knownGene)
```

``` output
 [1] "CDSCHROM"   "CDSEND"     "CDSID"      "CDSNAME"    "CDSPHASE"  
 [6] "CDSSTART"   "CDSSTRAND"  "EXONCHROM"  "EXONEND"    "EXONID"    
[11] "EXONNAME"   "EXONRANK"   "EXONSTART"  "EXONSTRAND" "GENEID"    
[16] "TXCHROM"    "TXEND"      "TXID"       "TXNAME"     "TXSTART"   
[21] "TXSTRAND"   "TXTYPE"    
```

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: keypoints

- Bioconductor provides a wide range annotation packages.
- Some Bioconductor software packages can be used to programmatically access online resources.
- Users should carefully choose their source of annotations based on their needs and expectations.

::::::::::::::::::::::::::::::::::::::::::::::::::

[biocviews]: https://www.bioconductor.org/packages/release/BiocViews.html
[biomart-ensembl]: https://www.ensembl.org/biomart/martview
