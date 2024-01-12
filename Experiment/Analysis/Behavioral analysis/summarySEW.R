##### function to compute means #####
summarySEW <- function(data=NULL, measurevar, groupvars=NULL, na.rm=TRUE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # new version of length which can handle NAs (if na.rm==T, don't count them)
  length2 <- function (x, na.rm=TRUE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # this does the summary. for each group's data frame, return a vector with
  # N, mean, and SD
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N     = length2(xx[[col]], na.rm=na.rm),
                     wmean = weighted.mean(xx[[col]], weights=c(209,235,319,302,252,121)/1438),
                     sd    = sd(xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # rename the "mean" column    
  datac <- rename(datac, c("wmean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # calculate Standard Error of the Mean
  
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}
