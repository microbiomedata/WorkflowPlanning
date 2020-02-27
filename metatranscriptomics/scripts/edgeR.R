#!/usr/bin/env Rscript

library(edgeR)
library(dplyr)
library(optparse)


option_list <- list(
    make_option(c("-r", "--reads_table"), action = "store",
              help = "reads table generated from featureCounts"),
    make_option(c("-n", "--name"), action = "store",
              help = "name of feature from gff file that was chosen to represent each feature"),
    make_option(c("-s", "--sample"), action = "store",
              help = "name of sample which corresponds to count column as well"),
    make_option(c("-o", "--out_tbl"), action = "store",
              help = "an output directory where all outputs will be stored")
)

opt <- parse_args(OptionParser(option_list = option_list))

#==============================================================================#
reads_file <- opt$reads_table
feature_name <- opt$name
out_tbl <- opt$out_tbl
#==============================================================================#

# read the output of featureCounts
col_names = c("Geneid", "Chr", "Start", "End", "Strand", "Length", as.character(opt$sample))
read_counts <- read.table(reads_file, sep = "\t", header = TRUE, comment.char = "#",
                          col.names=col_names)
read_counts_non0 <- dplyr::filter(read_counts, !!as.symbol(opt$sample) > 0)

#==============================================================================#
# convert first column to row names
row.names(read_counts_non0) <- read_counts_non0[, 1]
#==============================================================================#
# # # get gene information
gene.info <- read_counts_non0[, c(1:6)]
# print(head(gene.info))

group_table = data.frame(sample=as.character(opt$sample), group="x")
row.names(group_table) <- as.character(group_table[, 1])

edger_dge <- edgeR::DGEList(counts = read_counts_non0[, -c(1:6)], group = group_table$group,
                            remove.zeros = TRUE, genes = gene.info)

if (0 %in% colSums(edger_dge$counts)) {
        print("One of the sample does not have any reads mapped to it, so no further analysis will be done!")
} else {

        ############### calculate RPKM and CPM #########################################
        rpkm_results <- edgeR::rpkm(edger_dge)
        cpm_results <- edgeR::cpm(edger_dge)
        colnames(rpkm_results) <- c("RPKM")
        rpkm_results = merge(edger_dge$genes,rpkm_results, by=0, all=TRUE)
        rpkm_results$Row.names = NULL
        write.csv(rpkm_results, file = out_tbl)
        ################################################################################
    }
