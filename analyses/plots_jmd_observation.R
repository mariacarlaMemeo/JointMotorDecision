############################
# jmd observation experiment
# plotting the "observed confidence" (estimated during observation of videos)
# against the "subjective confidence" (reported during action execution)
# January 2022
############################

# Setup
# -----

# Clear workspace:
rm(list = ls())
# clear console: Crtl L

# Import libraries (not sure if all of these are necessary)
library(readxl)
library(plyr)
library(dplyr)
library(lme4)
library(ggplot2)
library(sjPlot)
library(plotly)
library(emmeans)
library(datawizard)
library(ez)
library(MuMIn)
require(lmerTest)
library("BayesFactor")
library(permuco)
library(RVAideMemoire)
library(sjstats)
library(effsize)
library(reshape2)
library(writexl)
library(readxl)
library(genTS)
library(car)

# Preparing the data
# ------------------

# specify directory
dataFile = "C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/05_Observation task/data/Results_updated.xlsx"
dataDir  = "C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/05_Observation task/data/"

# create vector with participant names
participants   <- c("P100_A1", "P100_A2", "P101_A1", "P101_A2", "P103_A1", "P103_A2")
p_originalFile <- c("P100_vidInfo50_A1", "P100_vidInfo50_A2", "P101_vidInfo50_A1", "P101_vidInfo50_A2", "P103_vidInfo50_A1", "P103_vidInfo50_A2")
obsAveHiLo = c()
exeAveAcc  = c()
obsAveconf = c()
exeAveconf = c()

# load data set per participant
for (i in participants)
{
  #read the excel file of the observation data
  obsData <- read_excel(dataFile, sheet = i)
  #View(obsData) # display the results
  
  #read the excel file of the execution data
  exeData  = read_excel(paste0(dataDir,strsplit(i,"_")[[1]][1],"_vidInfo50_",strsplit(i,"_")[[1]][2],".xlsx"))
  #next row removes the rows in which the video has 0 length (only for agent P100_A2)
  exeData  = exeData[exeData$dura_vid_cutMS>0,]
  exeData4 = rbind(exeData,exeData,exeData,exeData)
  
  # rename "obsData" and "exeData" to "data"
  data <- cbind(obsData,exeData4)
  head(data)
  
  #Check the agent acting in the execution 
  if(is_empty(grep("_A1",i))){actor = 1}else{actor = 2}
  
  # select relevant columns: obsConfidence= estimated; exeConfidence = executed
  obsConfidence = data$SubjResp
  exeConfidence = data$CorrResp
  rtNorm        = data$SubjRTnorm
  obsResp       = data$SubjResp
  exeResp       = data$CorrResp
  
  #Categorize accuracy in high(2) and low(1)
  obsResp[obsResp<4]=1
  obsResp[obsResp>=4]=2
  
  exeResp[exeResp<4]=1
  exeResp[exeResp>=4]=2
  
  obsAccHiLo = as.integer(obsResp==exeResp)
  currAve    = mean(obsAccHiLo,na.rm=TRUE)
  obsAveHiLo = c(obsAveHiLo,currAve)
  
  
  # Computing regression and plotting the data
  # ------------------------------------------
  
  # Linear regression: take observed conf. as predictor for subjective conf.
  fit <- lm(exeConfidence ~ obsConfidence)
  lm(formula = exeConfidence ~ obsConfidence)
  summary(fit)
  Rsquared <- summary(fit)$r.squared
  print(Rsquared,digits=3)
  
  ## Scatterplot
  # include linear trend + confidence interval (se)
  # jitter the points to avoid overlay of data points (jitter range: 0.5 on both axes)
  confidenceInOut = ggplot(data, aes(x = obsConfidence, y = exeConfidence)) +
    geom_point(
      shape = 1,   # Use hollow circles
      position = position_jitter(width = 0.1, height = .1)) +
    geom_smooth(
      method = lm, # Add linear regression line
      color = "blue",
      fill = "#69b3a2",
      se = TRUE)
  # show scatter plot and display R2-value
  confidenceInOut = confidenceInOut +
    annotate("text", x=1.5, y=6, label = paste("R2 = ", format(summary(fit)$r.squared,digits=3)), col="black", cex=6)+
    ggtitle(paste0(i," Mean Obs Acc:", as.character(format(currAve,digits=3))))
  print(confidenceInOut)
  
  
  ## RTnorm
  rtNorm_obsConf = ggplot(data, aes(x = obsConfidence, y = rtNorm)) +
    geom_point(
      shape = 1,   # Use hollow circles
      position = position_jitter(width = 0.1, height = .1))+
    scale_x_continuous(breaks=seq(1, 6, 1))+
    scale_y_continuous(breaks=seq(0, max(rtNorm,na.rm=TRUE), .5))+
    ggtitle(paste0(i," Mean Obs Acc:", as.character(format(currAve,digits=3))))
  print(rtNorm_obsConf)
  
  rtNorm_exeConf = ggplot(data, aes(x = exeConfidence, y = rtNorm)) +
    geom_point(
      shape = 1,   # Use hollow circles
      position = position_jitter(width = 0.1, height = .1))+
    scale_x_continuous(breaks=seq(1, 6, 1))+
    scale_y_continuous(breaks=seq(0, max(rtNorm,na.rm=TRUE), .5))+
    ggtitle(paste0(i," Mean Obs Acc:", as.character(format(currAve,digits=3))))
  print(rtNorm_exeConf)
  
  
  ## We cannot use RT as predictor because it is not included in the video
  # exeRT_obsConf = ggplot(data, aes(x = obsConfidence, y = rt_agentActing)) +
  #   geom_point(
  #     shape = 1,   # Use hollow circles
  #     position = position_jitter(width = 0.1, height = .1))+
  #   scale_x_continuous(breaks=seq(1, 6, 1))+
  #   scale_y_continuous(breaks=seq(0, max(data$rt_agentActing,na.rm=TRUE), .5))+
  #   ggtitle(paste0(i," Mean Obs Acc:", as.character(format(currAve,digits=3))))
  # print(exeRT_obsConf)
  
  #xxx## Video duration represents movement time 
  # plot the movement time during execution with confidence during observation
  exeMOV_obsConf = ggplot(data, aes(x = obsConfidence, y = dura_vid_cutMS)) +
    geom_point(shape = 1,   # Use hollow circles
      position = position_jitter(width = 0.1, height = .1))+
    scale_x_continuous(breaks=seq(1, 6, 1))+
   # scale_y_continuous(breaks=seq(0, max(dura_vid_cutMS,na.rm=TRUE), .5))+
    ggtitle(paste0(i," Mean Obs Acc:", as.character(format(currAve,digits=3))))
  print(exeMOV_obsConf)
  
  ## average execution accuracy 
  col_name   = paste0("A",as.character(actor),"_acc")
  currAveAcc = mean(data[[col_name]],na.rm=TRUE)
  exeAveAcc  = c(exeAveAcc,currAveAcc)
  ## average observation response (confidence)
  currAveconf = mean(data$SubjResp,na.rm=TRUE)
  obsAveconf  = c(obsAveconf,currAveconf)
  ## average execution response (confidence)
  currAveExeconf = mean(data$CorrResp,na.rm=TRUE)
  exeAveconf  = c(exeAveconf,currAveExeconf)
  
  # save the plots
  plotDir = "C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/05_Observation task/scatterplots/"
  ggsave(confidenceInOut, file=sprintf(paste0(plotDir,i,"_Confidence.png")), dpi = 300, units=c("cm"), height =20, width = 20)
  ggsave(rtNorm_obsConf, file=sprintf(paste0(plotDir,i,"_rtNorm_obsConf.png")), dpi = 300, units=c("cm"), height =20, width = 20)
  ggsave(rtNorm_exeConf, file=sprintf(paste0(plotDir,i,"_rtNorm_exeConf.png")), dpi = 300, units=c("cm"), height =20, width = 20)
  ggsave(exeMOV_obsConf, file=sprintf(paste0(plotDir,i,"_exeMOV_obsConf.png")), dpi = 300, units=c("cm"), height =20, width = 20)
  
}
  
# plot average (high/low-)accuracy for participants
jpeg(file=paste0(plotDir,"aveObsAcc_highLow.jpeg"))
boxplot(obsAveHiLo,ylab="Average observer Accuracy (high/low)")
stripchart(obsAveHiLo,method="jitter",vertical = TRUE,add = TRUE)
dev.off()

#MAKE IT SCHON! plot average execution accuracy and average observation confidence
plot(obsAveconf,exeAveAcc)

#Sensitivity vs observer confidence
# exeSens = c(2.5701,4.8552,1.8875,2.9721,2.7998,2.4420,7.5846,3.7935)
exeSens = c(2.5701,4.8552,1.8875,2.9721,7.5846,3.7935)

# scatterplot(exeSens ~ obsAveconf,smoother = FALSE, grid = FALSE, frame = FALSE)
plot(obsAveconf,exeSens)
abline(lm(exeSens ~ obsAveconf))


plot(exeAveconf,exeSens)
abline(lm(exeSens ~ exeAveconf))
###############################################################################

# more ideas for plotting below, see
# http://www.cookbook-r.com/Graphs/Scatterplots_(ggplot2)/

###############################################################################
