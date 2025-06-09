---
source: Rmd
title: Working with biological sequences
teaching: XX
exercises: XX
---



::::::::::::::::::::::::::::::::::::::: objectives

- Explain how biological sequences are represented in the Bioconductor project.
- Identify Bioconductor packages and methods available to process biological sequences.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- What is the recommended way to represent biological sequences in Bioconductor?
- What Bioconductor packages provides methods to efficiently process biological sequences?

::::::::::::::::::::::::::::::::::::::::::::::::::



## Install packages

Before we can proceed into the following sections, we install some Bioconductor packages that we will need.
First, we check that the *[BiocManager](https://bioconductor.org/packages/3.19/BiocManager)* package is installed before trying to use it; otherwise we install it.
Then we use the `BiocManager::install()` function to install the necessary packages.


``` r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("Biostrings")
```

## The Biostrings package and classes

### Why do we need classes for biological sequences?

Biological sequences are arguably some of the simplest biological entities to
represent computationally.
Examples include nucleic acid sequences (e.g., DNA, RNA) and protein sequences
composed of amino acids.

That is because alphabets have been designed and agreed upon to represent
individual monomers using character symbols.

For instance, using the alphabet for amino acids, the reference protein sequence
for the [Actin, alpha skeletal muscle protein sequence](https://www.uniprot.org/uniprot/P68133#sequences) is represented as
follows.


``` output
[1] "MCDEDETTALVCDNGSGLVKAGFAGDDAPRAVFPSIVGRPRHQGVMVGMGQKDSYVGDEAQSKRGILTLKYPIEHGIITNWDDMEKIWHHTFYNELRVAPEEHPTLLTEAPLNPKANREKMTQIMFETFNVPAMYVAIQAVLSLYASGRTTGIVLDSGDGVTHNVPIYEGYALPHAIMRLDLAGRDLTDYLMKILTERGYSFVTTAEREIVRDIKEKLCYVALDFENEMATAASSSSLEKSYELPDGQVITIGNERFRCPETLFQPSFIGMESAGIHETTYNSIMKCDIDIRKDLYANNVMSGGTTMYPGIADRMQKEITALAPSTMKIKIIAPPERKYSVWIGGSILASLSTFQQMWITKQEYDEAGPSIVHRKCF"
```

However, a major limitation of regular character vectors is that they do not
check the validity of the sequences that they contain.
Practically, it is possible to store meaningless sequences of symbols in
character strings, including symbols that are not part of the official alphabet
for the relevant type of polymer.
In those cases, the burden of checking the validity of sequences falls on the
programs that process them, or causing those programs to run into errors when
they unexpectedly encounter invalid symbols in a sequence.

Instead, [S4 classes][glossary-s4-class] -- demonstrated in the earlier episode [The S4 class system][crossref-s4] -- provide a way to label objects as distinct "DNA", "RNA", or "protein" varieties of biological sequences.
This label is an extremely powerful way to inform programs on the set of character symbols they can expect in the sequence, but also the range of computational operations that can be applied to those sequences.
For instance, a function designed to translate nucleic acid sequences into the corresponding amino acid sequence should only be allowed to run on sequences that represent nucleic acids.

:::::::::::::::::::::::::::::::::::::::  challenge

### Challenge

Can you tell whether this character string is a valid DNA sequence?

```
AATTGGCCRGGCCAATT
```

:::::::::::::::  solution

### Solution

Yes, this is a valid DNA sequence using ambiguity codes defined in the [IUPAC][external-iupac] notation.
In this case, `A`, `T`, `C`, and `G` represents the four standard types of
nucleotides, while the `R` symbol acts as a regular expression representing
either of the two purine nucleotide bases, `A` and `G`.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

## The Biostrings package

### Overview

In the Bioconductor project, the *[Biostrings](https://bioconductor.org/packages/3.19/Biostrings)* package
implements S4 classes to represent biological sequences as S4 objects, e.g.
`DNAString` for sequences of nucleotides in deoxyribonucleic acid polymers, and
`AAString` for sequences of amino acids in protein polymers.
Those S4 classes provide memory-efficient containers for character strings,
automatic validity-checking functionality for each class of biological
molecules, and methods implementing various string matching algorithms and other
utilities for fast manipulation and processing of large biological sequences or
sets of sequences.

A short presentation of the basic classes defined in the
*[Biostrings](https://bioconductor.org/packages/3.19/Biostrings)* package is available in one of the package
vignettes, accessible as `vignette("Biostrings2Classes")`, while more detailed
information is provided in the other package vignettes, accessible as
`browseVignettes("Biostrings")`.

### First steps

To get started, we load the package.


``` r
library(Biostrings)
```

With the package loaded and attached to the session, we have access to the
package functions.
Those include functions that let us create new objects of the classes defined
in the package.
For instance, we can create an object that represents a DNA sequence, using the
`DNAString()` constructor function.
Without assigning the output to an object, we let the resulting object be
printed in the console.


``` r
DNAString("ATCG")
```

``` output
4-letter DNAString object
seq: ATCG
```

Notably, DNA sequences may only contain the symbols `A`, `T`, `C`, and `G`, to
represent the four DNA nucleotide bases, the symbol `N` as a placeholder for an
unknown or unspecified base, and a restricted set of additional symbols with
special meaning defined in the
[IUPAC Extended Genetic Alphabet][iupac-alphabet].
Notice that the constructor function does not let us create objects that contain
invalid characters, e.g. `Z`.


``` r
DNAString("ATCGZ")
```

``` error
Error in .Call2("new_XString_from_CHARACTER", class(x0), string, start, : key 90 (char 'Z') not in lookup table
```

Specifically, the [IUPAC Extended Genetic Alphabet][iupac-alphabet] defines
ambiguity codes that represent sets of nucleotides, in a way similar to regular
expressions.
The `IUPAC_CODE_MAP` named character vector contains the mapping from the IUPAC
nucleotide ambiguity codes to their meaning.


``` r
IUPAC_CODE_MAP
```

``` output
     A      C      G      T      M      R      W      S      Y      K      V 
   "A"    "C"    "G"    "T"   "AC"   "AG"   "AT"   "CG"   "CT"   "GT"  "ACG" 
     H      D      B      N 
 "ACT"  "AGT"  "CGT" "ACGT" 
```

Any of those nucleotide codes are allowed in the sequence of a `DNAString`
object.
For instance, the symbol `M` represents either of the two nucleotides `A` or `C`
at a given position in a nucleic acid sequence.


``` r
DNAString("ATCGM")
```

``` output
5-letter DNAString object
seq: ATCGM
```

In particular, pattern matching methods implemented in the
*[Biostrings](https://bioconductor.org/packages/3.19/Biostrings)* package recognize the meaning of ambiguity
codes for each class of biological sequence, allowing them to efficiently match
motifs queried by users without the need to design elaborate regular
expressions.
For instance, the method `matchPattern()` takes a `pattern=` and a `subject=`
argument, and returns a `Views` object that reports and displays any match of
the `pattern` expression at any position in the `subject` sequence.

Note that the default option `fixed = TRUE` instructs the method to match the
query exactly -- i.e., ignore ambiguity codes -- which in this case does not report
any exact match.


``` r
dna1 <- DNAString("ATCGCTTTGA")
matchPattern("GM", dna1, fixed = TRUE)
```

``` output
Views on a 10-letter DNAString subject
subject: ATCGCTTTGA
views: NONE
```

Instead, to indicate that the pattern includes some ambiguity code, the argument
`fixed` must be set to `FALSE`.


``` r
matchPattern("GM", dna1, fixed = FALSE)
```

``` output
Views on a 10-letter DNAString subject
subject: ATCGCTTTGA
views:
      start end width
  [1]     4   5     2 [GC]
  [2]     9  10     2 [GA]
```

In this particular example, two views describe matches of the pattern in the
subject sequence.
Specifically, the pattern `GM` first matched the sequence `GC` spanning
positions 4 to 5 in the subject sequence, and then also matched the sequence
`GA` from positions 9 to 10.

Similarly to the method `matchPattern()`, the method `countPattern()` can be
applied to simply count the number of matches of the `pattern` in the `subject`
sequence.
And again, the option `fixed` controls whether to respect ambiguity codes, or
match them exactly.

:::::::::::::::::::::::::::::::::::::::  challenge

### Challenge

How many hits does the following code return? Why?

```
dna2 <- DNAString("TGATTGCTTGGTTGMTT")
countPattern("GM", dna2, fixed = FALSE)
```

:::::::::::::::  solution

### Solution

The method `countPattern()` reports 3 hits, because the option
`fixed = FALSE` allows the pattern `GM` to match `GA`, `GC`, and `GM`
sequences, due to the use of the ambiguity code `M` in the `pattern`.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

### Importing biological strings from files

In practice, users rarely type the strings representing biological sequences themselves.
Most of the time, biological strings are imported from files, either downloaded from public repositories or generated locally using bioinformatics programs.

For instance, we can load the set of adapter sequences for the [TruSeq™ DNA PCR-Free whole-genome sequencing library preparation][external-truseq] kit from a file that we downloaded during the lesson setup.
Since adapter sequences are nucleic acid sequences, we must use the function `readDNAStringSet()`.


``` r
truseq_adapters <- readDNAStringSet(filepath = "data/TruSeq3-PE-2.fa")
truseq_adapters
```

``` output
DNAStringSet object of length 6:
    width seq                                               names               
[1]    34 TACACTCTTTCCCTACACGACGCTCTTCCGATCT                PrefixPE/1
[2]    34 GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT                PrefixPE/2
[3]    34 TACACTCTTTCCCTACACGACGCTCTTCCGATCT                PE1
[4]    34 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA                PE1_rc
[5]    34 GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT                PE2
[6]    34 AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC                PE2_rc
```

:::::::::::::::::::::::::::::::::::::::::  callout

### Going further

The help page of the function `readDNAStringSet()` -- accessible using
`help(readDNAStringSet)` -- documents related functions designed to import
other types of biological sequences, e.g `readRNAStringSet()`,
`readAAStringSet()`.

::::::::::::::::::::::::::::::::::::::::::::::::::

### Operations on biological strings

#### Computing the frequency of symbols

The *[Biostrings](https://bioconductor.org/packages/3.19/Biostrings)* package provides several functions to
process and manipulate classes of biological strings.
For example, we have come across `matchPattern()` and `countPattern()` earlier
in this episode.

Another example of a method that can be applied to biological strings is
`letterFrequency()`, to compute the frequency of letters in a biological
sequence.


``` r
letterFrequency(truseq_adapters, letters = DNA_ALPHABET)
```

``` output
      A  C  G  T M R W S Y K V H D B N - + .
[1,]  6 14  3 11 0 0 0 0 0 0 0 0 0 0 0 0 0 0
[2,]  5  8 10 11 0 0 0 0 0 0 0 0 0 0 0 0 0 0
[3,]  6 14  3 11 0 0 0 0 0 0 0 0 0 0 0 0 0 0
[4,] 11  3 14  6 0 0 0 0 0 0 0 0 0 0 0 0 0 0
[5,]  5  8 10 11 0 0 0 0 0 0 0 0 0 0 0 0 0 0
[6,] 11 10  8  5 0 0 0 0 0 0 0 0 0 0 0 0 0 0
```

The output is a matrix with one row for each sequence in the `DNAStringSet`
object, and one column for each symbol in the alphabet of deoxyribonucleic
acids, provided by the *[Biostrings](https://bioconductor.org/packages/3.19/Biostrings)* package in a
built-in object called `DNA_ALPHABET`.

### Amino acid sequences

Similarly to the `DNAString` and `DNAStringSet` classes, the classes `AAString` and `AAStringSet` allow efficient storage and manipulation of a long amino acid sequence, or a set thereof.

Similarly to built-in objects for the DNA alphabet, the built-in objects `AA_ALPHABET`, `AA_STANDARD` and `AA_PROTEINOGENIC` describe different subsets of the alphabet of valid symbols for amino acid sequences.

For instance, the `AA_ALPHABET` object describes the set of symbols in the full amino acid alphabet.


``` r
AA_ALPHABET
```

``` output
 [1] "A" "R" "N" "D" "C" "Q" "E" "G" "H" "I" "L" "K" "M" "F" "P" "S" "T" "W" "Y"
[20] "V" "U" "O" "B" "J" "Z" "X" "*" "-" "+" "."
```

:::::::::::::::::::::::::::::::::::::::  challenge

### Challenge

Use base R code to identify the two symbols present in the `AA_PROTEINOGENIC`
alphabet object that are absent from the `AA_STANDARD` alphabet object.
What do those two symbols represent?

:::::::::::::::  solution

### Solution

```
> setdiff(AA_PROTEINOGENIC, AA_STANDARD)
[1] "U" "O"
```

The symbols `U` and `O` represent selenocysteine and pyrrolysine, respectively.
Those two amino acids are in some species coded for by codons that are usually interpreted as stop codons.
As such, they are not included in the alphabet of "standard" amino acids, and an alphabet of "proteinogenic" amino acids was defined to acknowledge the special biology of those amino acids.
Either of those alphabets may be used to determine the validity of an amino acid sequence, depending on its biological nature.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

### Translating nucleotide sequences

One of the key motivations for the use of [S4 classes][glossary-s4-class] and the object-oriented programming (OOP) model relies on the infrastructure of S4 generics and methods.
As described in the earlier episode [The S4 class system][crossref-s4], generics provide a mechanism for defining and applying distinct implementations of the same generic function name, according to the nature of the input object(s) provided to the function call.

For instance, the *[Biostrings](https://bioconductor.org/packages/3.19/Biostrings)* package provides multiple implementations of a generic called `translate()`,  for translating DNA or RNA sequences into amino acid sequences.
The set of input objects supported by the generic `translate()` can be listed using the function `showMethods()`, from the CRAN package *[methods](https://CRAN.R-project.org/package=methods)*.


``` r
showMethods("translate")
```

``` output
Function: translate (package Biostrings)
x="DNAString"
x="DNAStringSet"
x="MaskedDNAString"
x="MaskedRNAString"
x="RNAString"
x="RNAStringSet"
```

In the output above, we see that that the generic function `translate()` includes methods capable of handling objects representing DNA and RNA sequences in the `DNAString` and `RNAString` classes, respectively;
but also lists of DNA and RNA sequences in objects of class `DNAStringSet` and `RNAStringSet`, as well as other classes capable of storing DNA and RNA sequences.

To demonstrate the use of the `translate()` method, we first load a set of open
reading frames (ORFs) identified by the
[NIH Open Reading Frame Finder][orf-finder]
for the *Homo sapiens* actin beta (ACTB) mRNA (RefSeq: NM\_001101),
using the standard genetic code, a minimal ORF length of 75 nucleotides,
and starting with the "ATG" start codon only.


``` r
actb_orf_nih <- readDNAStringSet("data/actb_orfs.fasta")
actb_orf_nih
```

``` output
DNAStringSet object of length 13:
     width seq                                              names               
 [1]   222 ATGCCCACCATCACGCCCTGGTG...CGGGGCGGACGCGGTCTCGGCG gi|1519311456|ref...
 [2]  1128 ATGGATGATGATATCGCCGCGCT...CGTCCACCGCAAATGCTTCTAG gi|1519311456|ref...
 [3]   126 ATGATGATATCGCCGCGCTCGTC...CGCCCCAGGCACCAGGGCGTGA gi|1519311456|ref...
 [4]    90 ATGTCGTCCCAGTTGGTGACGAT...CTGGGCCTCGTCGCCCACATAG gi|1519311456|ref...
 [5]   225 ATGGGCACAGTGTGGGTGACCCC...AGCCACACGCAGCTCATTGTAG gi|1519311456|ref...
 ...   ... ...
 [9]   342 ATGAGATTGGCATGGCTTTATTT...ATGTAATGCAAAATTTTTTTAA gi|1519311456|ref...
[10]   168 ATGGCTTTATTTGTTTTTTTTGT...TTGCACATTGTTGTTTTTTTAA gi|1519311456|ref...
[11]   111 ATGACTATTAAAAAAACAACAAT...CCTTCACCGTTCCAGTTTTTAA gi|1519311456|ref...
[12]   105 ATGCAAAATTTTTTTAATCTTCG...CCTTTTTTGTCCCCCAACTTGA gi|1519311456|ref...
[13]   135 ATGATGAGCCTTCGTGCCCCCCC...TGACTTGAGACCAGTTGAATAA gi|1519311456|ref...
```

Having imported the nucleotide sequences as a `DNAStringSet` object, we can
apply the `translate()` method to that object to produce the amino acid
sequence that results from the translation process for each nucleotide sequence.


``` r
actb_aa <- translate(actb_orf_nih)
actb_aa
```

``` output
AAStringSet object of length 13:
     width seq                                              names               
 [1]    74 MPTITPWCLGRPTMEGKTARGAS...VWTGGGSAKARLCARGADAVSA gi|1519311456|ref...
 [2]   376 MDDDIAALVVDNGSGMCKAGFAG...MWISKQEYDESGPSIVHRKCF* gi|1519311456|ref...
 [3]    42 MMISPRSSSTTAPACARPASRATMPPGPSSPPSWGAPGTRA*       gi|1519311456|ref...
 [4]    30 MSSQLVTMPCSMGYFRVRMPLLLWASSPT*                   gi|1519311456|ref...
 [5]    75 MGTVWVTPSPESITMPVVRPEAY...GFRGASVSSTGCSSGATRSSL* gi|1519311456|ref...
 ...   ... ...
 [9]   114 MRLAWLYLFFLFCFGFFFFFGLT...QVHTGEVIALLSCKLCNAKFF* gi|1519311456|ref...
[10]    56 MALFVFFVLFWFFFFFWLDSGFK...ERASPKVHNVAEDFDCTLLFF* gi|1519311456|ref...
[11]    37 MTIKKTTMCNQSPRPHCELWGMLAPTDCCHLHRSSF*            gi|1519311456|ref...
[12]    35 MQNFFNLRLNTFLFCFILNDEPSCPPFPLFCPPT*              gi|1519311456|ref...
[13]    45 MMSLRAPPSPFFVPQLEMYEGFWSPWEWVEAARAYLYTDLRPVE*    gi|1519311456|ref...
```

In the example above, all amino acid sequences visible start with the typical
methionin amino acid encoded by the "ATG" start codon.
We also see that all but one of the amino acid sequences visible end with the
`*` symbol, which indicates that the translation process ended on a stop codon.
In contrast, the first open reading frame above reached the end of the
nucleotide sequence without encoutering a stop codon.

Conveniently, the number of amino acids in each sequence is stated under the
header `width`.

:::::::::::::::::::::::::::::::::::::::  challenge

### Challenge

Extract the length of each amino acid sequence above as an integer vector.
What is the length of the longest amino acid sequence translated from any of
those open reading frames?

Compare your result with the sequence information on the UniPro page for
ACTB ([https://www.uniprot.org/uniprot/P60709#sequences](https://www.uniprot.org/uniprot/P60709#sequences)).

:::::::::::::::  solution

### Solution

```
width(actb_aa)
# or
max(width(actb_aa))
```

The longest translated sequence contains 376 amino acids.

The Uniprot page reports a sequence of 375 amino acids.
However, the UniProt amino acid sequence does not comprise any symbol to
represent the stop codon.
That difference aside, the UniPro amino acid sequence is identical to the
sequence that was produced by the `translate()` method.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

## The BSgenome package

### Overview

In the Bioconductor project, the *[BSgenome](https://bioconductor.org/packages/3.19/BSgenome)* package
provides software infrastructure for efficient representation of full genome
and their single-nucleotide polymorphisms.

The *[BSgenome](https://bioconductor.org/packages/3.19/BSgenome)* package itself does not contain any
genome sequence itself, but provides functionality to access genome sequences
available in other Bioconductor packages, as we demonstrate in the next section.

### First steps

To get started, we load the package.


``` r
library(BSgenome)
```

With the package loaded and attached to the session, we have access to the
package functions.

In particular, the function `BSgenome::available.genomes()` can be used to
display the names of Bioconductor packages that contain genome sequences.


``` r
available.genomes()
```

``` output
'getOption("repos")' replaces Bioconductor standard repositories, see
'help("repositories", package = "BiocManager")' for details.
Replacement repositories:
    BioCsoft: https://bioconductor.org/packages/3.19/bioc
    BioCann: https://bioconductor.org/packages/3.19/data/annotation
    BioCexp: https://bioconductor.org/packages/3.19/data/experiment
    BioCworkflows: https://bioconductor.org/packages/3.19/workflows
    BioCbooks: https://bioconductor.org/packages/3.19/books
    CRAN: https://cloud.r-project.org
```

``` output
  [1] "BSgenome.Alyrata.JGI.v1"                           
  [2] "BSgenome.Amellifera.BeeBase.assembly4"             
  [3] "BSgenome.Amellifera.NCBI.AmelHAv3.1"               
  [4] "BSgenome.Amellifera.UCSC.apiMel2"                  
  [5] "BSgenome.Amellifera.UCSC.apiMel2.masked"           
  [6] "BSgenome.Aofficinalis.NCBI.V1"                     
  [7] "BSgenome.Athaliana.TAIR.04232008"                  
  [8] "BSgenome.Athaliana.TAIR.TAIR9"                     
  [9] "BSgenome.Btaurus.UCSC.bosTau3"                     
 [10] "BSgenome.Btaurus.UCSC.bosTau3.masked"              
 [11] "BSgenome.Btaurus.UCSC.bosTau4"                     
 [12] "BSgenome.Btaurus.UCSC.bosTau4.masked"              
 [13] "BSgenome.Btaurus.UCSC.bosTau6"                     
 [14] "BSgenome.Btaurus.UCSC.bosTau6.masked"              
 [15] "BSgenome.Btaurus.UCSC.bosTau8"                     
 [16] "BSgenome.Btaurus.UCSC.bosTau9"                     
 [17] "BSgenome.Btaurus.UCSC.bosTau9.masked"              
 [18] "BSgenome.Carietinum.NCBI.v1"                       
 [19] "BSgenome.Celegans.UCSC.ce10"                       
 [20] "BSgenome.Celegans.UCSC.ce11"                       
 [21] "BSgenome.Celegans.UCSC.ce2"                        
 [22] "BSgenome.Celegans.UCSC.ce6"                        
 [23] "BSgenome.Cfamiliaris.UCSC.canFam2"                 
 [24] "BSgenome.Cfamiliaris.UCSC.canFam2.masked"          
 [25] "BSgenome.Cfamiliaris.UCSC.canFam3"                 
 [26] "BSgenome.Cfamiliaris.UCSC.canFam3.masked"          
 [27] "BSgenome.Cjacchus.UCSC.calJac3"                    
 [28] "BSgenome.Cjacchus.UCSC.calJac4"                    
 [29] "BSgenome.CneoformansVarGrubiiKN99.NCBI.ASM221672v1"
 [30] "BSgenome.Creinhardtii.JGI.v5.6"                    
 [31] "BSgenome.Dmelanogaster.UCSC.dm2"                   
 [32] "BSgenome.Dmelanogaster.UCSC.dm2.masked"            
 [33] "BSgenome.Dmelanogaster.UCSC.dm3"                   
 [34] "BSgenome.Dmelanogaster.UCSC.dm3.masked"            
 [35] "BSgenome.Dmelanogaster.UCSC.dm6"                   
 [36] "BSgenome.Drerio.UCSC.danRer10"                     
 [37] "BSgenome.Drerio.UCSC.danRer11"                     
 [38] "BSgenome.Drerio.UCSC.danRer5"                      
 [39] "BSgenome.Drerio.UCSC.danRer5.masked"               
 [40] "BSgenome.Drerio.UCSC.danRer6"                      
 [41] "BSgenome.Drerio.UCSC.danRer6.masked"               
 [42] "BSgenome.Drerio.UCSC.danRer7"                      
 [43] "BSgenome.Drerio.UCSC.danRer7.masked"               
 [44] "BSgenome.Dvirilis.Ensembl.dvircaf1"                
 [45] "BSgenome.Ecoli.NCBI.20080805"                      
 [46] "BSgenome.Gaculeatus.UCSC.gasAcu1"                  
 [47] "BSgenome.Gaculeatus.UCSC.gasAcu1.masked"           
 [48] "BSgenome.Ggallus.UCSC.galGal3"                     
 [49] "BSgenome.Ggallus.UCSC.galGal3.masked"              
 [50] "BSgenome.Ggallus.UCSC.galGal4"                     
 [51] "BSgenome.Ggallus.UCSC.galGal4.masked"              
 [52] "BSgenome.Ggallus.UCSC.galGal5"                     
 [53] "BSgenome.Ggallus.UCSC.galGal6"                     
 [54] "BSgenome.Gmax.NCBI.Gmv40"                          
 [55] "BSgenome.Hsapiens.1000genomes.hs37d5"              
 [56] "BSgenome.Hsapiens.NCBI.GRCh38"                     
 [57] "BSgenome.Hsapiens.NCBI.T2T.CHM13v2.0"              
 [58] "BSgenome.Hsapiens.UCSC.hg17"                       
 [59] "BSgenome.Hsapiens.UCSC.hg17.masked"                
 [60] "BSgenome.Hsapiens.UCSC.hg18"                       
 [61] "BSgenome.Hsapiens.UCSC.hg18.masked"                
 [62] "BSgenome.Hsapiens.UCSC.hg19"                       
 [63] "BSgenome.Hsapiens.UCSC.hg19.masked"                
 [64] "BSgenome.Hsapiens.UCSC.hg38"                       
 [65] "BSgenome.Hsapiens.UCSC.hg38.dbSNP151.major"        
 [66] "BSgenome.Hsapiens.UCSC.hg38.dbSNP151.minor"        
 [67] "BSgenome.Hsapiens.UCSC.hg38.masked"                
 [68] "BSgenome.Hsapiens.UCSC.hs1"                        
 [69] "BSgenome.Mdomestica.UCSC.monDom5"                  
 [70] "BSgenome.Mfascicularis.NCBI.5.0"                   
 [71] "BSgenome.Mfascicularis.NCBI.6.0"                   
 [72] "BSgenome.Mfuro.UCSC.musFur1"                       
 [73] "BSgenome.Mmulatta.UCSC.rheMac10"                   
 [74] "BSgenome.Mmulatta.UCSC.rheMac2"                    
 [75] "BSgenome.Mmulatta.UCSC.rheMac2.masked"             
 [76] "BSgenome.Mmulatta.UCSC.rheMac3"                    
 [77] "BSgenome.Mmulatta.UCSC.rheMac3.masked"             
 [78] "BSgenome.Mmulatta.UCSC.rheMac8"                    
 [79] "BSgenome.Mmusculus.UCSC.mm10"                      
 [80] "BSgenome.Mmusculus.UCSC.mm10.masked"               
 [81] "BSgenome.Mmusculus.UCSC.mm39"                      
 [82] "BSgenome.Mmusculus.UCSC.mm8"                       
 [83] "BSgenome.Mmusculus.UCSC.mm8.masked"                
 [84] "BSgenome.Mmusculus.UCSC.mm9"                       
 [85] "BSgenome.Mmusculus.UCSC.mm9.masked"                
 [86] "BSgenome.Osativa.MSU.MSU7"                         
 [87] "BSgenome.Ppaniscus.UCSC.panPan1"                   
 [88] "BSgenome.Ppaniscus.UCSC.panPan2"                   
 [89] "BSgenome.Ptroglodytes.UCSC.panTro2"                
 [90] "BSgenome.Ptroglodytes.UCSC.panTro2.masked"         
 [91] "BSgenome.Ptroglodytes.UCSC.panTro3"                
 [92] "BSgenome.Ptroglodytes.UCSC.panTro3.masked"         
 [93] "BSgenome.Ptroglodytes.UCSC.panTro5"                
 [94] "BSgenome.Ptroglodytes.UCSC.panTro6"                
 [95] "BSgenome.Rnorvegicus.UCSC.rn4"                     
 [96] "BSgenome.Rnorvegicus.UCSC.rn4.masked"              
 [97] "BSgenome.Rnorvegicus.UCSC.rn5"                     
 [98] "BSgenome.Rnorvegicus.UCSC.rn5.masked"              
 [99] "BSgenome.Rnorvegicus.UCSC.rn6"                     
[100] "BSgenome.Rnorvegicus.UCSC.rn7"                     
[101] "BSgenome.Scerevisiae.UCSC.sacCer1"                 
[102] "BSgenome.Scerevisiae.UCSC.sacCer2"                 
[103] "BSgenome.Scerevisiae.UCSC.sacCer3"                 
[104] "BSgenome.Sscrofa.UCSC.susScr11"                    
[105] "BSgenome.Sscrofa.UCSC.susScr3"                     
[106] "BSgenome.Sscrofa.UCSC.susScr3.masked"              
[107] "BSgenome.Tgondii.ToxoDB.7.0"                       
[108] "BSgenome.Tguttata.UCSC.taeGut1"                    
[109] "BSgenome.Tguttata.UCSC.taeGut1.masked"             
[110] "BSgenome.Tguttata.UCSC.taeGut2"                    
[111] "BSgenome.Vvinifera.URGI.IGGP12Xv0"                 
[112] "BSgenome.Vvinifera.URGI.IGGP12Xv2"                 
[113] "BSgenome.Vvinifera.URGI.IGGP8X"                    
```

### Installing BSgenome packages

To use one of the available genomes, the corresponding package must be installed
first.
For instance, the example below demonstrates how the data package
*[BSgenome.Hsapiens.UCSC.hg38.masked](https://bioconductor.org/packages/3.19/BSgenome.Hsapiens.UCSC.hg38.masked)* can be installed
using the function `BiocManager::install()` that we have seen before.


``` r
BiocManager::install("BSgenome.Hsapiens.UCSC.hg38.masked")
```

### Using BSgenome packages

Once installed, BSgenome packages can be loaded like any other R package,
using the `library()` function.


``` r
library(BSgenome.Hsapiens.UCSC.hg38.masked)
```

Each BSgenome package contains an object that is named identically to the
package and contains the genome sequence.

Having loaded the package
*[BSgenome.Hsapiens.UCSC.hg38.masked](https://bioconductor.org/packages/3.19/BSgenome.Hsapiens.UCSC.hg38.masked)* above, we can
display the BSgenome object as follows.


``` r
BSgenome.Hsapiens.UCSC.hg38.masked
```

``` output
| BSgenome object for Human
| - organism: Homo sapiens
| - provider: UCSC
| - genome: hg38
| - release date: 2023/01/31
| - 711 sequence(s):
|     chr1                    chr2                    chr3                   
|     chr4                    chr5                    chr6                   
|     chr7                    chr8                    chr9                   
|     chr10                   chr11                   chr12                  
|     chr13                   chr14                   chr15                  
|     ...                     ...                     ...                    
|     chr19_KV575256v1_alt    chr19_KV575257v1_alt    chr19_KV575258v1_alt   
|     chr19_KV575259v1_alt    chr19_KV575260v1_alt    chr19_MU273387v1_alt   
|     chr22_KN196485v1_alt    chr22_KN196486v1_alt    chr22_KQ458387v1_alt   
|     chr22_KQ458388v1_alt    chr22_KQ759761v1_alt    chrX_KV766199v1_alt    
|     chrX_MU273395v1_alt     chrX_MU273396v1_alt     chrX_MU273397v1_alt    
| 
| Tips: call 'seqnames()' on the object to get all the sequence names, call
| 'seqinfo()' to get the full sequence info, use the '$' or '[[' operator to
| access a given sequence, see '?BSgenome' for more information.
```

Given the length and the complexity of the object name, it is common practice
to assign a copy of BSgenome objects to a new object simply called `genome`.


``` r
genome <- BSgenome.Hsapiens.UCSC.hg38.masked
```

### Using BSgenome objects

When printing BSgenome objects in the console (see above), some helpful tips
are displayed under the object itself, hinting at functions commonly used to
access information in the object.

For instance, the function `seqnames()` can be used get the list of sequence
names (i.e., chromosomes and contigs) present in the object.


``` r
seqnames(genome)
```

``` output
  [1] "chr1"                    "chr2"                   
  [3] "chr3"                    "chr4"                   
  [5] "chr5"                    "chr6"                   
  [7] "chr7"                    "chr8"                   
  [9] "chr9"                    "chr10"                  
 [11] "chr11"                   "chr12"                  
 [13] "chr13"                   "chr14"                  
 [15] "chr15"                   "chr16"                  
 [17] "chr17"                   "chr18"                  
 [19] "chr19"                   "chr20"                  
 [21] "chr21"                   "chr22"                  
 [23] "chrX"                    "chrY"                   
 [25] "chrM"                    "chr1_GL383518v1_alt"    
 [27] "chr1_GL383519v1_alt"     "chr1_GL383520v2_alt"    
 [29] "chr1_KI270759v1_alt"     "chr1_KI270760v1_alt"    
 [31] "chr1_KI270761v1_alt"     "chr1_KI270762v1_alt"    
 [33] "chr1_KI270763v1_alt"     "chr1_KI270764v1_alt"    
 [35] "chr1_KI270765v1_alt"     "chr1_KI270766v1_alt"    
 [37] "chr1_KI270892v1_alt"     "chr2_GL383521v1_alt"    
 [39] "chr2_GL383522v1_alt"     "chr2_GL582966v2_alt"    
 [41] "chr2_KI270767v1_alt"     "chr2_KI270768v1_alt"    
 [43] "chr2_KI270769v1_alt"     "chr2_KI270770v1_alt"    
 [45] "chr2_KI270771v1_alt"     "chr2_KI270772v1_alt"    
 [47] "chr2_KI270773v1_alt"     "chr2_KI270774v1_alt"    
 [49] "chr2_KI270775v1_alt"     "chr2_KI270776v1_alt"    
 [51] "chr2_KI270893v1_alt"     "chr2_KI270894v1_alt"    
 [53] "chr3_GL383526v1_alt"     "chr3_JH636055v2_alt"    
 [55] "chr3_KI270777v1_alt"     "chr3_KI270778v1_alt"    
 [57] "chr3_KI270779v1_alt"     "chr3_KI270780v1_alt"    
 [59] "chr3_KI270781v1_alt"     "chr3_KI270782v1_alt"    
 [61] "chr3_KI270783v1_alt"     "chr3_KI270784v1_alt"    
 [63] "chr3_KI270895v1_alt"     "chr3_KI270924v1_alt"    
 [65] "chr3_KI270934v1_alt"     "chr3_KI270935v1_alt"    
 [67] "chr3_KI270936v1_alt"     "chr3_KI270937v1_alt"    
 [69] "chr4_GL000257v2_alt"     "chr4_GL383527v1_alt"    
 [71] "chr4_GL383528v1_alt"     "chr4_KI270785v1_alt"    
 [73] "chr4_KI270786v1_alt"     "chr4_KI270787v1_alt"    
 [75] "chr4_KI270788v1_alt"     "chr4_KI270789v1_alt"    
 [77] "chr4_KI270790v1_alt"     "chr4_KI270896v1_alt"    
 [79] "chr4_KI270925v1_alt"     "chr5_GL339449v2_alt"    
 [81] "chr5_GL383530v1_alt"     "chr5_GL383531v1_alt"    
 [83] "chr5_GL383532v1_alt"     "chr5_GL949742v1_alt"    
 [85] "chr5_KI270791v1_alt"     "chr5_KI270792v1_alt"    
 [87] "chr5_KI270793v1_alt"     "chr5_KI270794v1_alt"    
 [89] "chr5_KI270795v1_alt"     "chr5_KI270796v1_alt"    
 [91] "chr5_KI270897v1_alt"     "chr5_KI270898v1_alt"    
 [93] "chr6_GL000250v2_alt"     "chr6_GL000251v2_alt"    
 [95] "chr6_GL000252v2_alt"     "chr6_GL000253v2_alt"    
 [97] "chr6_GL000254v2_alt"     "chr6_GL000255v2_alt"    
 [99] "chr6_GL000256v2_alt"     "chr6_GL383533v1_alt"    
[101] "chr6_KB021644v2_alt"     "chr6_KI270758v1_alt"    
[103] "chr6_KI270797v1_alt"     "chr6_KI270798v1_alt"    
[105] "chr6_KI270799v1_alt"     "chr6_KI270800v1_alt"    
[107] "chr6_KI270801v1_alt"     "chr6_KI270802v1_alt"    
[109] "chr7_GL383534v2_alt"     "chr7_KI270803v1_alt"    
[111] "chr7_KI270804v1_alt"     "chr7_KI270805v1_alt"    
[113] "chr7_KI270806v1_alt"     "chr7_KI270807v1_alt"    
[115] "chr7_KI270808v1_alt"     "chr7_KI270809v1_alt"    
[117] "chr7_KI270899v1_alt"     "chr8_KI270810v1_alt"    
[119] "chr8_KI270811v1_alt"     "chr8_KI270812v1_alt"    
[121] "chr8_KI270813v1_alt"     "chr8_KI270814v1_alt"    
[123] "chr8_KI270815v1_alt"     "chr8_KI270816v1_alt"    
[125] "chr8_KI270817v1_alt"     "chr8_KI270818v1_alt"    
[127] "chr8_KI270819v1_alt"     "chr8_KI270820v1_alt"    
[129] "chr8_KI270821v1_alt"     "chr8_KI270822v1_alt"    
[131] "chr8_KI270900v1_alt"     "chr8_KI270901v1_alt"    
[133] "chr8_KI270926v1_alt"     "chr9_GL383539v1_alt"    
[135] "chr9_GL383540v1_alt"     "chr9_GL383541v1_alt"    
[137] "chr9_GL383542v1_alt"     "chr9_KI270823v1_alt"    
[139] "chr10_GL383545v1_alt"    "chr10_GL383546v1_alt"   
[141] "chr10_KI270824v1_alt"    "chr10_KI270825v1_alt"   
[143] "chr11_GL383547v1_alt"    "chr11_JH159136v1_alt"   
[145] "chr11_JH159137v1_alt"    "chr11_KI270826v1_alt"   
[147] "chr11_KI270827v1_alt"    "chr11_KI270829v1_alt"   
[149] "chr11_KI270830v1_alt"    "chr11_KI270831v1_alt"   
[151] "chr11_KI270832v1_alt"    "chr11_KI270902v1_alt"   
[153] "chr11_KI270903v1_alt"    "chr11_KI270927v1_alt"   
[155] "chr12_GL383549v1_alt"    "chr12_GL383550v2_alt"   
[157] "chr12_GL383551v1_alt"    "chr12_GL383552v1_alt"   
[159] "chr12_GL383553v2_alt"    "chr12_GL877875v1_alt"   
[161] "chr12_GL877876v1_alt"    "chr12_KI270833v1_alt"   
[163] "chr12_KI270834v1_alt"    "chr12_KI270835v1_alt"   
[165] "chr12_KI270836v1_alt"    "chr12_KI270837v1_alt"   
[167] "chr12_KI270904v1_alt"    "chr13_KI270838v1_alt"   
[169] "chr13_KI270839v1_alt"    "chr13_KI270840v1_alt"   
[171] "chr13_KI270841v1_alt"    "chr13_KI270842v1_alt"   
[173] "chr13_KI270843v1_alt"    "chr14_KI270844v1_alt"   
[175] "chr14_KI270845v1_alt"    "chr14_KI270846v1_alt"   
[177] "chr14_KI270847v1_alt"    "chr15_GL383554v1_alt"   
[179] "chr15_GL383555v2_alt"    "chr15_KI270848v1_alt"   
[181] "chr15_KI270849v1_alt"    "chr15_KI270850v1_alt"   
[183] "chr15_KI270851v1_alt"    "chr15_KI270852v1_alt"   
[185] "chr15_KI270905v1_alt"    "chr15_KI270906v1_alt"   
[187] "chr16_GL383556v1_alt"    "chr16_GL383557v1_alt"   
[189] "chr16_KI270853v1_alt"    "chr16_KI270854v1_alt"   
[191] "chr16_KI270855v1_alt"    "chr16_KI270856v1_alt"   
[193] "chr17_GL000258v2_alt"    "chr17_GL383563v3_alt"   
[195] "chr17_GL383564v2_alt"    "chr17_GL383565v1_alt"   
[197] "chr17_GL383566v1_alt"    "chr17_JH159146v1_alt"   
[199] "chr17_JH159147v1_alt"    "chr17_JH159148v1_alt"   
[201] "chr17_KI270857v1_alt"    "chr17_KI270858v1_alt"   
[203] "chr17_KI270859v1_alt"    "chr17_KI270860v1_alt"   
[205] "chr17_KI270861v1_alt"    "chr17_KI270862v1_alt"   
[207] "chr17_KI270907v1_alt"    "chr17_KI270908v1_alt"   
[209] "chr17_KI270909v1_alt"    "chr17_KI270910v1_alt"   
[211] "chr18_GL383567v1_alt"    "chr18_GL383568v1_alt"   
[213] "chr18_GL383569v1_alt"    "chr18_GL383570v1_alt"   
[215] "chr18_GL383571v1_alt"    "chr18_GL383572v1_alt"   
[217] "chr18_KI270863v1_alt"    "chr18_KI270864v1_alt"   
[219] "chr18_KI270911v1_alt"    "chr18_KI270912v1_alt"   
[221] "chr19_GL000209v2_alt"    "chr19_GL383573v1_alt"   
[223] "chr19_GL383574v1_alt"    "chr19_GL383575v2_alt"   
[225] "chr19_GL383576v1_alt"    "chr19_GL949746v1_alt"   
[227] "chr19_GL949747v2_alt"    "chr19_GL949748v2_alt"   
[229] "chr19_GL949749v2_alt"    "chr19_GL949750v2_alt"   
[231] "chr19_GL949751v2_alt"    "chr19_GL949752v1_alt"   
[233] "chr19_GL949753v2_alt"    "chr19_KI270865v1_alt"   
[235] "chr19_KI270866v1_alt"    "chr19_KI270867v1_alt"   
[237] "chr19_KI270868v1_alt"    "chr19_KI270882v1_alt"   
[239] "chr19_KI270883v1_alt"    "chr19_KI270884v1_alt"   
[241] "chr19_KI270885v1_alt"    "chr19_KI270886v1_alt"   
[243] "chr19_KI270887v1_alt"    "chr19_KI270888v1_alt"   
[245] "chr19_KI270889v1_alt"    "chr19_KI270890v1_alt"   
[247] "chr19_KI270891v1_alt"    "chr19_KI270914v1_alt"   
[249] "chr19_KI270915v1_alt"    "chr19_KI270916v1_alt"   
[251] "chr19_KI270917v1_alt"    "chr19_KI270918v1_alt"   
[253] "chr19_KI270919v1_alt"    "chr19_KI270920v1_alt"   
[255] "chr19_KI270921v1_alt"    "chr19_KI270922v1_alt"   
[257] "chr19_KI270923v1_alt"    "chr19_KI270929v1_alt"   
[259] "chr19_KI270930v1_alt"    "chr19_KI270931v1_alt"   
[261] "chr19_KI270932v1_alt"    "chr19_KI270933v1_alt"   
[263] "chr19_KI270938v1_alt"    "chr20_GL383577v2_alt"   
[265] "chr20_KI270869v1_alt"    "chr20_KI270870v1_alt"   
[267] "chr20_KI270871v1_alt"    "chr21_GL383578v2_alt"   
[269] "chr21_GL383579v2_alt"    "chr21_GL383580v2_alt"   
[271] "chr21_GL383581v2_alt"    "chr21_KI270872v1_alt"   
[273] "chr21_KI270873v1_alt"    "chr21_KI270874v1_alt"   
[275] "chr22_GL383582v2_alt"    "chr22_GL383583v2_alt"   
[277] "chr22_KB663609v1_alt"    "chr22_KI270875v1_alt"   
[279] "chr22_KI270876v1_alt"    "chr22_KI270877v1_alt"   
[281] "chr22_KI270878v1_alt"    "chr22_KI270879v1_alt"   
[283] "chr22_KI270928v1_alt"    "chrX_KI270880v1_alt"    
[285] "chrX_KI270881v1_alt"     "chrX_KI270913v1_alt"    
[287] "chr1_KI270706v1_random"  "chr1_KI270707v1_random" 
[289] "chr1_KI270708v1_random"  "chr1_KI270709v1_random" 
[291] "chr1_KI270710v1_random"  "chr1_KI270711v1_random" 
[293] "chr1_KI270712v1_random"  "chr1_KI270713v1_random" 
[295] "chr1_KI270714v1_random"  "chr2_KI270715v1_random" 
[297] "chr2_KI270716v1_random"  "chr3_GL000221v1_random" 
[299] "chr4_GL000008v2_random"  "chr5_GL000208v1_random" 
[301] "chr9_KI270717v1_random"  "chr9_KI270718v1_random" 
[303] "chr9_KI270719v1_random"  "chr9_KI270720v1_random" 
[305] "chr11_KI270721v1_random" "chr14_GL000009v2_random"
[307] "chr14_GL000194v1_random" "chr14_GL000225v1_random"
[309] "chr14_KI270722v1_random" "chr14_KI270723v1_random"
[311] "chr14_KI270724v1_random" "chr14_KI270725v1_random"
[313] "chr14_KI270726v1_random" "chr15_KI270727v1_random"
[315] "chr16_KI270728v1_random" "chr17_GL000205v2_random"
[317] "chr17_KI270729v1_random" "chr17_KI270730v1_random"
[319] "chr22_KI270731v1_random" "chr22_KI270732v1_random"
[321] "chr22_KI270733v1_random" "chr22_KI270734v1_random"
[323] "chr22_KI270735v1_random" "chr22_KI270736v1_random"
[325] "chr22_KI270737v1_random" "chr22_KI270738v1_random"
[327] "chr22_KI270739v1_random" "chrY_KI270740v1_random" 
[329] "chrUn_GL000195v1"        "chrUn_GL000213v1"       
[331] "chrUn_GL000214v1"        "chrUn_GL000216v2"       
[333] "chrUn_GL000218v1"        "chrUn_GL000219v1"       
[335] "chrUn_GL000220v1"        "chrUn_GL000224v1"       
[337] "chrUn_GL000226v1"        "chrUn_KI270302v1"       
[339] "chrUn_KI270303v1"        "chrUn_KI270304v1"       
[341] "chrUn_KI270305v1"        "chrUn_KI270310v1"       
[343] "chrUn_KI270311v1"        "chrUn_KI270312v1"       
[345] "chrUn_KI270315v1"        "chrUn_KI270316v1"       
[347] "chrUn_KI270317v1"        "chrUn_KI270320v1"       
[349] "chrUn_KI270322v1"        "chrUn_KI270329v1"       
[351] "chrUn_KI270330v1"        "chrUn_KI270333v1"       
[353] "chrUn_KI270334v1"        "chrUn_KI270335v1"       
[355] "chrUn_KI270336v1"        "chrUn_KI270337v1"       
[357] "chrUn_KI270338v1"        "chrUn_KI270340v1"       
[359] "chrUn_KI270362v1"        "chrUn_KI270363v1"       
[361] "chrUn_KI270364v1"        "chrUn_KI270366v1"       
[363] "chrUn_KI270371v1"        "chrUn_KI270372v1"       
[365] "chrUn_KI270373v1"        "chrUn_KI270374v1"       
[367] "chrUn_KI270375v1"        "chrUn_KI270376v1"       
[369] "chrUn_KI270378v1"        "chrUn_KI270379v1"       
[371] "chrUn_KI270381v1"        "chrUn_KI270382v1"       
[373] "chrUn_KI270383v1"        "chrUn_KI270384v1"       
[375] "chrUn_KI270385v1"        "chrUn_KI270386v1"       
[377] "chrUn_KI270387v1"        "chrUn_KI270388v1"       
[379] "chrUn_KI270389v1"        "chrUn_KI270390v1"       
[381] "chrUn_KI270391v1"        "chrUn_KI270392v1"       
[383] "chrUn_KI270393v1"        "chrUn_KI270394v1"       
[385] "chrUn_KI270395v1"        "chrUn_KI270396v1"       
[387] "chrUn_KI270411v1"        "chrUn_KI270412v1"       
[389] "chrUn_KI270414v1"        "chrUn_KI270417v1"       
[391] "chrUn_KI270418v1"        "chrUn_KI270419v1"       
[393] "chrUn_KI270420v1"        "chrUn_KI270422v1"       
[395] "chrUn_KI270423v1"        "chrUn_KI270424v1"       
[397] "chrUn_KI270425v1"        "chrUn_KI270429v1"       
[399] "chrUn_KI270435v1"        "chrUn_KI270438v1"       
[401] "chrUn_KI270442v1"        "chrUn_KI270448v1"       
[403] "chrUn_KI270465v1"        "chrUn_KI270466v1"       
[405] "chrUn_KI270467v1"        "chrUn_KI270468v1"       
[407] "chrUn_KI270507v1"        "chrUn_KI270508v1"       
[409] "chrUn_KI270509v1"        "chrUn_KI270510v1"       
[411] "chrUn_KI270511v1"        "chrUn_KI270512v1"       
[413] "chrUn_KI270515v1"        "chrUn_KI270516v1"       
[415] "chrUn_KI270517v1"        "chrUn_KI270518v1"       
[417] "chrUn_KI270519v1"        "chrUn_KI270521v1"       
[419] "chrUn_KI270522v1"        "chrUn_KI270528v1"       
[421] "chrUn_KI270529v1"        "chrUn_KI270530v1"       
[423] "chrUn_KI270538v1"        "chrUn_KI270539v1"       
[425] "chrUn_KI270544v1"        "chrUn_KI270548v1"       
[427] "chrUn_KI270579v1"        "chrUn_KI270580v1"       
[429] "chrUn_KI270581v1"        "chrUn_KI270582v1"       
[431] "chrUn_KI270583v1"        "chrUn_KI270584v1"       
[433] "chrUn_KI270587v1"        "chrUn_KI270588v1"       
[435] "chrUn_KI270589v1"        "chrUn_KI270590v1"       
[437] "chrUn_KI270591v1"        "chrUn_KI270593v1"       
[439] "chrUn_KI270741v1"        "chrUn_KI270742v1"       
[441] "chrUn_KI270743v1"        "chrUn_KI270744v1"       
[443] "chrUn_KI270745v1"        "chrUn_KI270746v1"       
[445] "chrUn_KI270747v1"        "chrUn_KI270748v1"       
[447] "chrUn_KI270749v1"        "chrUn_KI270750v1"       
[449] "chrUn_KI270751v1"        "chrUn_KI270752v1"       
[451] "chrUn_KI270753v1"        "chrUn_KI270754v1"       
[453] "chrUn_KI270755v1"        "chrUn_KI270756v1"       
[455] "chrUn_KI270757v1"        "chr1_KN196472v1_fix"    
[457] "chr1_KN196473v1_fix"     "chr1_KN196474v1_fix"    
[459] "chr1_KN538360v1_fix"     "chr1_KN538361v1_fix"    
[461] "chr1_KQ031383v1_fix"     "chr1_KZ208906v1_fix"    
[463] "chr1_KZ559100v1_fix"     "chr1_MU273333v1_fix"    
[465] "chr1_MU273334v1_fix"     "chr1_MU273335v1_fix"    
[467] "chr1_MU273336v1_fix"     "chr2_KN538362v1_fix"    
[469] "chr2_KN538363v1_fix"     "chr2_KQ031384v1_fix"    
[471] "chr2_ML143341v1_fix"     "chr2_ML143342v1_fix"    
[473] "chr2_MU273341v1_fix"     "chr2_MU273342v1_fix"    
[475] "chr2_MU273343v1_fix"     "chr2_MU273344v1_fix"    
[477] "chr2_MU273345v1_fix"     "chr3_KN196475v1_fix"    
[479] "chr3_KN196476v1_fix"     "chr3_KN538364v1_fix"    
[481] "chr3_KQ031385v1_fix"     "chr3_KQ031386v1_fix"    
[483] "chr3_KV766192v1_fix"     "chr3_KZ559104v1_fix"    
[485] "chr3_MU273346v1_fix"     "chr3_MU273347v1_fix"    
[487] "chr3_MU273348v1_fix"     "chr4_KQ983257v1_fix"    
[489] "chr4_ML143344v1_fix"     "chr4_ML143345v1_fix"    
[491] "chr4_ML143346v1_fix"     "chr4_ML143347v1_fix"    
[493] "chr4_ML143348v1_fix"     "chr4_ML143349v1_fix"    
[495] "chr4_MU273350v1_fix"     "chr4_MU273351v1_fix"    
[497] "chr5_KV575244v1_fix"     "chr5_ML143350v1_fix"    
[499] "chr5_MU273352v1_fix"     "chr5_MU273353v1_fix"    
[501] "chr5_MU273354v1_fix"     "chr5_MU273355v1_fix"    
[503] "chr6_KN196478v1_fix"     "chr6_KQ031387v1_fix"    
[505] "chr6_KQ090016v1_fix"     "chr6_KV766194v1_fix"    
[507] "chr6_KZ208911v1_fix"     "chr6_ML143351v1_fix"    
[509] "chr7_KQ031388v1_fix"     "chr7_KV880764v1_fix"    
[511] "chr7_KV880765v1_fix"     "chr7_KZ208912v1_fix"    
[513] "chr7_ML143352v1_fix"     "chr8_KV880766v1_fix"    
[515] "chr8_KV880767v1_fix"     "chr8_KZ208914v1_fix"    
[517] "chr8_KZ208915v1_fix"     "chr8_MU273359v1_fix"    
[519] "chr8_MU273360v1_fix"     "chr8_MU273361v1_fix"    
[521] "chr8_MU273362v1_fix"     "chr8_MU273363v1_fix"    
[523] "chr9_KN196479v1_fix"     "chr9_ML143353v1_fix"    
[525] "chr9_MU273364v1_fix"     "chr9_MU273365v1_fix"    
[527] "chr9_MU273366v1_fix"     "chr10_KN196480v1_fix"   
[529] "chr10_KN538365v1_fix"    "chr10_KN538366v1_fix"   
[531] "chr10_KN538367v1_fix"    "chr10_KQ090021v1_fix"   
[533] "chr10_ML143354v1_fix"    "chr10_ML143355v1_fix"   
[535] "chr10_MU273367v1_fix"    "chr11_KN196481v1_fix"   
[537] "chr11_KQ090022v1_fix"    "chr11_KQ759759v1_fix"   
[539] "chr11_KQ759759v2_fix"    "chr11_KV766195v1_fix"   
[541] "chr11_KZ559108v1_fix"    "chr11_KZ559109v1_fix"   
[543] "chr11_ML143356v1_fix"    "chr11_ML143357v1_fix"   
[545] "chr11_ML143358v1_fix"    "chr11_ML143359v1_fix"   
[547] "chr11_ML143360v1_fix"    "chr11_MU273369v1_fix"   
[549] "chr11_MU273370v1_fix"    "chr11_MU273371v1_fix"   
[551] "chr12_KN196482v1_fix"    "chr12_KN538369v1_fix"   
[553] "chr12_KN538370v1_fix"    "chr12_KQ759760v1_fix"   
[555] "chr12_KZ208916v1_fix"    "chr12_KZ208917v1_fix"   
[557] "chr12_ML143361v1_fix"    "chr12_ML143362v1_fix"   
[559] "chr12_MU273372v1_fix"    "chr13_KN196483v1_fix"   
[561] "chr13_KN538371v1_fix"    "chr13_KN538372v1_fix"   
[563] "chr13_KN538373v1_fix"    "chr13_ML143363v1_fix"   
[565] "chr13_ML143364v1_fix"    "chr13_ML143365v1_fix"   
[567] "chr13_ML143366v1_fix"    "chr14_KZ208920v1_fix"   
[569] "chr14_ML143367v1_fix"    "chr14_MU273373v1_fix"   
[571] "chr15_KN538374v1_fix"    "chr15_ML143369v1_fix"   
[573] "chr15_ML143370v1_fix"    "chr15_ML143371v1_fix"   
[575] "chr15_ML143372v1_fix"    "chr15_MU273374v1_fix"   
[577] "chr16_KV880768v1_fix"    "chr16_KZ559113v1_fix"   
[579] "chr16_ML143373v1_fix"    "chr16_MU273376v1_fix"   
[581] "chr16_MU273377v1_fix"    "chr17_KV575245v1_fix"   
[583] "chr17_KV766196v1_fix"    "chr17_ML143374v1_fix"   
[585] "chr17_ML143375v1_fix"    "chr17_MU273379v1_fix"   
[587] "chr17_MU273380v1_fix"    "chr17_MU273381v1_fix"   
[589] "chr17_MU273382v1_fix"    "chr17_MU273383v1_fix"   
[591] "chr18_KQ090028v1_fix"    "chr18_KZ208922v1_fix"   
[593] "chr18_KZ559115v1_fix"    "chr19_KN196484v1_fix"   
[595] "chr19_KQ458386v1_fix"    "chr19_ML143376v1_fix"   
[597] "chr19_MU273384v1_fix"    "chr19_MU273385v1_fix"   
[599] "chr19_MU273386v1_fix"    "chr20_MU273388v1_fix"   
[601] "chr20_MU273389v1_fix"    "chr21_ML143377v1_fix"   
[603] "chr21_MU273390v1_fix"    "chr21_MU273391v1_fix"   
[605] "chr21_MU273392v1_fix"    "chr22_KQ759762v1_fix"   
[607] "chr22_KQ759762v2_fix"    "chr22_ML143378v1_fix"   
[609] "chr22_ML143379v1_fix"    "chr22_ML143380v1_fix"   
[611] "chrX_ML143381v1_fix"     "chrX_ML143382v1_fix"    
[613] "chrX_ML143383v1_fix"     "chrX_ML143384v1_fix"    
[615] "chrX_ML143385v1_fix"     "chrX_MU273393v1_fix"    
[617] "chrX_MU273394v1_fix"     "chrY_KN196487v1_fix"    
[619] "chrY_KZ208923v1_fix"     "chrY_KZ208924v1_fix"    
[621] "chrY_MU273398v1_fix"     "chr1_KQ458382v1_alt"    
[623] "chr1_KQ458383v1_alt"     "chr1_KQ458384v1_alt"    
[625] "chr1_KQ983255v1_alt"     "chr1_KV880763v1_alt"    
[627] "chr1_KZ208904v1_alt"     "chr1_KZ208905v1_alt"    
[629] "chr1_MU273330v1_alt"     "chr1_MU273331v1_alt"    
[631] "chr1_MU273332v1_alt"     "chr2_KQ983256v1_alt"    
[633] "chr2_KZ208907v1_alt"     "chr2_KZ208908v1_alt"    
[635] "chr2_MU273337v1_alt"     "chr2_MU273338v1_alt"    
[637] "chr2_MU273339v1_alt"     "chr2_MU273340v1_alt"    
[639] "chr3_KZ208909v1_alt"     "chr3_KZ559101v1_alt"    
[641] "chr3_KZ559102v1_alt"     "chr3_KZ559103v1_alt"    
[643] "chr3_KZ559105v1_alt"     "chr3_ML143343v1_alt"    
[645] "chr4_KQ090013v1_alt"     "chr4_KQ090014v1_alt"    
[647] "chr4_KQ090015v1_alt"     "chr4_KQ983258v1_alt"    
[649] "chr4_KV766193v1_alt"     "chr4_MU273349v1_alt"    
[651] "chr5_KN196477v1_alt"     "chr5_KV575243v1_alt"    
[653] "chr5_KZ208910v1_alt"     "chr5_MU273356v1_alt"    
[655] "chr6_KQ090017v1_alt"     "chr6_MU273357v1_alt"    
[657] "chr7_KZ208913v1_alt"     "chr7_KZ559106v1_alt"    
[659] "chr7_MU273358v1_alt"     "chr8_KZ559107v1_alt"    
[661] "chr9_KQ090018v1_alt"     "chr9_KQ090019v1_alt"    
[663] "chr10_KQ090020v1_alt"    "chr11_KN538368v1_alt"   
[665] "chr11_KZ559110v1_alt"    "chr11_KZ559111v1_alt"   
[667] "chr11_MU273368v1_alt"    "chr12_KQ090023v1_alt"   
[669] "chr12_KZ208918v1_alt"    "chr12_KZ559112v1_alt"   
[671] "chr13_KQ090024v1_alt"    "chr13_KQ090025v1_alt"   
[673] "chr14_KZ208919v1_alt"    "chr14_ML143368v1_alt"   
[675] "chr15_KQ031389v1_alt"    "chr15_MU273375v1_alt"   
[677] "chr16_KQ031390v1_alt"    "chr16_KQ090026v1_alt"   
[679] "chr16_KQ090027v1_alt"    "chr16_KZ208921v1_alt"   
[681] "chr17_KV766197v1_alt"    "chr17_KV766198v1_alt"   
[683] "chr17_KZ559114v1_alt"    "chr17_MU273378v1_alt"   
[685] "chr18_KQ458385v1_alt"    "chr18_KZ559116v1_alt"   
[687] "chr19_KV575246v1_alt"    "chr19_KV575247v1_alt"   
[689] "chr19_KV575248v1_alt"    "chr19_KV575249v1_alt"   
[691] "chr19_KV575250v1_alt"    "chr19_KV575251v1_alt"   
[693] "chr19_KV575252v1_alt"    "chr19_KV575253v1_alt"   
[695] "chr19_KV575254v1_alt"    "chr19_KV575255v1_alt"   
[697] "chr19_KV575256v1_alt"    "chr19_KV575257v1_alt"   
[699] "chr19_KV575258v1_alt"    "chr19_KV575259v1_alt"   
[701] "chr19_KV575260v1_alt"    "chr19_MU273387v1_alt"   
[703] "chr22_KN196485v1_alt"    "chr22_KN196486v1_alt"   
[705] "chr22_KQ458387v1_alt"    "chr22_KQ458388v1_alt"   
[707] "chr22_KQ759761v1_alt"    "chrX_KV766199v1_alt"    
[709] "chrX_MU273395v1_alt"     "chrX_MU273396v1_alt"    
[711] "chrX_MU273397v1_alt"    
```

Similarly, the function `seqinfo()` can be used to get the full sequence
information stored in the object.


``` r
seqinfo(genome)
```

``` output
Seqinfo object with 711 sequences (1 circular) from hg38 genome:
  seqnames             seqlengths isCircular genome
  chr1                  248956422      FALSE   hg38
  chr2                  242193529      FALSE   hg38
  chr3                  198295559      FALSE   hg38
  chr4                  190214555      FALSE   hg38
  chr5                  181538259      FALSE   hg38
  ...                         ...        ...    ...
  chr22_KQ759761v1_alt     145162      FALSE   hg38
  chrX_KV766199v1_alt      188004      FALSE   hg38
  chrX_MU273395v1_alt      619716      FALSE   hg38
  chrX_MU273396v1_alt      294119      FALSE   hg38
  chrX_MU273397v1_alt      330493      FALSE   hg38
```

Finally, the nature of BSgenome objects being akin to a list of sequences,
the operators `$` and `[[]]` can both be used to extract individual sequences
from the BSgenome object.


``` r
genome$chr1
```

``` output
248956422-letter MaskedDNAString object (# for masking)
seq: ####################################...####################################
masks:
  maskedwidth  maskedratio active names                               desc
1    18470101 7.419010e-02   TRUE AGAPS                      assembly gaps
2        5309 2.132502e-05   TRUE   AMB           intra-contig ambiguities
3   119060341 4.782377e-01  FALSE    RM                       RepeatMasker
4     1647959 6.619468e-03  FALSE   TRF Tandem Repeats Finder [period<=12]
all masks together:
  maskedwidth maskedratio
    137685771   0.5530517
all active masks together:
  maskedwidth maskedratio
     18475410  0.07421142
```

For instance, we can extract the sequence of the Y chromosome and assign it
to a new object `chrY`.


``` r
chrY <- genome[["chrY"]]
```

### Using genome sequences

From this point, genome sequences can be treated very much like biological
strings (e.g. `DNAString`) described earlier, in the
*[Biostrings](https://bioconductor.org/packages/3.19/Biostrings)* package.

For instance, the function `countPattern()` can be used to count the number of
occurences of a given pattern in a given genome sequence.


``` r
countPattern(pattern = "CANNTG", subject = chrY, fixed = FALSE)
```

``` output
[1] 141609
```

:::::::::::::::::::::::::::::::::::::::::  callout

### Note

In the example above, the argument `fixed = FALSE` is used to indicate that the
pattern contain [IUPAC ambiguity codes][external-iupac].

::::::::::::::::::::::::::::::::::::::::::::::::::

[glossary-s4-class]: reference.html#s4-class
[crossref-s4]: 05-s4.html
[external-iupac]: https://en.wikipedia.org/wiki/Nucleic_acid_notation#IUPAC_notation
[iupac-alphabet]: https://www.bioinformatics.org/sms/iupac.html
[external-truseq]: https://emea.illumina.com/products/by-type/sequencing-kits/library-prep-kits.html
[orf-finder]: https://www.ncbi.nlm.nih.gov/orffinder/


:::::::::::::::::::::::::::::::::::::::: keypoints

- The `Biostrings` package defines classes to represent sequences of nucleotides and amino acids.
- The `Biostrings` package also defines methods to efficiently process biological sequences.
- The `BSgenome` package provides genome sequences for a range of model organisms immediately available as Bioconductor objects.

::::::::::::::::::::::::::::::::::::::::::::::::::


