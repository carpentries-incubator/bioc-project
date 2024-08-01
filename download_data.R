dir.create("data", showWarnings = FALSE)

download.file(
    url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/master/data/TrimmomaticAdapters/TruSeq3-PE-2.fa",
    destfile = "data/TruSeq3-PE-2.fa"
)
download.file(
    url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/master/data/ActbGtf/actb.gtf",
    destfile = "data/actb.gtf"
)
download.file(
    url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/master/data/ActbOrf/actb_orfs.fasta",
    destfile = "data/actb_orfs.fasta"
)
download.file(
  url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/devel/data/SummarizedExperiment/counts.csv",
  destfile = "data/counts.csv"
)
download.file(
  url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/devel/data/SummarizedExperiment/gene_metadata.csv",
  destfile = "data/gene_metadata.csv"
)
download.file(
  url = "https://raw.githubusercontent.com/Bioconductor/bioconductor-teaching/devel/data/SummarizedExperiment/sample_metadata.csv",
  destfile = "data/sample_metadata.csv"
)
