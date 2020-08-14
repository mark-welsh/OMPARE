#############################
# Function to plot Expression
#############################

plotGenes <- function(myRNASeqAnalysisOut = RNASeqAnalysisOut) {
  geneData <- myRNASeqAnalysisOut[[1]][[2]]
  geneData <- geneData %>%
    rownames_to_column("Gene") %>%
    mutate(Direction = ifelse(Z_Score > 0, "Up", "Down")) %>%
    arrange(Z_Score)
  geneData$Gene <- factor(geneData$Gene, levels = geneData$Gene)
  p <- ggplot(geneData, aes(Gene, y = Z_Score, fill = Direction)) + 
    geom_bar(stat="identity") + coord_flip() + theme_bw() + 
    xlab("Gene Symbol") + scale_fill_manual(values = c("Down" = "forest green", 
                                                       "Up" = "red"))
  return(p)
}

plotFoldChange <- function(dgd_gene_expression = NULL) {
  geneData <- read.table(dgd_gene_expression, header = TRUE, sep = '\t')
  geneData$gene_sym <- make.names(geneData$gene_sym, unique = TRUE)
  log2_column <- tail(colnames(geneData), n=1)
  geneData <- geneData %>%
    remove_rownames() %>%
    column_to_rownames(var="gene_sym") %>%
    rownames_to_column("Gene") %>%
    mutate(Direction = ifelse(get(log2_column) >= 1, "Up", "Down")) %>%
    arrange(get(log2_column))
  geneData$Gene <- factor(geneData$Gene, levels = geneData$Gene)
  top20_geneData <- head(geneData, 20)
  top20_geneData <- rbind(top20_geneData, tail(geneData, 20))
  p <- ggplot(top20_geneData, aes(Gene, y = get(log2_column), fill = Direction)) +
    geom_bar(stat="identity") + coord_flip() + theme_bw() + ylab(log2_column) +
    xlab("Gene Symbol") + scale_fill_manual(values = c("Down" = "forest green",
                                                       "Up" = "red"))
  return(p)
}
