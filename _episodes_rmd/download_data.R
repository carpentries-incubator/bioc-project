dir.create("data", showWarnings = FALSE)

download.file(
    url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/master/data/TrimmomaticAdapters/TruSeq3-PE-2.fa", 
    destfile = "data/TruSeq3-PE-2.fa"
)
