#############################
# Read Patient-specific Data
# Save all data to global env
#############################

source('code/load_reference.R') # load reference data

readData <- function(topDir, fusion_method = c("star","arriba"), snv_pattern = "all"){
  
  # patient sample info (at most one with .txt extension)
  # assign n/a if no clinical info is present
  sampleInfo <- list.files(path = topDir, pattern = "patient_report.txt", recursive = T, full.names = T)
  if(length(sampleInfo) == 1){
    sampleInfo <- read.delim(sampleInfo, stringsAsFactors = F)
    assign("sampleInfo", sampleInfo, envir = globalenv())
  }
  
  # expression data: TPM (can be only 1 per patient with .genes.results)
  expDat <- list.files(path = topDir, pattern = "*.genes.results*", recursive = TRUE, full.names = T)
  if(length(expDat) == 1){
    expData <- read.delim(expDat)
    expData.full <- expData %>% 
      mutate(gene_id = str_replace(gene_id, "_PAR_Y_", "_"))  %>%
      separate(gene_id, c("gene_id", "gene_symbol"), sep = "\\_", extra = "merge") %>%
      mutate(gene_id = gsub('[.].*', '', gene_id))  %>%
      unique()
    expData <- expData.full %>% 
      arrange(desc(TPM)) %>% 
      distinct(gene_symbol, .keep_all = TRUE) %>%
      mutate(!!sampleInfo$subjectID := TPM) %>%
      dplyr::select(!!sampleInfo$subjectID, gene_id, gene_symbol) %>%
      unique()
    rownames(expData) <- expData$gene_symbol
    assign("expData", expData, envir = globalenv())
    
    expData.counts <- expData.full %>%
      filter(expData.full$gene_id  %in% expData$gene_id) %>%
      mutate(!!sampleInfo$subjectID := expected_count) %>%
      dplyr::select(!!sampleInfo$subjectID, gene_id, gene_symbol) %>%
      unique()
    rownames(expData.counts) <- expData.counts$gene_symbol
    assign("expData.counts", expData.counts, envir = globalenv())
  }
}

