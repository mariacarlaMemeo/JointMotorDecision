# First data check for JMD Data

# select directory
# DataDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/'
DataDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/updated_rt/'
# save plots here
#PlotDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/pilotPlots/'
PlotDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/pilotPlots/updated_rt/'

# load necessary/useful libraries
library(ggplot2)
library(ez)
library(MuMIn)
library(lme4)
require(lmerTest)
library("BayesFactor")
library(permuco)
library(RVAideMemoire)
library(sjstats)
library(effsize)
library(reshape2)
library(writexl)

##### function to compute means #####
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # new version of length which can handle NAs (if na.rm==T, don't count them)
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # this does the summary. for each group's data frame, return a vector with
  # N, mean, and SD
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # calculate Standard Error of the Mean
  
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}


##### load data ####

# can be used for random selection (always same randomization)
set.seed(1)

# create data frame
collect_dat = data.frame(matrix(ncol = 0, nrow = 0))

# collect all file names (excel files)
Subs = list.files(DataDir,pattern="*.csv")

Subcounter = 99+length(Subs)
Subnums <- c(100:Subcounter) # create vector from 100 to Subcounter

Subcount = 0
#cursub = "pilotData_102.csv" # just for testing the script
cursub = "P103_rtUpdated.csv" # just for testing the script


for (cursub in Subs){
  Subcount = Subcount + 1 # count from 1 onwards
  Group  = 99+Subcount # count from 100 onwards
  Filetmp <- sprintf('%s%s', DataDir, cursub)       # create path
  #curdat <- read.csv(Filetmp,sep=",",header=FALSE) # load file
  curdat <- read.csv(Filetmp,sep=",",header=TRUE) # update file has a header
  

  
  # assign variables
  curdat_filt = curdat[,c(5:ncol(curdat))]
  colnames(curdat_filt) <-
    c(
      "targetContrast",
      "targetInterval",
      "targetLocation",
      "A1_decision",
      "A1_accuracy",
      "A1_RT",
      "A1_MT",
      "A1_Confidence",
      "A1_ConfRT",
      "A2_decision",
      "A2_accuracy",
      "A2_RT",
      "A2_MT",
      "A2_Confidence",
      "A2_ConfRT",
      "Coll_decision",
      "Coll_accuracy",
      "Coll_RT",
      "Coll_MT",
      "Coll_Confidence",
      "Coll_ConfRT",
      "Agent1stDecision",
      "Agent2ndDecision" ,
      "AgentCollDecision"
    )
  
  curdat_filt$GroupID <- Group # add column (at the end) for groupID XXX add as 1st col instead
  
  # reshape data to long format, to include A1, A2, and Coll in one plot
  ##################  ACCURACY  ################## 
  accuracy_all <- curdat_filt[,c("targetContrast","A1_accuracy","A2_accuracy","Coll_accuracy")]
  accuracy_all_long <- melt(accuracy_all, id="targetContrast")  # convert to long format
  accuracy_all_sum = summarySE(accuracy_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  # rename variables
  names(accuracy_all_sum)[names(accuracy_all_sum)=='value'] <- 'Accuracy'
  names(accuracy_all_sum)[names(accuracy_all_sum)=='variable'] <- 'Agent'
  # rename factor levels
  levels(accuracy_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")

  # plot for each pair
  group_acc <- accuracy_all_sum
  pd <- position_dodge(0.001) 
  ggplot(group_acc, aes(x=targetContrast, y=Accuracy, color=Agent, group=Agent)) + 
    geom_errorbar(aes(ymin=Accuracy-se, ymax=Accuracy+se), size=0.7, width=.01, position=pd) +
    scale_y_continuous(limits = c(0.4,1.0), breaks=seq(0.3,1.1, by=0.1)) +
    scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
    geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
    geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
    scale_shape_manual(values=c(15, 16, 17)) +
    scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
    scale_linetype_manual(values=c("dotted","dashed","solid")) +
    scale_size_manual(values=c(3,3,3)) +
    xlab("contrast level") + ylab("mean accuracy") +   # Set axis labels
    ggtitle("Perceptual accuracy") +                   # Set title
    theme_bw() +
    theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
          axis.title.x = element_text(face="bold", size=14,vjust=0.1),
          axis.title.y = element_text(face="bold", size=14,vjust=2),
          axis.text.y = element_text(size=12),
          axis.text.x = element_text(size=12),
          panel.border = element_blank(),
          axis.line = element_line(color = 'black', linewidth=0.1),
          legend.title=element_blank(),
          legend.text = element_text(size=14),
          legend.position=c(0.8,0.2)) 
          #legend.position=c(1,0) / scale_fill_discrete(labels = c("A", "B", "C"))
  
  # save plots XXX adjust this to save for each pair
  #ggsave(pilotAcc, file=sprintf("%spilotAcc.png",PlotDir), dpi = 300, units=c("cm"), height =20, width = 12)

  ################## REACTION TIME ##################
  rt_all <- curdat_filt[,c("targetContrast","A1_RT","A2_RT","Coll_RT")]
  rt_all_long <- melt(rt_all, id="targetContrast")  # convert to long format
  rt_all_sum = summarySE(rt_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  # rename variables
  names(rt_all_sum)[names(rt_all_sum)=='value'] <- 'RT'
  names(rt_all_sum)[names(rt_all_sum)=='variable'] <- 'Agent'
  # rename factor levels
  levels(rt_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
  
  # plot for each pair
  group_rt <- rt_all_sum
  pd <- position_dodge(0.001) 
  ggplot(group_rt, aes(x=targetContrast, y=RT, color=Agent, group=Agent)) + 
    geom_errorbar(aes(ymin=RT-se, ymax=RT+se), size=0.7, width=.01, position=pd) +
    scale_y_continuous(limits = c(0,3000), breaks=seq(0,3000, by=500)) +
    scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
    geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
    geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
    scale_shape_manual(values=c(15, 16, 17)) +
    scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
    scale_linetype_manual(values=c("dotted","dashed","solid")) +
    scale_size_manual(values=c(3,3,3)) +
    xlab("contrast level") + ylab("mean RT (ms)") +   # Set axis labels
    ggtitle("Reaction time") +                        # Set title
    theme_bw() +
    theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
          axis.title.x = element_text(face="bold", size=14,vjust=0.1),
          axis.title.y = element_text(face="bold", size=14,vjust=2),
          axis.text.y = element_text(size=12),
          axis.text.x = element_text(size=12),
          panel.border = element_blank(),
          axis.line = element_line(color = 'black', linewidth=0.1),
          legend.title=element_blank(),
          legend.text = element_text(size=14),
          legend.position=c(0.8,0.85)) 
  
  ################## MOVEMENT TIME ##################
  mt_all <- curdat_filt[,c("targetContrast","A1_MT","A2_MT","Coll_MT")]
  mt_all_long <- melt(mt_all, id="targetContrast")  # convert to long format
  mt_all_sum = summarySE(mt_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  # rename variables
  names(mt_all_sum)[names(mt_all_sum)=='value'] <- 'MT'
  names(mt_all_sum)[names(mt_all_sum)=='variable'] <- 'Agent'
  # rename factor levels
  levels(mt_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
  
  # plot for each pair
  group_mt <- mt_all_sum
  pd <- position_dodge(0.001) 
  ggplot(group_mt, aes(x=targetContrast, y=MT, color=Agent, group=Agent)) + 
    geom_errorbar(aes(ymin=MT-se, ymax=MT+se), size=0.7, width=.01, position=pd) +
    scale_y_continuous(limits = c(250,1750), breaks=seq(250,1750, by=250)) +
    scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
    geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
    geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
    scale_shape_manual(values=c(15, 16, 17)) +
    scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
    scale_linetype_manual(values=c("dotted","dashed","solid")) +
    scale_size_manual(values=c(3,3,3)) +
    xlab("contrast level") + ylab("mean MT (ms)") +   # Set axis labels
    ggtitle("Movement time") +                        # Set title
    theme_bw() +
    theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
          axis.title.x = element_text(face="bold", size=14,vjust=0.1),
          axis.title.y = element_text(face="bold", size=14,vjust=2),
          axis.text.y = element_text(size=12),
          axis.text.x = element_text(size=12),
          panel.border = element_blank(),
          axis.line = element_line(color = 'black', linewidth=0.1),
          legend.title=element_blank(),
          legend.text = element_text(size=14),
          legend.position=c(0.8,0.85)) 
  
  ##################  CONFIDENCE   ################## 
  conf_all <- curdat_filt[,c("targetContrast","A1_Confidence","A2_Confidence","Coll_Confidence")]
  conf_all_long <- melt(conf_all, id="targetContrast")  # convert to long format
  conf_all_sum = summarySE(conf_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  # rename variables
  names(conf_all_sum)[names(conf_all_sum)=='value'] <- 'Confidence'
  names(conf_all_sum)[names(conf_all_sum)=='variable'] <- 'Agent'
  # rename factor levels
  levels(conf_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
  
  # plot for each pair
  group_conf <- conf_all_sum
  pd <- position_dodge(0.001) 
  ggplot(group_conf, aes(x=targetContrast, y=Confidence, color=Agent, group=Agent)) + 
    geom_errorbar(aes(ymin=Confidence-se, ymax=Confidence+se), size=0.7, width=.01, position=pd) +
    scale_y_continuous(limits = c(1,6), breaks=seq(1,6, by=1)) +
    scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
    geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
    geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
    scale_shape_manual(values=c(15, 16, 17)) +
    scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
    scale_linetype_manual(values=c("dotted","dashed","solid")) +
    scale_size_manual(values=c(3,3,3)) +
    xlab("contrast level") + ylab("mean confidence") +   # Set axis labels
    ggtitle("Confidence level (1-6)") +                           # Set title
    theme_bw() +
    theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
          axis.title.x = element_text(face="bold", size=14,vjust=0.1),
          axis.title.y = element_text(face="bold", size=14,vjust=2),
          axis.text.y = element_text(size=12),
          axis.text.x = element_text(size=12),
          panel.border = element_blank(),
          axis.line = element_line(color = 'black', linewidth=0.1),
          legend.title=element_blank(),
          legend.text = element_text(size=14),
          legend.position=c(0.2,0.85))
  
  ##################  CONFIDENCE per RT XXX   ################## 
  conf_all <- curdat_filt[,c("targetContrast","A1_Confidence","A2_Confidence","Coll_Confidence")]
  conf_all_long <- melt(conf_all, id="targetContrast")  # convert to long format
  conf_all_sum = summarySE(conf_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  # rename variables
  names(conf_all_sum)[names(conf_all_sum)=='value'] <- 'Confidence'
  names(conf_all_sum)[names(conf_all_sum)=='variable'] <- 'Agent'
  # rename factor levels
  levels(conf_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
  
  # plot for each pair
  group_conf <- conf_all_sum
  pd <- position_dodge(0.001) 
  ggplot(group_conf, aes(x=targetContrast, y=Confidence, color=Agent, group=Agent)) + 
    geom_errorbar(aes(ymin=Confidence-se, ymax=Confidence+se), size=0.7, width=.01, position=pd) +
    scale_y_continuous(limits = c(1,6), breaks=seq(1,6, by=1)) +
    scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
    geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
    geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
    scale_shape_manual(values=c(15, 16, 17)) +
    scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
    scale_linetype_manual(values=c("dotted","dashed","solid")) +
    scale_size_manual(values=c(3,3,3)) +
    xlab("contrast level") + ylab("mean confidence") +   # Set axis labels
    ggtitle("Confidence level (1-6)") +                           # Set title
    theme_bw() +
    theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
          axis.title.x = element_text(face="bold", size=14,vjust=0.1),
          axis.title.y = element_text(face="bold", size=14,vjust=2),
          axis.text.y = element_text(size=12),
          axis.text.x = element_text(size=12),
          panel.border = element_blank(),
          axis.line = element_line(color = 'black', linewidth=0.1),
          legend.title=element_blank(),
          legend.text = element_text(size=14),
          legend.position=c(0.2,0.85))
  
  ##################  CONFIDENCE distribution  ##################
  conf_all <- curdat_filt[,c("targetContrast","A1_Confidence","A2_Confidence","Coll_Confidence")]
  conf_all_long <- melt(conf_all, id="targetContrast")  # convert to long format
  # rename variables
  names(conf_all_long)[names(conf_all_long)=='value'] <- 'Confidence'
  names(conf_all_long)[names(conf_all_long)=='variable'] <- 'Agent'
  # rename factor levels
  levels(conf_all_long$Agent) <- c("Agent 1", "Agent 2", "Collective")
  
  conf_dist <- conf_all_long
  ggplot(conf_dist, aes(x=Confidence, fill=Agent)) +
    #scale_x_continuous(limits = c(0,7), breaks=seq(1,6,by=1)) +
    #scale_y_continuous(limits = c(0,105), breaks=seq(0,105, by=25)) +
    geom_histogram(color = 1, binwidth=0.5, alpha=.5, position="dodge", linetype = 0.5) +
    scale_fill_manual(values = c("blue3", "gold2", "darkgreen"))
  
  #https://es.sonicurlprotection-fra.com/click?PV=2&MSGID=202301111637540285145&URLID=1&ESV=10.0.19.7431&IV=057805C0C70B3CE68BBD833F0CBC3537&TT=1673455074941&ESN=VwPbpXAVUwxyP%2BDb3sYErlHdTCl65OQfAYWLlKD%2BYAA%3D&KV=1536961729280&B64_ENCODED_URL=aHR0cHM6Ly9yLWNoYXJ0cy5jb20vZGlzdHJpYnV0aW9uL2hpc3RvZ3JhbS1ncm91cC1nZ3Bsb3QyLw&HK=8F0224221A817A9E7FFFBBA67210A6287850609150F1A62E1E00C6E0E3715D21
  
  ##################
  collect_dat = rbind(collect_dat, curdat_filt) # combine all subjects' data
}

################## go on to work with means ################## 

# filter rt?
#collect_dat$RT <- collect_dat$response.rt 
#collect_dat_RTcorrect <- collect_dat[collect_dat$Accuracy == 1 & collect_dat$RT < 0.8 & collect_dat$RT >= 0.1,]

#### compute means ####
# compute means per subject and contrast level
#Accuracy
Data_sub_acc_A1 = summarySE(collect_dat,measurevar="A1_accuracy",groupvars=c("GroupID","targetContrast"))
Data_sub_acc_A2 = summarySE(collect_dat,measurevar="A2_accuracy",groupvars=c("GroupID","targetContrast"))
Data_sub_acc_Coll = summarySE(collect_dat,measurevar="Coll_accuracy",groupvars=c("GroupID","targetContrast"))
#RT
Data_sub_RT_A1 = summarySE(collect_dat,measurevar="A1_RT",groupvars=c("GroupID","targetContrast"))
Data_sub_RT_A2 = summarySE(collect_dat,measurevar="A2_RT",groupvars=c("GroupID","targetContrast"))
Data_sub_RT_Coll = summarySE(collect_dat,measurevar="Coll_RT",groupvars=c("GroupID","targetContrast"))
#MT
Data_sub_MT_A1 = summarySE(collect_dat,measurevar="A1_MT",groupvars=c("GroupID","targetContrast"))
Data_sub_MT_A2 = summarySE(collect_dat,measurevar="A2_MT",groupvars=c("GroupID","targetContrast"))
Data_sub_MT_Coll = summarySE(collect_dat,measurevar="Coll_MT",groupvars=c("GroupID","targetContrast"))
#Confidence
Data_sub_Conf_A1 = summarySE(collect_dat,measurevar="A1_Confidence",groupvars=c("GroupID","targetContrast"))
Data_sub_Conf_A2 = summarySE(collect_dat,measurevar="A2_Confidence",groupvars=c("GroupID","targetContrast"))
Data_sub_Conf_Coll = summarySE(collect_dat,measurevar="Coll_Confidence",groupvars=c("GroupID","targetContrast"))

# try plotting
ggplot(Data_sub_acc_A1, aes(x=targetContrast, y=A1_accuracy, colour=GroupID)) + 
  geom_errorbar(aes(ymin=A1_accuracy-se, ymax=A1_accuracy+se), width=.1) +
  geom_line() +
  geom_point()


# compute overall means+SD+SE+CI XXX
Data_individual_acc <- cbind2(collect_dat$A1_accuracy,collect_dat$A2_accuracy)
Data_collective_acc = 
Data_overall_acc = summarySE(Data_sub_acc,measurevar="Accuracy")
Data_overall_acc_cond = summarySE(Data_sub_acc_cond,measurevar="Accuracy",groupvars=c("Gazecue_Target_Congruency"))
Data_overall_rt = summarySE(Data_sub_rt,measurevar="RT")
Data_overall_rt_cond = summarySE(Data_sub_rt_cond,measurevar="RT",groupvars=c("Gazecue_Target_Congruency"))




################################################################################


#### create Excel file for students ####
Data_prep_analysis <- Data_sub_rt
Data_prep_analysis$RTCongruent <- Data_sub_rt_cond$RT[Data_sub_rt_cond$Gazecue_Target_Congruency == "Congruent"]
Data_prep_analysis$RTIncongruent <- Data_sub_rt_cond$RT[Data_sub_rt_cond$Gazecue_Target_Congruency == "Incongruent"]
Data_prep_analysis$AccuracyCongruent <- Data_sub_acc_cond$Accuracy[Data_sub_acc_cond$Gazecue_Target_Congruency == "Congruent"]
Data_prep_analysis$AccuracyIncongruent <- Data_sub_acc_cond$Accuracy[Data_sub_acc_cond$Gazecue_Target_Congruency == "Incongruent"]

Data_prep_analysis$Nr <- Data_prep_analysis$Subnum #rename "Subnum" to "Nr"


Data_analysis <- Data_prep_analysis[,c("Nr","VP","Sportart","RT","RTCongruent","RTIncongruent","AccuracyCongruent","AccuracyIncongruent")]

write.csv(Data_analysis,sprintf("%sResults/GazeData.csv",DataDir))
write_xlsx(Data_analysis,sprintf("%sResults/GazeData.xlsx",DataDir))
