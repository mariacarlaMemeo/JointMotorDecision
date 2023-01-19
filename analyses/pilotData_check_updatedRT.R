# First data check for JMD Data
rm(list = ls())


## Functions
source('C:/Users/MMemeo/OneDrive - Fondazione Istituto Italiano Tecnologia/Documents/GitHub/temporalLagMEmodulation/Temporal Lag of ME modulation/read_all_sheets.R')

##flag 
all_script = FALSE #run all the scritp

# select directory
# DataDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/'
# DataDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/video_cut/'
DataDir = 'C:/Users/MMemeo/OneDrive - Fondazione Istituto Italiano Tecnologia/Documents/GitHub/joint-motor-decision/analyses/'
DataDirObs = 'C:/Users/MMemeo/OneDrive - Fondazione Istituto Italiano Tecnologia/Documents/GitHub/joint-motor-decision/analyses/data_obs/'

# save plots here
#PlotDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/pilotPlots/'
# PlotDir <- 'C:/Users/Laura/Sync/00_Research/2022_UKE/Confidence from motion/04_Analysis/pilotData/pilotPlots/video_cut/'
PlotDir = 'C:/Users/MMemeo/OneDrive - Fondazione Istituto Italiano Tecnologia/Documents/GitHub/joint-motor-decision/analyses/plot/'

# load necessary/useful libraries
## Load libraries
pckgs = c("data.table","lattice","lme4", "nlme","emmeans","doBy","effsize","ez","MuMIn","BayesFactor","permuco","RVAideMemoire",
          "readxl","stringr","knitr","multcomp","ggplot2","car","dplyr", "plyr","lmerTest","ggrepel","sjstats","reshape2","writexl")
sum(lapply(pckgs, require, character.only = TRUE)==FALSE)#Check how many packages failed the loading


##### function to compute means #####
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=TRUE,
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
cursub = "pilotData_all.xlsx" # execution data
Filetmp <- sprintf('%s%s', DataDir, cursub)       # create path

# read all the sheets, i.e. all the pairs data, the from the excel file
dat       = read_all_sheets(Filetmp,"P","A:AH")
list_size = lapply(dat,lengths)
Group     = c(rep(100,list_size[[1]][[1]]),rep(101,list_size[[2]][[1]]),rep(102,list_size[[3]][[1]]),rep(103,list_size[[4]][[1]]))
Trial     = c(1:list_size[[1]][[1]],1:list_size[[2]][[1]],1:list_size[[3]][[1]],1:list_size[[4]][[1]])
curdat    = rbindlist(dat)

curdat$group = Group # add column (at the end) for groupID XXX add as 1st col instead
curdat$trial = Trial

### Order data according to agents
#rt agent 1
rt1_a1=curdat[curdat$AgentTakingFirstDecision==1,c("rt_final1","trial","group")]
rt2_a1=curdat[curdat$AgentTakingSecondDecision==1,c("rt_final2","trial","group")]
names(rt1_a1) = c("rt","trial","group")
names(rt2_a1) = c("rt","trial","group")
drt_a1 = rbind(rt1_a1,rt2_a1)
rt_a1  = with(drt_a1, drt_a1[order(group,trial,rt),])
#rt agent 2
rt1_a2=curdat[curdat$AgentTakingFirstDecision==2,c("rt_final1","trial","group")]
rt2_a2=curdat[curdat$AgentTakingSecondDecision==2,c("rt_final2","trial","group")]
names(rt1_a2) = c("rt","trial","group")
names(rt2_a2) = c("rt","trial","group")
drt_a2 = rbind(rt1_a2,rt2_a2)
rt_a2  = with(drt_a2, drt_a2[order(group,trial,rt),])

#mt agent 1
mt1_a1=curdat[curdat$AgentTakingFirstDecision==1,c("mt_final1","trial","group")]
mt2_a1=curdat[curdat$AgentTakingSecondDecision==1,c("mt_final2","trial","group")]
names(mt1_a1) = c("mt","trial","group")
names(mt2_a1) = c("mt","trial","group")
dmt_a1 = rbind(mt1_a1,mt2_a1)
mt_a1  = with(dmt_a1, dmt_a1[order(group,trial,mt),])
#mt agent 2
mt1_a2=curdat[curdat$AgentTakingFirstDecision==2,c("mt_final1","trial","group")]
mt2_a2=curdat[curdat$AgentTakingSecondDecision==2,c("mt_final2","trial","group")]
names(mt1_a2) = c("mt","trial","group")
names(mt2_a2) = c("mt","trial","group")
dmt_a2 = rbind(mt1_a2,mt2_a2)
mt_a2  = with(dmt_a2, dmt_a2[order(group,trial,mt),])
####

#merge
(rt_a1$trial == rt_a2$trial) && (mt_a1$trial == mt_a2$trial)
curdat$A1_rtKin = rt_a1$rt
curdat$A2_rtKin = rt_a2$rt
curdat$A1_mtKin = mt_a1$mt
curdat$A2_mtKin = mt_a2$mt

#rt - calc the average, se, ci
rt_conf_a1  = curdat[,c("A1_conf","A1_rtKin")]; names(rt_conf_a1) = c("conf","rtKin")
rt_conf_a2  = curdat[,c("A2_conf","A2_rtKin")]; names(rt_conf_a2) = c("conf","rtKin")
rt_conf     = rbind(rt_conf_a1,rt_conf_a2)
rt_conf_sum = summarySE(rt_conf,measurevar="rtKin",groupvars=c("conf"))

#mt - calc the average, se, ci
mt_conf_a1  = curdat[,c("A1_conf","A1_mtKin")]; names(mt_conf_a1) = c("conf","mtKin")
mt_conf_a2  = curdat[,c("A2_conf","A2_mtKin")]; names(mt_conf_a2) = c("conf","mtKin")
mt_conf     = rbind(mt_conf_a1,mt_conf_a2)
mt_conf_sum = summarySE(mt_conf,measurevar="mtKin",groupvars=c("conf"))

names(rt_conf_sum) = c("conf","N","var","sd","se","ci")
names(mt_conf_sum) = c("conf","N","var","sd","se","ci")
mt_rt_conf_sum = rbind(rt_conf_sum,mt_conf_sum); 
mt_rt_conf_sum$var_lab = c(replicate(length(rt_conf_sum), "rt"),replicate(length(mt_conf_sum), "mt"))

# plot that include RT and MT as a function of confidence level (across participants)
pd <- position_dodge(0.001) 
ggplot(mt_rt_conf_sum, aes(x=conf, y=var, color=var_lab, group=var_lab)) + 
        geom_errorbar(aes(ymin=var-se, ymax=var+se), size=0.7, width=.01, position=pd) +
        scale_y_continuous(limits = c(0.25,1.75), breaks=seq(0.25,1.75, by=0.25)) +
        scale_x_discrete(limits = factor(c(1,2,3,4,5,6)), breaks=seq(1,6, by=1)) +
        geom_point(aes(shape=var_lab, color=var_lab, size=var_lab), position=pd) +
        geom_line(aes(linetype=var_lab, color=var_lab), size=1, position=pd) +
        scale_shape_manual(values=c(15, 16)) +
        scale_color_manual(values=c("grey", "black")) +
        scale_linetype_manual(values=c("dotted","solid")) +
        scale_size_manual(values=c(3,3)) +
        xlab("agent confidence") + ylab("time [s]") +   # Set axis labels
        ggtitle("MT/RT as a function of confidence (individual all)") +    # Set title
        theme_bw() +
        theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
              axis.title.x = element_text(face="bold", size=14,vjust=0.1),
              axis.title.y = element_text(face="bold", size=14,vjust=2),
              axis.text.y = element_text(size=12),
              axis.text.x = element_text(size=12),
              panel.border = element_blank(),
              axis.line = element_line(color = 'black'),
              legend.title=element_blank(),
              legend.text = element_text(size=14),
              legend.position=c(0.75,0.9))
ggsave(file=sprintf(("%stime_conf.png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


##### THIS IS NEW
for (v in 1:2){
  
  ################## plot RT and MT as a function of target contrast  ################## 
  if (v==1){lab ="RT"
            all <- curdat[,c("targetContrast","rt_final1","rt_final2","rt_finalColl")]} else {lab="MT"
            all <- curdat[,c("targetContrast","mt_final1","mt_final2","mt_finalColl")]}# 
  
  all_long <- melt(all, id="targetContrast")  # convert to long format
  # rename factor levels
  levels(all_long$variable) <- c("Individual", "Individual", "Collective")
  
  all_sum = summarySE(all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  var = all_sum$value
  
  # rename variables
  names(all_sum)[names(all_sum)=='value'] <- lab
  names(all_sum)[names(all_sum)=='variable'] <- 'DecisionType'
  
  # plot for each pair
  pd <- position_dodge(0.001) 
  print(ggplot(all_sum, aes(x=targetContrast, y=var, color=DecisionType, group=DecisionType)) + 
    geom_errorbar(aes(ymin=var-se, ymax=var+se), size=0.7, width=.01, position=pd) +
    scale_y_continuous(limits = c(0.4,1.5), breaks=seq(0.4,1.5, by=0.1)) +
    # scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
    geom_point(aes(shape=DecisionType, color=DecisionType, size=DecisionType), position=pd) +
    geom_line(aes(linetype=DecisionType, color=DecisionType), size=1, position=pd) +
    scale_shape_manual(values=c(15, 16)) +
    scale_color_manual(values=c("steelblue1", "darkgreen")) +
    scale_linetype_manual(values=c("dotted","solid")) +
    scale_size_manual(values=c(3,3)) +
    xlab("contrast level") + ylab(paste("mean ",lab," [s]")) +   # Set axis labels
    ggtitle(paste(lab," as a function of task difficulty")) +    # Set title
            theme_bw() +
            theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
                  axis.title.x = element_text(face="bold", size=14,vjust=0.1),
                  axis.title.y = element_text(face="bold", size=14,vjust=2),
                  axis.text.y = element_text(size=12),
                  axis.text.x = element_text(size=12),
                  panel.border = element_blank(),
                  axis.line = element_line(color = 'black'),
                  legend.title=element_blank(),
                  legend.text = element_text(size=14),
                  legend.position=c(0.75,0.9)))
    ggsave(file=sprintf(paste0("%s",lab,"_ave.png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  
}

###per group
for (m in 1:2){
  
  ################## plot RT and MT as a function of target contrast/per agent  ################## 
  if (m==1){lab ="RT"
  all <- curdat[,c("targetContrast","A1_rtKin","A2_rtKin","rt_finalColl","group")]
  lim = c(0.2,1.6)} else {lab="MT"
  all <- curdat[,c("targetContrast","A1_mtKin","A2_mtKin","mt_finalColl","group")]
  lim = c(0.5,2.5)}# 
  
  all$group=as.factor(all$group)
  
  for (g in 100:104){
  
  sub_all=all[all$group==g,]
  sub_all=subset(sub_all, select = -c(group) )
  all_long <- melt(sub_all, id="targetContrast")  # convert to long format
  # rename factor levels
  levels(all_long$variable) <- c("A1", "A2", "Collective")
  
  all_sum = summarySE(all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  var = all_sum$value
  
  # rename variables
  names(all_sum)[names(all_sum)=='value'] <- lab
  names(all_sum)[names(all_sum)=='variable'] <- 'DecisionType'
  
  # plot for each pair
  pd <- position_dodge(0.001) 
  print(ggplot(all_sum, aes(x=targetContrast, y=var, color=DecisionType, group=DecisionType)) + 
          geom_errorbar(aes(ymin=var-se, ymax=var+se), size=0.7, width=.01, position=pd) +
          scale_y_continuous(limits = lim, breaks=seq(lim[1],lim[2], by=0.1)) +
          # scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
          geom_point(aes(shape=DecisionType, color=DecisionType, size=DecisionType), position=pd) +
          geom_line(aes(linetype=DecisionType, color=DecisionType), size=1, position=pd) +
          scale_shape_manual(values=c(15, 16, 17)) +
          scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
          scale_linetype_manual(values=c("dotted","dashed","solid")) +
          scale_size_manual(values=c(3,3,3)) +
          xlab("contrast level") + ylab(paste("mean ",lab," [s]")) +   # Set axis labels
          ggtitle(paste(as.character(g)," ",lab," as a function of task difficulty")) +    # Set title
          theme_bw() +
          theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
                axis.title.x = element_text(face="bold", size=14,vjust=0.1),
                axis.title.y = element_text(face="bold", size=14,vjust=2),
                axis.text.y = element_text(size=12),
                axis.text.x = element_text(size=12),
                panel.border = element_blank(),
                axis.line = element_line(color = 'black'),
                legend.title=element_blank(),
                legend.text = element_text(size=14),
                legend.position=c(0.75,0.9)))
  ggsave(file=sprintf(paste0("%s",as.character(g),"_",lab,"_ave.png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  }
}

##### THIS IS NEW

##############################################################################################################
#                                     OBSERVATION                                                            #
##############################################################################################################
curobs = "Results_updated_12012023_magic.xlsx" #observation data
file <- sprintf('%s%s', DataDirObs, curobs) 
# read all the sheets, i.e. all the pairs data, the from the excel file of observation
datObs = read_all_sheets(file,"P","A:U")
curdatObs = rbindlist(datObs)
names(curdatObs)[names(curdatObs)=="Trial"] <- "trial_obs"
names(curdatObs)[names(curdatObs)=="Block"] <- "block_obs"
names(curdatObs)[names(curdatObs)=="Group"] <- "pair_obs"
names(curdatObs)[names(curdatObs)=="CorrResp"] <- "agent_confidence"
names(curdatObs)[names(curdatObs)=="SubjResp"] <- "observer_confidence"
names(curdatObs)[names(curdatObs)=="SubjAcc01"] <- "observer_acc"
names(curdatObs)[names(curdatObs)=="SubjRTnorm"] <- "observer_RTnorm"


#combine execution and observation 
#First remove the trials in which the video was not recorded during execution
exedat      = curdat[-c(2,6,8),]
exedat      = as.data.frame(lapply(exedat, rep, each=4)) #repeat each row 4 times to match the observation data (4 blocks ordered in Excel so that each the first 4 rows represent trial1 from block 1-2-3-4)
exedat_a2a1 = with(exedat, exedat[order(group,-AgentTakingSecondDecision),])#first agent2 acting second, observed by agent1 (to align with obsdat)
names(exedat_a2a1)[names(exedat_a2a1)=="trial"] <- "trial_exe"
names(exedat_a2a1)[names(exedat_a2a1)=="group"] <- "pair_exe"

#Check if the order of agents is the same
all(exedat_a2a1$AgentTakingSecondDecision==curdatObs$Pagent)
all(exedat_a2a1$AgentTakingFirstDecision==curdatObs$Oagent)
if (dim(exedat_a2a1)[1] == dim(curdatObs)[1]){merge = 1}

#merge execution and observation
if (merge) {inout = cbind(exedat_a2a1,curdatObs)}

sinout = inout[,c("pair_exe","pair_obs","Pagent","Oagent","trial_exe","trial_obs","block_obs","Video","targetContrast","firstSecondInterval",
                  "agent_confidence","observer_confidence","observer_acc","observer_RTnorm",
                  "A1_acc","A1_conf","A1_confRT","A2_acc","A2_conf","A2_confRT","Coll_acc","Coll_conf","Coll_confRT",
                  "AgentTakingSecondDecision","rt_final2","mt_final2","A1_rtKin","A2_rtKin","A1_mtKin","A2_mtKin")]


# prepare plotting
#rt - calc the average, se, ci
rt_confObs  = sinout[,c("observer_confidence","rt_final2")]; names(rt_confObs) = c("observer_confidence","time")
rt_confObs_sum = summarySE(rt_confObs,measurevar="time",groupvars=c("observer_confidence"))

#mt - calc the average, se, ci
mt_confObs  = sinout[,c("observer_confidence","mt_final2")]; names(mt_confObs) = c("observer_confidence","time")
mt_confObs_sum = summarySE(mt_confObs,measurevar="time",groupvars=c("observer_confidence"))

names(rt_confObs_sum) = c("observer_confidence","N","var","sd","se","ci")
names(mt_confObs_sum) = c("observer_confidence","N","var","sd","se","ci")
mt_rt_confObs_sum = rbind(rt_confObs_sum,mt_confObs_sum); 
mt_rt_confObs_sum = mt_rt_confObs_sum[!is.na(mt_rt_confObs_sum$observer_confidence),]
mt_rt_confObs_sum$var_lab = c(replicate(length(rt_confObs_sum), "rt"),replicate(length(mt_confObs_sum), "mt"))


##  
ggplot(mt_rt_confObs_sum, aes(x=observer_confidence, y=var, color=var_lab, group=var_lab)) + 
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=0.7, width=.01, position=pd) +
  scale_y_continuous(limits = c(0.25,1.75), breaks=seq(0.25,1.75, by=0.25)) +
  scale_x_discrete(limits = factor(c(1,2,3,4,5,6)), breaks=seq(1,6, by=1)) +
  geom_point(aes(shape=var_lab, color=var_lab, size=var_lab), position=pd) +
  geom_line(aes(linetype=var_lab, color=var_lab), size=1, position=pd) +
  scale_shape_manual(values=c(15, 16)) +
  scale_color_manual(values=c("grey", "black")) +
  scale_linetype_manual(values=c("dotted","solid")) +
  scale_size_manual(values=c(3,3)) +
  xlab("observer confidence") + ylab("time [s]") +   # Set axis labels
  ggtitle("MT/RT as a function of confidence (indivdual 2nd)") +    # Set title
  theme_bw() +
  theme(plot.title = element_text(face="bold", size=18, hjust = 0.5),
        axis.title.x = element_text(face="bold", size=14,vjust=0.1),
        axis.title.y = element_text(face="bold", size=14,vjust=2),
        axis.text.y = element_text(size=12),
        axis.text.x = element_text(size=12),
        panel.border = element_blank(),
        axis.line = element_line(color = 'black'),
        legend.title=element_blank(),
        legend.text = element_text(size=14),
        legend.position=c(0.75,0.9))
ggsave(file=sprintf(("%stime_obs_conf.png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)




if (all_script){
## BELOW ARE THE PLOTS THAT WE DID FOR THE PREVIOUS VERSION OF THE RT ######################################

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
        axis.line = element_line(color = 'black'),
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

#https://es.sonicurlprotection-fra.com/click?PV=2&MSGID=202301111614160142157&URLID=1&ESV=10.0.19.7431&IV=BAD6512CAE5511F393A81FF3342D7CF1&TT=1673453657212&ESN=6RqFVHQ3UCp8TU9tR5eie7OtUmOEYnwkhc24442tYcU%3D&KV=1536961729280&B64_ENCODED_URL=aHR0cHM6Ly9yLWNoYXJ0cy5jb20vZGlzdHJpYnV0aW9uL2hpc3RvZ3JhbS1ncm91cC1nZ3Bsb3QyLw&HK=DC2FA2A0C28F7BA64EE2B6864EF8555DD2A90BFA1F64E405B62B31A19F8B5F11

##################
collect_dat = rbind(collect_dat, curdat_filt) # combine all subjects' data


################################################################################
#################### plot as a function of difficulty ##########################
################################################################################




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
}





# colnames(curdat_filt) <-
#   c(
#     "targetContrast",
#     "targetInterval",
#     "targetLocation",
#     "A1_decision",
#     "A1_accuracy",
#     "A1_RT",
#     "A1_MT",
#     "A1_Confidence",
#     "A1_ConfRT",
#     "A2_decision",
#     "A2_accuracy",
#     "A2_RT",
#     "A2_MT",
#     "A2_Confidence",
#     "A2_ConfRT",
#     "Coll_decision",
#     "Coll_accuracy",
#     "Coll_RT",
#     "Coll_MT",
#     "Coll_Confidence",
#     "Coll_ConfRT",
#     "Agent1stDecision",
#     "Agent2ndDecision" ,
#     "AgentCollDecision",
#     "rt_final1","rt_final2","rt_finalColl","mt_final1","mt_final2","mt_finalColl"
#     )
