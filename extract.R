# A few different methods for extracting min, max, mean, and stdev from envi "stats" output in ROI tools
# Method 3 (line 53) is currently working the best

## Method 1
# read the text file
txt <- readLines('~/Desktop/rois_all.txt') 
# create an index for the lines that are needed
ti <- rep(which(grepl('ROI:', txt)), each = 3) + 1:3
# create a grouping vector of the same length
grp <- rep(1:33, each = 3)

# filter the text with the index 'ti' 
# and split into a list with grouping variable 'grp'
lst <- split(txt[ti], grp)
# loop over the list a read the text parts in as dataframes
lst <- lapply(lst, function(x) read.table(text = x, sep = '\t', header = TRUE,
                                          blank.lines.skip = TRUE))

# bind the dataframes in the list together in one data.frame
DF <- do.call(rbind, lst)
# change the name of the first column
names(DF)[1] <- 'ROI'

# get the correct ROI's for the ROI-column
DF$ROI <- sub('.*: (\\w+).*$', '\\1', txt[grepl('ROI: ', txt)])
DF # this is a little messed up

# alternatives to line 16
# load the 'data.table' package for the 'rbindlist' function
library(data.table)
# bind the dataframes in the list together to a data.table (enhanced version of a data.frame)
DT <- rbindlist(lst)
# change the name of the first column
setnames(DT, 1, 'ROI')

# get the correct ROI's for the ROI-column
DT[, ROI := sub('.*: (\\w+).*$', '\\1', txt[grepl('ROI: ', txt)])]
DT

## Method 2 -- this doesn't work
require(data.table)
raw <- readLines(con = "https://dl.dropboxusercontent.com/u/45095175/rois_all.txt",
                 n = 5)[1:5]
# Number of rows/files in data.table
nr <- 1
final <- data.frame(matrix(0L, nr, 5)) 
names(final) <- c("Roi", strsplit(x = raw[4], split = "\t")[[1]][2:5])
final[1, 2:5] <- strsplit(x = raw[5], split = "\t")[[1]][2:5]
final[1, 1]  <- strsplit(x = raw[2], split = " ")[[1]][2]
setDT(final)
final

## Method 3
xy <- readLines('~/Desktop/rois_all.txt') 

# find lines where ROI starts
roin <- grep(pattern = "ROI: ", x = xy)
roi <- xy[roin]
roi <- gsub(".*ROI: (\\w+).*$", "\\1", roi)

# find lines with stats
stats <- grep(pattern = "Basic Stats", x = xy)

# trim whitespace and collect Col
cn <- trimws(sapply(strsplit(xy[stats][1], "\t"), "[", 2:5, simplify = FALSE)[[1]])

# split the stat line by \t and extract only elements 2 to 5. merge row-wise
out <- do.call(rbind, sapply(strsplit(xy[stats + 1], "\t"), "[", 2:5, simplify = FALSE))
out <- as.data.frame(apply(out, MARGIN = 2, as.numeric))

# add ROI column extracted earlier
out <- cbind(roi, out)

colnames(out) <- c("ROI", cn)
out
