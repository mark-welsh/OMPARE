# Author: Komal S. Rathi
# Date: 04/13/2020
# Function: Generate patient report

suppressPackageStartupMessages(library(optparse))

option_list <- list(
  make_option(c("-p", "--patient"), type = "character",
              help = "Patient Number (1, 2...)"),
  make_option(c("-w", "--workdir"), type = "character",
              help = "OMPARE working directory")
)

# parameters to pass
opt <- parse_args(OptionParser(option_list = option_list))
p <- opt$patient
workdir <- opt$workdir

# set variables
setwd(workdir) # This should be the OMPARE directory
print(paste0("Working directory:", getwd()))
patient <- paste0(p)
topDir <- file.path(getwd(), 'data', patient)
set_title <- paste0(patient,' Patient Report')
callers <- c("mutect2", "strelka2")

# fusion_method can be either arriba, star, both or not specified
print("Run reports...")
if(dir.exists(topDir)){
  for(i in 1:length(callers)) {
    outputfile <- paste0(patient, '_', callers[i], '.html')
    outputfile <- file.path(topDir, 'Reports', outputfile)
    rmarkdown::render(input = 'OMPARE.Rmd',
                      params = list(topDir = topDir,
                                    fusion_method = 'both',
                                    set_title = set_title,
                                    snv_pattern = callers[i]),
                      output_file = outputfile)
  }
}
