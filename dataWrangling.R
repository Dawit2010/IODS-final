# Author: Dawit A. Yohannes
# E-mail: dawit.yohannes@helsinki.fi
# Date : December 10, 2017
# Description: Human development and gender inequality data 
# Data source : http://hdr.undp.org/en/content/human-development-index-hdi


library(dplyr)

#-----  Reading in the data

hd <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/human_development.csv", stringsAsFactors = F)
gii <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/gender_inequality.csv", stringsAsFactors = F, na.strings = "..")


#-----  Explore the datasets
# Both hd and gii datasets have 195 obs, and 8 and 10 vars respectively.

str(hd)
dim(hd)


str(gii)
dim(gii)



#----- Renaming variable names to shorter meaningful names

colnames(hd) <- c("HDIRank","Country","HDI","LifeExpectancy","ExpEduInYears","MeanEduInYears","GNIperCapita","GNIPCminusHDIRank")
colnames(gii) <- c("GIIRank","Country","GII","MaternalMortalityRatio","AdolescentBirthRate","percentInParliament","SecondaryEducFemale","SecondaryEducMale","LFPRFemale","LFPRMale")


#----- Create two new variables in gii
gii <- mutate(gii, SecondaryEducFtoM = SecondaryEducFemale / SecondaryEducMale)
gii <- mutate(gii, LFPRFtoM = LFPRFemale / LFPRMale)


#----- Inner join of the datasets on the variable country

human <- inner_join(hd, gii, by = "Country", suffix=c(".hd",".gii"))
str(human)
head(human)


#----- remove the commas from GNI and transform it to a numeric data
library(stringr);
human$GNIperCapita <- str_replace(human$GNIperCapita, pattern=",", replace ="") %>% as.numeric


#-----  Remove rows with NA
human <- filter(human, complete.cases(human))


#----- Create a new variable indicating country grouping based on human development index, HDI
# This country grouping is defined in page 3 of hdi data technical notes (http://hdr.undp.org/sites/default/files/hdr2016_technical_notes.pdf)

# HDI groups: low < 0.550, medium 0.550-0.700, high 0.700-0.800, very high > 0.800

# create a categorical variable named 'HDIgroup' using the given definition of HDI groups
bins <- c(0,0.550,0.700,0.800,1)
hditypes <- cut(human$HDI, breaks = bins, include.lowest = TRUE,right = F,labels=c("low","med","high","veryhigh"))

human <- mutate(human, HDIgroup = hditypes)



#-----  Making rownames country names & removing the country column

rownames(human) <- human$Country

human <- dplyr::select(human, -Country)

str(human)
head(human)




#-----  Writing the finalized human data

# human data now has 155 observations and 19 variables.
# 18 variables are either integer or numeric, HDIgroup variable is a factor.

write.table(human,file="data/human.txt",sep="\t")






