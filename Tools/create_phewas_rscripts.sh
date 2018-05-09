#!/bin/bash

mkdir phewasresults

for i in {1..22};
do

echo '#install.packages("devtools")
#library(devtools)
#install_github("PheWAS/PheWAS")
library(PheWAS)

# https://github.com/PheWAS/PheWAS


# Real data - genotypes

genotypes.GSA = read.table("GSA_chr_'$i'.A.raw", header=T, check.names = F) # takes about 4 minutes
genotypes.GSA$FID = NULL
genotypes.GSA$PAT = NULL
genotypes.GSA$MAT = NULL
genotypes.GSA$SEX = NULL
genotypes.GSA$PHENOTYPE = NULL
colnames(genotypes.GSA)[1] = "ID" 


# IDs merge

IDs = read.table("PSI.imputation.key", header=T, sep = "\t")
colnames(IDs)[2] = "ID"
genotypes.GSA.merge = merge(IDs, genotypes.GSA, by = "ID", all=F)
genotypes.GSA.merge[1] = NULL
genotypes = genotypes.GSA.merge

library(foreign)
#install.packages("lubridate")
library(lubridate)

db <- read.dta("Michiel_PSI_data_opgeschoond.dta", convert.dates = TRUE, convert.factors = TRUE)

# In eerste instantie neem ik de roogegevens van het eerste consult. Dit MOET namelijk zijn ingevuld door de arts/VPK. 
# Daarna zou het zo kunnen zijn dat de gegevens steeds maar blijven staan zonder dat het opnieuw is gevraagd. Dit weet je niet.

attach(db) 
colnames(db)[colnames(db)=="ROOK_CAT"] <- "Smoking_first_consult"
colnames(db)[colnames(db)=="ROKEN_DAT"] <- "Smoking_first_consult_date"
detach(db)

# Van alle rook categorien naar "Current", "Former" of "Never" of "Current", "Not current" of "Ever, "Never"

db$Smoking_CFN <- ifelse(db$Smoking_first_consult == "huidige roker" | db$Smoking_first_consult == "minder dan 6 maanden geleden gestopt", "Current", ifelse(db$Smoking_first_consult == "nooit gerookt", "Never", "Former")) 

db$Smoking_CE <- ifelse(db$Smoking_CFN == "Current", "Current", "Not current") 

db$Smoking_EN <- ifelse(db$Smoking_CFN == "Never", "Never", "Ever") 

#
# rename all columns

colnames(db)[colnames(db)=="strictuur_stenose"] <- "Stenosing"
colnames(db)[colnames(db)=="penetrerende_ziekte"] <- "Penetrating"
colnames(db)[colnames(db)=="totaal_colon_resectie"] <- "Colectomy"
colnames(db)[colnames(db)=="totaal_ileocecaalresectie"] <- "Ileocaecal_resection"
colnames(db)[colnames(db)=="resectie"] <- "Resection_any"
colnames(db)[colnames(db)=="P"] <- "Peri_anal_disease"
colnames(db)[colnames(db)=="DIAGN_LTST_CONS_laatste_diagnose"] <- "Diagnosis"
colnames(db)[colnames(db)=="extraint_arthropathie"] <- "EIM_arthropathy"
colnames(db)[colnames(db)=="EXTRAINT_BOT"] <- "EIM_BMD"


db$Stenosing <- factor(db$Stenosing, 
                       levels = c("geen stenose", "stenoserende ziekte"),
                       labels = c("No stenosis", "Stenosis"))

db$Penetrating <- factor(db$Penetrating, 
                         levels = c("geen penetrerende ziekte", "penetrerende ziekte"),
                         labels = c("No penetration", "Penetration"))

db$Colectomy <- factor(db$Colectomy, 
                       levels = c("geen colon resectie", "colonresectie"),
                       labels = c("No colectomy", "Colectomy"))

db$Ileocaecal_resection <- factor(db$Ileocaecal_resection, 
                                  levels = c("geen ileocecaal resectie", "ileocecaalresectie"),
                                  labels = c("No illeocaecal resection", "Ileocaecal resection"))

db$Resection_any <- factor(db$Resection_any, 
                           levels = c("geen resectie", "resectie"),
                           labels = c("No resection", "(any) resection"))

db$Diagnosis <- factor(db$Diagnosis,
                       levels = c("CD","CU","IBDU","IBDI","nog te bepalen"),
                       labels = c("CD","CU", "IBDU", "IBDI", NA))

db$L4 <- factor(db$L4,
                levels = c("geen L4","L4"),
                labels = c("No L4", "L4"))

db$EIM_arthropathy <- factor(db$EIM_arthropathy,
                             levels = c("nee", "ja"),
                             labels = c("No", "Yes"))

db$PSC <- factor(db$PSC,
                 levels = c(0, 1),
                 labels = c("No", "Yes"))

db$EIM_BMD <- factor(db$EIM_BMD,
                     levels = c(0, 1),
                     labels = c("No", "BMD T-score < -1"))

# Define missings

db$L[db$L=="missing"] <- NA
db$L <- factor(db$L)
db$E[db$E=="missing"] <- NA
db$E <- factor(db$E)


library(data.table)
phenotypes.Lieke = as.data.frame(subset(db, IDAA %in% genotypes$IDAA.PSI))

# Apperently not all PSI patients are in Liekes cleaned database. We remain with 2695 out of 2732 invidivuals.



# example 
# csv.phenotypes=read.csv("~/Documents/Werk/Promotie/PheWas/example_pheno.csv")

# We will now drop variable from the phenotypes Lieke dataset that dont make sense for a PheWas
# Also we need to convert factors to logical and numbers to integer

phenotypes = phenotypes.Lieke[,c(1,2)]
phenotypes$CrohnsDisease=phenotypes.Lieke$Diagnosis=="CD"
phenotypes$UlcerativeColitis=phenotypes.Lieke$Diagnosis=="CU"
phenotypes$IBDU=phenotypes.Lieke$Diagnosis=="IBDU"
phenotypes$Colectomy=phenotypes.Lieke$Colectomy=="Colectomy" 
phenotypes$Stenosing=phenotypes.Lieke$Stenosing=="Stenosis" 
phenotypes$Penetrating=phenotypes.Lieke$Penetrating=="Penetration"
phenotypes$Ileocaecal_resection=phenotypes.Lieke$Ileocaecal_resection=="Ileocaecal resection"
phenotypes$Time_to_Surgery=as.numeric(phenotypes.Lieke$time_surgery)
phenotypes$CD_Time_to_Surgery=as.numeric(phenotypes.Lieke$CD_time_surgery)
phenotypes$UC_Time_to_Surgery=as.numeric(phenotypes.Lieke$UC_time_surgery)
phenotypes$Smoking_EN=phenotypes.Lieke$Smoking_EN=="Ever"
phenotypes$Smoking_CE=phenotypes.Lieke$Smoking_CE=="Current"
phenotypes$Complications=phenotypes.Lieke$complicaties=="complicaties"
phenotypes$EIM_arthropathy=phenotypes.Lieke$EIM_arthropathy=="Yes"
phenotypes$EIM_arthritis=phenotypes.Lieke$extraint_arthritis=="ja"
phenotypes$Pouchitis=phenotypes.Lieke$samen_pouchitis=="pouchitis"
phenotypes$AgeDiagnosis=as.numeric(phenotypes.Lieke$AgeDiagnose)
phenotypes$A1=phenotypes.Lieke$A1=="1"
phenotypes$A2=phenotypes.Lieke$A2=="1"
phenotypes$A3=phenotypes.Lieke$A3=="1"
phenotypes$PeriAnalDisease=phenotypes.Lieke$Peri_anal_disease=="P"
phenotypes$E1=phenotypes.Lieke$E=="E1"
phenotypes$E2=phenotypes.Lieke$E=="E2"
phenotypes$E3=phenotypes.Lieke$E=="E3"
phenotypes$Azathioprine=phenotypes.Lieke$azathioprine=="azathioprine"
phenotypes$Mercaptopurine=phenotypes.Lieke$mercaptopurine=="mercaptopurine"
phenotypes$Immunomodulator=phenotypes.Lieke$immunomodulator=="immunomodulator"
phenotypes$Mesalazine=phenotypes.Lieke$mesalazine=="Mesalazine"
phenotypes$PSC=phenotypes.Lieke$PSC=="Yes"
phenotypes$Appendectomy=phenotypes.Lieke$APPENDECTOMIE=="1"
phenotypes$Pouch=phenotypes.Lieke$POUCH=="1"
phenotypes$Stoma=phenotypes.Lieke$STOMA=="1"
phenotypes$HBImean=as.numeric(phenotypes.Lieke$HBI_mean)
phenotypes$SCCAImean=as.numeric(phenotypes.Lieke$SCCAI_mean)
phenotypes$Uveitis=phenotypes.Lieke$HB_UVEITIS=="1"
phenotypes$Erythema=phenotypes.Lieke$HB_ERYTHEMA=="1"
phenotypes$Pyoderma=phenotypes.Lieke$HB_PYODERMA_GANG=="1"
phenotypes$OralAphthae=phenotypes.Lieke$HB_AFTEN_MOND=="1"
phenotypes$AnalFissura=phenotypes.Lieke$HB_ANAL_FISSU=="1"
phenotypes$Skin=phenotypes.Lieke$EXTRAINT_HUID=="1"
phenotypes$Eyes=phenotypes.Lieke$EXTRAINT_OGEN=="1"
phenotypes$TromboticEvents=phenotypes.Lieke$EXTRAINT_TROMB=="1"
phenotypes$EIM_BMD=phenotypes.Lieke$EIM_BMD=="BMD T-score < -1"
phenotypes$Height=as.numeric(phenotypes.Lieke$LENGTE)

# Many laboratory tests seem to have negative values -> make NA
phenotypes.Lieke[, 145:174][phenotypes.Lieke[, 145:174] <= 0 ] <- NA

# A few laboratory values seem to be incorrect. For exapmle Hb of 93 (probably 9.3, but we should remove)
phenotypes.Lieke[, "BLD_HB"][phenotypes.Lieke[, "BLD_HB"] >= 15] <- NA
phenotypes.Lieke[, "BLD_HT"][phenotypes.Lieke[, "BLD_HT"] >= 1] <- NA

phenotypes$ASAT=as.numeric(phenotypes.Lieke$BLD_ASAT)
phenotypes$AF=as.numeric(phenotypes.Lieke$BLD_ALK_FOSF)
phenotypes$ALAT=as.numeric(phenotypes.Lieke$BLD_ALAT)
phenotypes$BSE=as.numeric(phenotypes.Lieke$BLD_BSE)
phenotypes$CRP=as.numeric(phenotypes.Lieke$BLD_CRP)
phenotypes$GGT=as.numeric(phenotypes.Lieke$BLD_GGT_GT)
phenotypes$Ht=as.numeric(phenotypes.Lieke$BLD_HT)
phenotypes$Leuco=as.numeric(phenotypes.Lieke$BLD_LEUKO)
phenotypes$MCV=as.numeric(phenotypes.Lieke$BLD_MCV)
phenotypes$Creat=as.numeric(phenotypes.Lieke$BLD_CREAT)
phenotypes$Thrombos=as.numeric(phenotypes.Lieke$BLD_TROMBO)
phenotypes$Hb=as.numeric(phenotypes.Lieke$BLD_HB)

# match ID column name
phenotypes[2] = NULL
colnames(phenotypes)[1] = "id"
colnames(genotypes)[1] = "id"


# include disease as covariate. We will use the CD column as a binary covariates (either CD or UC/IBDU)

covariates = phenotypes[,c("id","CrohnsDisease")]
phenotypes[2]=NULL
phenotypes[2]=NULL
phenotypes[2]=NULL

library(parallel)

# Remove not usefull stuff from environment

rm(db)
rm(genotypes.GSA)
rm(genotypes.GSA.merge)
rm(phenotypes.Lieke)

# Now we have to rename the phenotypes into phecodes (3 digits) (Please see ~/Documents/Werk/Promotie/PheWas/pheinfo.csv)
colnames(phenotypes)<- c("id", "080", "120", "120.1", "080.1", "080.4", "080.2", "080.3", "021", "022", "011", "012", "013", "040", "050", "050.1", "050.2", "050.3", "060", "070", "070.1", "070.2", "101", "101.1", "101.2" ,"102", "100", "082", "081", "081.1", "130", "130.1", "002", "003", "004", "005", "006", "007", "008", "009", "010", "020", "001.11", "001.12", "001.13", "001.2", "001.21", "001.14", "001.3", "001.31", "001.32", "001.4", "001.33", "001")

# Supporting files for plotting:
pheinfo = read.csv("pheinfo.csv", sep = ";", colClasses=c("character",rep("character",4)))
phemap= read.csv("phemap.csv", sep = ";", colClasses = c("character", "character"))
phemap[3]=NULL
phemap[3]=NULL
phemap[3]=NULL
phemap[3]=NULL


# Save current project
# save.image("PheWas_GWAScat_snps.Rdata")

# Better to perform on cluster: PheWas with 5 cores per chromosome
results=phewas(phenotypes = phenotypes, genotypes = genotypes, covariates = covariates[,c("id", "CrohnsDisease")], significance.threshold = c("fdr"), min.records = 20, alpha = 0.05 ,cores=5)

# Write results of phewas
write.csv(results, file = "phewasresults/PheWas_All_snps_chr_'$i'.csv", row.names = F, quote = F)


# Plot results
pdf("phewasresults/PheWas_All_snps_chr_'$i'.pdf")
phewasManhattan(results, annotate.phenotype.description = T, title = "PheWas All snps chr '$i'")
dev.off()
jpeg("phewasresults/PheWas_All_snps_chr_'$i'.jpg")
phewasManhattan(results, annotate.phenotype.description = T, title = "PheWAS All snps chr '$i'")
dev.off() '>> PheWas_chr_"$i".r;
done
