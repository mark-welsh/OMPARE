#####################
# Format TCGA data
#####################

# TCGA specific
tcga.gbm.clinData <- tcga.gbm.clinData %>%
  dplyr::select(-c(overall_survival_time_in_days, vital_status)) %>%
  as.data.frame()
pat.clinData <- pnoc008.clinData[,c(rep('subjectID', 2), 'sex', 'AgeAtCollection', 'ethnicity', rep('tumorType',2), 'study_id')] 
colnames(pat.clinData) <- colnames(tcga.gbm.clinData)
tcga.gbm.clinData <- rbind(tcga.gbm.clinData, pat.clinData)
rownames(tcga.gbm.clinData) <- tcga.gbm.clinData$sample_barcode

# Combine tcga.gbm and PNOC Patients
combGenes <- intersect(rownames(tcga.gbm.mat), rownames(pnoc008.data))
tcga.gbm.mat <- cbind(tcga.gbm.mat[combGenes,], pnoc008.data[combGenes,])

# keep full matrix for ImmuneProfile.R (not required for TCGA for now)
# tcga.gbm.mat.all <- tcga.gbm.mat 

# Now remove genes that have less 20 FPKM
maxVals <- apply(tcga.gbm.mat, FUN = max, MARGIN = 1)
tcga.gbm.mat <- tcga.gbm.mat[maxVals>50,]

# Order samples for expression and clinical file
common.smps <- intersect(colnames(tcga.gbm.mat), rownames(tcga.gbm.clinData))
tcga.gbm.mat <- tcga.gbm.mat[,common.smps]
tcga.gbm.clinData <- tcga.gbm.clinData[common.smps,]

###########################
# Get Annotation data ready 
# Constrain columns
##########################

# for getTSNEPlot.R
# Get top 10000 most variable genes
myCV <- function(x) { sd(x)/mean(x)}
myCVs <- apply(tcga.gbm.mat, FUN=myCV, MARGIN=1)
tcga.gbm.mat.tsne <- tcga.gbm.mat
tcga.gbm.mat.tsne["CV"] <- myCVs
tcga.gbm.mat.tsne <- tcga.gbm.mat.tsne[order(-tcga.gbm.mat.tsne[,"CV"]),]
if(nrow(tcga.gbm.mat.tsne) >= 10000){
  tcga.gbm.mat.tsne <- tcga.gbm.mat.tsne[1:10000,]
}
tcga.gbm.mat.tsne <- tcga.gbm.mat.tsne[-ncol(tcga.gbm.mat.tsne)] # Remove cv

# for getKMPlot.R and getSimilarPatients.R
# diseasetypes <- c("High-grade glioma", sampleInfo$tumorType)
# tcga.gbm.clinDataHGG <- tcga.gbm.clinData[grepl(paste(diseasetypes, collapse = "|"), tcga.gbm.clinData$integrated_diagnosis),]
# tcga.gbm.HGG <- tcga.gbm.mat.tsne[,rownames(tcga.gbm.clinDataHGG)]
tcga.gbm.allCor <- cor(tcga.gbm.mat.tsne[sampleInfo$subjectID], tcga.gbm.mat.tsne)
tcga.gbm.allCor <- data.frame(t(tcga.gbm.allCor), check.names = F)
tcga.gbm.allCor[,"sample_barcode"] <- rownames(tcga.gbm.allCor)
tcga.gbm.allCor <- tcga.gbm.allCor[!grepl(sampleInfo$subjectID, rownames(tcga.gbm.allCor)),]
# tcga.gbm.allCor <- tcga.gbm.allCor[intersect(rownames(tcga.gbm.allCor), survData$Kids_First_Biospecimen_ID),]
tcga.gbm.allCor <- tcga.gbm.allCor[order(-tcga.gbm.allCor[,1]),]
tcga.gbm.allCor[,1] <- round(tcga.gbm.allCor[,1], 3)