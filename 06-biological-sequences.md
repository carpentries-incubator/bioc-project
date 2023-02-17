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
First, we check that the *[BiocManager](https://bioconductor.org/packages/3.16/BiocManager)* package is installed before trying to use it; otherwise we install it.
Then we use the `BiocManager::install()` function to install the necessary packages.


```r
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


```{.output}
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

In the Bioconductor project, the *[Biostrings](https://bioconductor.org/packages/3.16/Biostrings)* package
implements S4 classes to represent biological sequences as S4 objects, e.g.
`DNAString` for sequences of nucleotides in deoxyribonucleic acid polymers, and
`AAString` for sequences of amino acids in protein polymers.
Those S4 classes provide memory-efficient containers for character strings,
automatic validity-checking functionality for each class of biological
molecules, and methods implementing various string matching algorithms and other
utilities for fast manipulation and processing of large biological sequences or
sets of sequences.

A short presentation of the basic classes defined in the
*[Biostrings](https://bioconductor.org/packages/3.16/Biostrings)* package is available in one of the package
vignettes, accessible as `vignette("Biostrings2Classes")`, while more detailed
information is provided in the other package vignettes, accessible as
`browseVignettes("Biostrings")`.

### First steps

To get started, we load the package.


```r
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


```r
DNAString("ATCG")
```

```{.output}
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


```r
DNAString("ATCGZ")
```

```{.error}
Error in .Call2("new_XString_from_CHARACTER", class(x0), string, start, : key 90 (char 'Z') not in lookup table
```

Specifically, the [IUPAC Extended Genetic Alphabet][iupac-alphabet] defines
ambiguity codes that represent sets of nucleotides, in a way similar to regular
expressions.
The `IUPAC_CODE_MAP` named character vector contains the mapping from the IUPAC
nucleotide ambiguity codes to their meaning.


```r
IUPAC_CODE_MAP
```

```{.output}
     A      C      G      T      M      R      W      S      Y      K      V 
   "A"    "C"    "G"    "T"   "AC"   "AG"   "AT"   "CG"   "CT"   "GT"  "ACG" 
     H      D      B      N 
 "ACT"  "AGT"  "CGT" "ACGT" 
```

Any of those nucleotide codes are allowed in the sequence of a `DNAString`
object.
For instance, the symbol `M` represents either of the two nucleotides `A` or `C`
at a given position in a nucleic acid sequence.


```r
DNAString("ATCGM")
```

```{.output}
5-letter DNAString object
seq: ATCGM
```

In particular, pattern matching methods implemented in the
*[Biostrings](https://bioconductor.org/packages/3.16/Biostrings)* package recognize the meaning of ambiguity
codes for each class of biological sequence, allowing them to efficiently match
motifs queried by users without the need to design elaborate regular
expressions.
For instance, the method `matchPattern()` takes a `pattern=` and a `subject=`
argument, and returns a `Views` object that reports and displays any match of
the `pattern` expression at any position in the `subject` sequence.

Note that the default option `fixed = TRUE` instructs the method to match the
query exactly -- i.e., ignore ambiguity codes -- which in this case does not report
any exact match.


```r
dna1 <- DNAString("ATCGCTTTGA")
matchPattern("GM", dna1, fixed = TRUE)
```

```{.output}
Views on a 10-letter DNAString subject
subject: ATCGCTTTGA
views: NONE
```

Instead, to indicate that the pattern includes some ambiguity code, the argument
`fixed` must be set to `FALSE`.


```r
matchPattern("GM", dna1, fixed = FALSE)
```

```{.output}
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


```r
truseq_adapters <- readDNAStringSet(filepath = "data/TruSeq3-PE-2.fa")
truseq_adapters
```

```{.output}
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

The *[Biostrings](https://bioconductor.org/packages/3.16/Biostrings)* package provides several functions to
process and manipulate classes of biological strings.
For example, we have come across `matchPattern()` and `countPattern()` earlier
in this episode.

Another example of a method that can be applied to biological strings is
`letterFrequency()`, to compute the frequency of letters in a biological
sequence.


```r
letterFrequency(truseq_adapters, letters = DNA_ALPHABET)
```

```{.output}
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
acids, provided by the *[Biostrings](https://bioconductor.org/packages/3.16/Biostrings)* package in a
built-in object called `DNA_ALPHABET`.

### Amino acid sequences

Similarly to the `DNAString` and `DNAStringSet` classes, the classes `AAString` and `AAStringSet` allow efficient storage and manipulation of a long amino acid sequence, or a set thereof.

Similarly to built-in objects for the DNA alphabet, the built-in objects `AA_ALPHABET`, `AA_STANDARD` and `AA_PROTEINOGENIC` describe different subsets of the alphabet of valid symbols for amino acid sequences.

For instance, the `AA_ALPHABET` object describes the set of symbols in the full amino acid alphabet.


```r
AA_ALPHABET
```

```{.output}
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

For instance, the *[Biostrings](https://bioconductor.org/packages/3.16/Biostrings)* package provides multiple implementations of a generic called `translate()`,  for translating DNA or RNA sequences into amino acid sequences.
The set of input objects supported by the generic `translate()` can be listed using the function `showMethods()`, from the CRAN package *[methods](https://CRAN.R-project.org/package=methods)*.


```r
showMethods("translate")
```

```{.output}
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


```r
actb_orf_nih <- readDNAStringSet("data/actb_orfs.fasta")
actb_orf_nih
```

```{.output}
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


```r
actb_aa <- translate(actb_orf_nih)
actb_aa
```

```{.output}
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


