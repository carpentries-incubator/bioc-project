if (!file.exists("data/uniprot-filtered-reviewed_human_96.fasta.gz")) {
    dir.create("data", showWarnings = FALSE)
    download.file(
        url = "https://github.com/Bioconductor/bioconductor-teaching/raw/master/data/UniProt/uniprot-filtered-reviewed_human_96.fasta.gz",
        destfile = "data/uniprot-filtered-reviewed_human_96.fasta.gz")
}
