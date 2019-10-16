#' @title Download soil microbial metadata and sequence data
#' @author
#' Lee Stanish \email{lstanish@battelleecology.org} \cr

options(stringsAsFactors = FALSE)

library(plyr)
library(dplyr)
if(!'neonUtilities' %in% row.names(installed.packages())) install.packages('neonUtilities')
library(neonUtilities)

# Set output directory
outDir='/Users/lstanish/Downloads/' # update for your directory


## Grab soil field data ##
print("Grabbing soil field data")
L1sls <- loadByProduct(startdate = "2016-01", enddate = "2017-01", dpID = 'DP1.10086.001', check.size = FALSE)
# subset to soilCoreCollect data
L1sls.scc <- data.frame(L1sls$sls_soilCoreCollection)
# convert factors to characters (sometimes needed when converting lists to data frames
i <- sapply(L1sls.scc, is.factor)
L1sls.scc[i] <- lapply(L1sls.scc[i], as.character)
# remove Ntrans T-final bout data #
L1sls.scc <- L1sls.scc[grep("initial|No|no|Initial", L1sls.scc$nTransBoutType), ]
L1.sls.bgc <- L1sls$sls_bgcSubsampling
L1.sls.sm <- L1sls$sls_soilMoisture
L1.sls.ph <- L1sls$sls_soilpH
L1.sls.mg <- L1sls$sls_metagenomicsPooling


## Grab soil microbe data ##
L1mic <- loadByProduct(startdate = "2016-09", enddate = "2017-01", dpID = 'DP1.10108.001', 
                       package = 'expanded', check.size = FALSE)
L1mic.dna <- L1mic$mmg_soilDnaExtraction   # read in soilDnaExtraction L1 data
L1mic.dna <- L1mic.dna[grep("marker gene|marker gene and metagenomics", L1mic.dna$sequenceAnalysisType),]
L1mic.dna$dnaSampleID <- toupper(L1mic.dna$dnaSampleID)

# 16S sequencing metadata
L1mmg16S <- L1mic$mmg_soilMarkerGeneSequencing_16S   # read in marker gene sequencing 16S L1 data
L1mmg16S$dnaSampleID <- toupper(L1mmg16S$dnaSampleID)

# ITS sequencing metadata
L1mmgITS <- L1mic$mmg_soilMarkerGeneSequencing_ITS   # read in marker gene sequencing ITS L1 data
L1mmgITS$dnaSampleID <- toupper(L1mmgITS$dnaSampleID)

# 16S rawDataFiles metadata - this contains URL links to sequence data
L1mmgRaw <- L1mic$mmg_soilRawDataFiles   # read in soilDnaExtraction L1 data
L1mmgRaw16S <- L1mmgRaw[grep('16S', L1mmgRaw$rawDataFileName), ]
L1mmgRaw16S <- L1mmgRaw16S[!duplicated(L1mmgRaw16S$dnaSampleID), ]

# ITS rawDataFiles metadata - this contains URL links to sequence data
L1mmgRawITS <- L1mmgRaw[grep('ITS', L1mmgRaw$rawDataFileName), ]
L1mmgRawITS <- L1mmgRawITS[!duplicated(L1mmgRawITS$dnaSampleID), ]

# variables file - needed to use zipsByURI
varFile <- L1mic$variables

# export data
targetGene <- '16S'  # change to ITS if you want the ITS data instead

if(!dir.exists(paste0(outDir, 'mmg/')) ) {
  dir.create(paste0(outDir, 'mmg/'))
}

write.csv(L1sls.scc, paste0(outDir, 'mmg/', "soilFieldData.csv"), row.names=FALSE)
write.csv(L1.sls.bgc, paste0(outDir, 'mmg/', "soilBGCData.csv"), row.names=FALSE)
write.csv(L1.sls.sm, paste0(outDir, 'mmg/', "soilMoistureData.csv"), row.names=FALSE)
write.csv(L1.sls.ph, paste0(outDir, 'mmg/', "soilpHData.csv"), row.names=FALSE)
write.csv(L1.sls.mg, paste0(outDir,'mmg/', "soilmetagenomicsPoolingData.csv"), row.names=FALSE)
write.csv(L1mic.dna, paste0(outDir,'mmg/', "soilDNAextractionData.csv"), row.names=FALSE)
write.csv(L1mmgITS, paste0(outDir, 'mmg/', "soilITSmetadata.csv"), row.names=FALSE)
if(targetGene=="16S") {
  write.csv(L1mmgRaw16S[1,], paste0(outDir, 'mmg/', "mmg_soilrawDataFiles.csv"), row.names=FALSE)
} else {
  write.csv(L1mmgRawITS, paste0(outDir, 'mmg/', "mmg_soilrawDataFiles.csv"), row.names=FALSE)
}
write.csv(varFile, paste0(outDir,'mmg/', "variables.csv"), row.names=FALSE)


# Download sequence data (lots of storage space needed!)
rawFile <- paste0(outDir, 'mmg/')
zipsByURI(filepath = rawFile, savepath = outDir, unzip = FALSE, saveZippedFiles = TRUE)


