# Envi --> ascii file
# Credit: http://stackoverflow.com/questions/42615659/organize-txt-file-into-data-frame-in-r/42634354?noredirect=1#comment72410711_42634354

setwd("~/Desktop") # set your working directory to wherever your ascii file is

txt <- readLines('test.txt')

# extract the columnn names from the text file
colnms <- sapply(strsplit(grep('^Column ', txt, value = TRUE),':'), function(i) trimws(tail(i,1)))
colnms <- sub('(\\w+).*', '\\1', colnms)

# reading the data lines into a dataframe with 'read.table'
# and use the 'col.names' parameter to assign the column names
dat <- read.table(text = txt, skip = 22, header = FALSE, col.names = colnms)

# reshape the data into the desired format
library(reshape2)
dat2 <- recast(dat, variable ~ paste0('Band_',Band), id.var = 'Band')
names(dat2)[1] <- 'ROI'

#library(data.table)
#dcast(melt(setDT(dat), id = 1, variable.name = 'ROI'), ROI ~ paste0('Band_',Band))

write.csv(dat2, file = "test.csv")
