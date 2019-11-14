# Author: Chance Muscarella   email: chancemusky@email.arizona.edu
# NEON Science Summit: Environmental Drivers of microbial community composition Working Group
# Script for downloading NEON soil microbe and soil chemical data, modified from Lee Stanish's code file:getNEON_soil_microbes_data.R  Github URL: https://github.com/NEONScience/SummitMicrobes/blob/master/getNEON_soil_microbes_data.R
# Lee Stanish contact: (email: lstanish@battelleecology.org)


options(stringsAsFactors = FALSE)

library(plyr)
library(dplyr)
if(!'neonUtilities' %in% row.names(installed.packages())) install.packages('neonUtilities')
library(neonUtilities)

# Set output directory where you'll download datasets
outDir='C:/Users/chanc/OneDrive - University of Arizona/Documents/NEON_Sci_summit_2019/Microbial_community_working_group/' # update for your directory

# Grab soil physical properties (Distributed periodic) ####

print("Grabbing soil physical properties")
L1sls <- loadByProduct(startdate = "2013-01", enddate = "2019-12", dpID = 'DP1.10086.001', package = "expanded", check.size = FALSE)

# subset to soilCoreCollect data
L1.sls.scc <- data.frame(L1sls$sls_soilCoreCollection)
L1.sls.bgc <- data.frame(L1sls$sls_bgcSubsampling)
L1.sls.sm <- data.frame(L1sls$sls_soilMoisture)
L1.sls.pH <- data.frame(L1sls$sls_soilpH)
L1.sls.mg <- data.frame(L1sls$sls_metagenomicsPooling)


# convert factors to characters (sometimes needed when converting lists to data frames
i <- sapply(L1.sls.scc, is.factor)
L1.sls.scc[i] <- lapply(L1.sls.scc[i], as.character)


# Grab soil chemical properties (distributed periodic) ####
print("Grabbing soil chemical properties")
sls_soilChemistry <- loadByProduct(startdate = "2013-01", enddate = "2019-12", dpID = 'DP1.10078.001', check.size = FALSE)

# subset to soil chem table with relevant data
sls.soilchem <- data.frame(sls_soilChemistry$sls_soilChemistry)

# convert factors to characters (sometimes needed when converting lists to data frames
i <- sapply(sls.soilchem, is.factor)
sls.soilchem[i] <- lapply(sls.soilchem[i], as.character)

# Grab soil microbe marker gene sequences ####
print("Grabbing soil microbe marker gene sequences")
L1mic <- loadByProduct(startdate = "2013-01", enddate = "2019-12", dpID = 'DP1.10108.001', 
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

# 16S rawDataFiles metadata - this contains URL links to sequence data. RawDataFilepath contains the URL
L1mmgRaw <- L1mic$mmg_soilRawDataFiles   # read in soilDnaExtraction L1 data
L1mmgRaw16S <- L1mmgRaw[grep('16S', L1mmgRaw$rawDataFileName), ]
L1mmgRaw16S <- L1mmgRaw16S[!duplicated(L1mmgRaw16S$dnaSampleID), ]

# ITS rawDataFiles metadata - this contains URL links to sequence data. RawDataFilepath contains the URL
L1mmgRawITS <- L1mmgRaw[grep('ITS', L1mmgRaw$rawDataFileName), ]
L1mmgRawITS <- L1mmgRawITS[!duplicated(L1mmgRawITS$dnaSampleID), ]

# Grab soil microbe metagenome sequences ####
print("Grabbing soil microbe metagenome sequences sequences")
L1metagen <- loadByProduct(startdate = "2013-01", enddate = "2019-12", dpID = 'DP1.10107.001', 
                       package = 'expanded', check.size = FALSE)
L1metagen.dna <- L1metagen$mms_metagenomeDnaExtraction   # read in soilDnaExtraction L1 data
L1metagen.dna <- L1metagen.dna[grep("marker gene | marker gene and metagenomics | metagenomics", L1metagen.dna$sequenceAnalysisType),] #Do we need "marker gene" and "marker gene and metagenomics" again if we pulled those from the L1mic.dna?

# Metagenome sequencing metadata
L1metagen.seq <- L1metagen$mms_metagenomeSequencing 
L1metagen.seq$dnaSampleID <- toupper(L1metagen.seq$dnaSampleID)

# Metagenome Raw Data Files metadata for R1. Need to check in documentation what R1 and R2 refer to  - RawDataFilepath contains the URL
L1metagen.raw <- L1metagen$mms_rawDataFiles
L1metagen.raw.R1 <- L1metagen.raw[grep('R1', L1metagen.raw$rawDataFileName), ]
L1metagen.raw.R1 <- L1metagen.raw.R1[!duplicated(L1metagen.raw$dnaSampleID), ]

# Metagenome Raw Data Files metadata for R2. Need to check in documentation what R1 and R2 refer to
L1metagen.raw.R2 <- L1metagen.raw[grep('R2', L1metagen.raw$rawDataFileName), ]
L1metagen.raw.R2 <- L1metagen.raw.R2[!duplicated(L1metagen.raw$dnaSampleID), ]

# variables file - needed to use zipsByURI
varFile_mic <- L1mic$variables
varFile_chem <- sls_soilChemistry$variables
varFile_phys <- L1sls$variables
varFile_metagen <- L1metagen$variables

# export data
targetGene_16s <- '16S'  
targetGene_ITS <- 'ITS'

if(!dir.exists(paste0(outDir, 'mmg/')) ) { #name output directory whatever you want, but be sure to change it below if you dont use mmg
  dir.create(paste0(outDir, 'mmg/'))
}

write.csv(L1.sls.scc, paste0(outDir, 'mmg/', "soilFieldData.csv"), row.names=FALSE)
write.csv(L1.sls.bgc, paste0(outDir, 'mmg/', "soilBGCData.csv"), row.names=FALSE)
write.csv(L1.sls.sm, paste0(outDir, 'mmg/', "soilMoistureData.csv"), row.names=FALSE)
write.csv(L1.sls.ph, paste0(outDir, 'mmg/', "soilpHData.csv"), row.names=FALSE)
write.csv(L1.sls.mg, paste0(outDir,'mmg/', "soilmetagenomicsPoolingData.csv"), row.names=FALSE)
write.csv(L1mic.dna, paste0(outDir,'mmg/', "soilDNAextractionData.csv"), row.names=FALSE)
write.csv(L1mmgITS, paste0(outDir, 'mmg/', "soilITSmetadata.csv"), row.names=FALSE)
write.csv(sls.soilchem, paste0(outdir, 'mmg/', "soilChemistrydata.csv"), row.names = FALSE)
write.csv(L1mmgRaw16S[1,], paste0(outDir, '/mmg/', "mmg_soilraw16sDataFiles.csv"), row.names = FALSE)
write.csv(L1mmgRawITS[1,], paste0(outDir, '/mmg/', "mmg_soilrawITSDataFiles.csv"), row.names = FALSE)
write.csv(varFile_phys, paste0(outDir, '/mmg/', "phys_variables.csv"), row.names=FALSE)
write.csv(varFile_chem, paste0(outDir, '/mmg/', "chem_variables.csv"), row.names=FALSE)
write.csv(varFile_mic, paste0(outDir, '/mmg/', "mic_variables.csv"), row.names=FALSE)
write.csv(varFile_metagen, paste0(outDir, '/mmg/', "metagen_variables.csv"), row.names=FALSE)


# Download sequence data (lots of storage space needed!) --- As of 2019.11.13, I haven't done this yet because I'm not 100% sure how much space this will take
rawFile <- paste0(outDir, 'mmg/')
zipsByURI(filepath = rawFile, savepath = outDir, unzip = FALSE, saveZippedFiles = TRUE)









