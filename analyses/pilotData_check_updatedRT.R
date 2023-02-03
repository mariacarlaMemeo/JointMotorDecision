## Script to analyze JMD pilot data collected in November 2022

#Remove variables and plots
rm(list = ls())
graphics.off()

#Load necessary/useful libraries
pckgs = c("data.table","lattice","lme4", "nlme","emmeans","doBy","effsize","ez","MuMIn","BayesFactor","permuco","RVAideMemoire","this.path",
          "RColorBrewer","readxl","stringr","knitr","multcomp","ggplot2","car","dplyr", "plyr","lmerTest","ggrepel","sjstats","reshape2","writexl")
sum(lapply(pckgs, require, character.only = TRUE)==FALSE)#Check how many packages failed the loading

#Retrieve the directory of the current file and create the main directory path
slash   = unlist(gregexpr("/", this.path()))
DataDir = substr(this.path(),1,slash[length(slash)])
#Save plots here
PlotDir = paste0(DataDir,"plot/")

#Call needed functions 
source(paste0(DataDir,'read_all_sheets.R'))
source(paste0(DataDir,'summarySE.R'))
source(paste0(DataDir,'theme_custom.R'))

##############################################################################################################
#                                     EXECUTION                                                              #
##############################################################################################################
#Create data frame of execution part - retrieve data from an Excel file that was manually created by merging the single pair files. 
#Single pair files were created with movement_onset.m matlab file, starting from the .mat files acquired during the exp.
cursub = "pilotData_all.xlsx" # execution data
Filetmp <- sprintf('%s%s', DataDir, cursub)       # create path

#Read all the sheets till the selected columns and create curdat dataframe.
dat       = read_all_sheets(Filetmp,"P","A:AH")
list_size = lapply(dat,lengths)
group     = c(rep(100,list_size[[1]][[1]]),rep(101,list_size[[2]][[1]]),rep(102,list_size[[3]][[1]]),rep(103,list_size[[4]][[1]]))
trial     = c(1:list_size[[1]][[1]],1:list_size[[2]][[1]],1:list_size[[3]][[1]],1:list_size[[4]][[1]])
#Rbind all the excel sheets
curdat    = rbindlist(dat)
curdat    = cbind(group,trial,curdat) # added at the beginning of the dataframe
#Add a column to express the agreement on the perceptual task between the 2 agents. [1=agreement, -1=disagreement]
curdat$agree = as.integer(curdat$A1_decision == curdat$A2_decision)
curdat$agree[curdat$agree==0]=-1

#Remove pair 102 - didn't follow the instructions
if(schon_data){curdat    = curdat[curdat$group!=102,]
               schon_lab = "noPair102" } else{schon_lab = ""}

#configure plot variables
pd         = position_dodge(0.001)
conf_lim   = c(1,6)
conf_break = seq(1,6, by=1)


##################  CONFIDENCE BY TARGET CONTRASTS  ##################
#According to the level of agreement
conf_all <- curdat[,c("targetContrast","A1_conf","A2_conf","Coll_conf","agree")]
conf_all_long <- melt(conf_all, id=c("targetContrast","agree"))  # convert to long format
levels(conf_all_long$variable) <- c("Individual", "Individual", "Collective")
conf_all_sum = summarySE(conf_all_long,measurevar="value",groupvars=c("variable","targetContrast","agree"))
# rename variables
names(conf_all_sum)[names(conf_all_sum)=='value'] <- 'Confidence'
names(conf_all_sum)[names(conf_all_sum)=='variable'] <- 'DecisionType'
# rename factor levels
conf_all_sum$agree = as.factor(conf_all_sum$agree)
levels(conf_all_sum$agree) <- c("disagree", "agree")

# plot - Confidence level by agreement 
print(ggplot(conf_all_sum, aes(x=targetContrast, y=Confidence, color=DecisionType, shape=agree)) +
        geom_errorbar(aes(ymin=Confidence-se, ymax=Confidence+se), size=0.7, width=.01, position=pd) +
        scale_y_continuous(limits = conf_lim, breaks=conf_break) +
        geom_point(aes(shape=agree, color=DecisionType), size = 3,position=pd) +
        geom_line(aes(linetype=agree), size=1, position=pd) +
        scale_color_manual(values=c("steelblue1", "darkgreen")) +
        scale_linetype_manual(values=c("dashed","solid"))+
        ggtitle("Confidence level by agreement") + theme_custom())
ggsave(file=paste0(PlotDir,"conf_agree_individual",schon_lab,".png"), dpi = 300, units=c("cm"), height =20, width = 20)



#According to the level of agreement and accuracy (only collective)
conf_all_acc <- curdat[,c("targetContrast","Coll_acc","Coll_conf","agree")]
conf_all_long_acc <- melt(conf_all_acc, id=c("targetContrast","agree","Coll_acc"))  # convert to long format
conf_all_sum_acc = summarySE(conf_all_long_acc,measurevar="value",groupvars=c("targetContrast","agree","Coll_acc"))
# rename variables
names(conf_all_sum_acc)[names(conf_all_sum_acc)=='value'] <- 'Confidence'
names(conf_all_sum_acc)[names(conf_all_sum_acc)=='Coll_acc'] <- 'Accuracy'
# rename factor levels
conf_all_sum_acc$agree = as.factor(conf_all_sum_acc$agree)
levels(conf_all_sum_acc$agree) <- c("disagree", "agree")
conf_all_sum_acc$Accuracy = as.factor(conf_all_sum_acc$Accuracy)
levels(conf_all_sum_acc$Accuracy) <- c("incorrect", "correct")

# plot - Confidence level by agreement and accuracy (only collective) 

print(ggplot(conf_all_sum_acc, aes(x=targetContrast, y=Confidence, color=Accuracy, shape=agree)) +
  geom_errorbar(aes(ymin=Confidence-se, ymax=Confidence+se), size=0.7, width=.01, position=pd) +
  scale_y_continuous(limits = conf_lim, breaks=conf_break) +
  geom_point(aes(shape=agree, color=Accuracy), size = 3,position=pd) +
  geom_line(aes(linetype=agree), size=1, position=pd) +
  scale_color_manual(values=c("red", "green")) +
  scale_linetype_manual(values=c("dashed","solid"))+ theme_custom())
ggsave(file=paste0(PlotDir,"conf_agree_corr_coll",schon_lab,".png"), dpi = 300, units=c("cm"), height =20, width = 20)


########################################################

##################  RT and MT BY CONFIDENCE   ##################
#Create a column containing the confidence of the 1st and 2nd decisions
#First decision
a1_conf_1d = curdat[curdat$AgentTakingFirstDecision==1,c("A1_conf","trial","group")]
a2_conf_1d = curdat[curdat$AgentTakingFirstDecision==2,c("A2_conf","trial","group")]
names(a1_conf_1d) = c("conf","trial","group")
names(a2_conf_1d) = c("conf","trial","group")
dconf_1d    = rbind(a1_conf_1d,a2_conf_1d)    
conf_1d  = with(dconf_1d, dconf_1d[order(group,trial,conf),])

#Second decision
a1_conf_2d =curdat[curdat$AgentTakingSecondDecision==1,c("A1_conf","trial","group")]
a2_conf_2d =curdat[curdat$AgentTakingSecondDecision==2,c("A2_conf","trial","group")]
names(a1_conf_2d) = c("conf","trial","group")
names(a2_conf_2d) = c("conf","trial","group")
dconf_2d    = rbind(a1_conf_2d,a2_conf_2d)    
conf_2d  = with(dconf_2d, dconf_2d[order(group,trial,conf),])

#add the new variable to the dataframe of execution 
curdat$conf_1d = conf_1d$conf
curdat$conf_2d = conf_2d$conf

#
#rt 2nd decision - calc the average, se, ci
rt_conf_2d  = curdat[,c("conf_2d","rt_final2")]; names(rt_conf_2d) = c("conf2","rtKin2")
rt_conf_2d_sum = summarySE(rt_conf_2d,measurevar="rtKin2",groupvars=c("conf2"))

#mt 2nd decision - calc the average, se, ci
mt_conf_2d  = curdat[,c("conf_2d","mt_final2")]; names(mt_conf_2d) = c("conf2","mtKin2")
mt_conf_2d_sum = summarySE(mt_conf_2d,measurevar="mtKin2",groupvars=c("conf2"))

names(rt_conf_2d_sum) = c("conf2","N","var","sd","se","ci")
names(mt_conf_2d_sum) = c("conf2","N","var","sd","se","ci")
mt_rt_conf_2d_sum = rbind(rt_conf_2d_sum,mt_conf_2d_sum); 
mt_rt_conf_2d_sum$var_lab = c(replicate(length(rt_conf_2d_sum), "rt"),replicate(length(mt_conf_2d_sum), "mt"))


# plot that include RT and MT as a function of confidence level (across participants)

print(ggplot(mt_rt_conf_2d_sum, aes(x=conf2, y=var, color=var_lab, group=var_lab)) + 
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=0.7, width=.01, position=pd) +
  scale_y_continuous(limits = c(0.25,1.75), breaks=seq(0.25,1.75, by=0.25)) +
  scale_x_discrete(limits = factor(c(1,2,3,4,5,6)), breaks=conf_break) +
  geom_point(aes(shape=var_lab, color=var_lab, size=var_lab), position=pd) +
  geom_line(aes(linetype=var_lab, color=var_lab), size=1, position=pd) +
  scale_shape_manual(values=c(15, 16)) +
  scale_color_manual(values=c("grey", "black")) +
  scale_linetype_manual(values=c("dotted","solid")) +
  scale_size_manual(values=c(3,3)) +
  xlab("agent confidence") + ylab("time [s]") +   # Set axis labels
  ggtitle(paste0("MT/RT as a function of confidence (individual 2nd) ",schon_lab)) + theme_custom())
ggsave(file=sprintf(paste0("%stime_conf_2d",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


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

# # plot that include RT and MT as a function of confidence level (across participants)
# ggplot(mt_rt_conf_sum, aes(x=conf, y=var, color=var_lab, group=var_lab)) + 
#         geom_errorbar(aes(ymin=var-se, ymax=var+se), size=0.7, width=.01, position=pd) +
#         scale_y_continuous(limits = c(0.25,1.75), breaks=seq(0.25,1.75, by=0.25)) +
#         scale_x_discrete(limits = factor(c(1,2,3,4,5,6)), breaks=conf_break) +
#         geom_point(aes(shape=var_lab, color=var_lab, size=var_lab), position=pd) +
#         geom_line(aes(linetype=var_lab, color=var_lab), size=1, position=pd) +
#         scale_shape_manual(values=c(15, 16)) +
#         scale_color_manual(values=c("grey", "black")) +
#         scale_linetype_manual(values=c("dotted","solid")) +
#         scale_size_manual(values=c(3,3)) +
#         xlab("agent confidence") + ylab("time [s]") +   # Set axis labels
#         ggtitle("MT/RT as a function of confidence (individual all)") + theme_custom())
# ggsave(file=paste0(PlotDir,"time_conf",schon_lab,".png"), dpi = 300, units=c("cm"), height =20, width = 20)
########################################################

##################  CONFIDENCE BY MT ##################
conf_a1a2 = curdat[,c("group","A1_conf","A2_conf")]
conf_a1a2_long <- melt(conf_a1a2, id=c("group"))

mt_a1a2 = curdat[,c("group","A1_mtKin","A2_mtKin")]
mt_a1a2_long <- melt(mt_a1a2, id=c("group")); names(mt_a1a2_long) = c("group","label_mt","mtKin")

conf_mt_a1a2         = cbind(conf_a1a2_long,mt_a1a2_long)
conf_mt_a1a2$agent   = c(rep("A1",length(curdat$A1_mtKin)),rep("A2",length(curdat$A1_mtKin)))
names(conf_mt_a1a2)  = c("group","label_conf","Confidence","group_spare","label_mt","MovementTime","agent")
conf_mt_a1a2         = subset(conf_mt_a1a2,select=-c(group_spare,label_mt,label_conf))
conf_mt_a1a2$subject = interaction(conf_mt_a1a2$agent,conf_mt_a1a2$group)
conf_mt_a1a2         = subset(conf_mt_a1a2,select=-c(group,agent))

#Movement Time contains multiple NA values. They are not used to calculated the average
aveConf = summarySE(conf_mt_a1a2,measurevar="Confidence",groupvars="subject")
aveMt   = summarySE(conf_mt_a1a2,measurevar="MovementTime",groupvars="subject");names(aveMt)=c("subject_mt","N_mt","MovementTime","sd_mt","se_mt","ci_mt")
#bind MT and confidence averaged values
aveConf_Mt = cbind(aveConf,aveMt)
aveConf_Mt = subset(aveConf_Mt,select=-c(subject_mt))

print(ggplot(aveConf_Mt, aes(x=MovementTime, y=Confidence, color=subject)) +
        geom_errorbar(aes(ymin=Confidence-se, ymax=Confidence+se), size=0.7, width=.01, position=pd) +
        scale_y_continuous(limits = conf_lim, breaks=conf_break) +
        geom_point(aes(color=subject), size = 3,position=pd) +
        ggtitle("Mean confidence and Mean MT") + theme_custom())
# ggsave(file=paste0(PlotDir,"conf_agree_individual",schon_lab,".png"), dpi = 300, units=c("cm"), height =20, width = 20)


########################################################

###################### RT and MT BY TARGET CONTRASTS ###################################

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
    ggtitle(paste(lab," as a function of task difficulty")) + theme_custom())
    ggsave(file=sprintf(paste0("%s",lab,"_ave",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  
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
  if(schon_data){all_pairs = c(100,101,103)} else{all_pairs = c(100,101,102,103)}
  
  for (g in all_pairs){
  
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
          ggtitle(paste(as.character(g)," ",lab," as a function of task difficulty")) + theme_custom())
  ggsave(file=sprintf(paste0("%s",as.character(g),"_",lab,"_ave",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  }
}
########################################################


##############################################################################################################
#                                     OBSERVATION                                                            #
##############################################################################################################
curobs = "Results_updated_24012023_magic.xlsx" #observation data
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

if(schon_data){curdatObs    = curdatObs[curdatObs$pair_obs!=102,]}

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
                  "agent_confidence","observer_confidence","observer_acc","observer_RTnorm","agree",
                  "A1_acc","A1_conf","A1_confRT","A2_acc","A2_conf","A2_confRT","Coll_acc","Coll_conf","Coll_confRT",
                  "AgentTakingSecondDecision","rt_final2","mt_final2","A1_rtKin","A2_rtKin","A1_mtKin","A2_mtKin")]

#calculating average values of confidence for each video because in observation we show videos 4 times
sinout = transformBy(~Video+pair_obs,data=sinout, conf_aveBlock = round(mean(as.numeric(observer_confidence),na.rm=T),1))
#calculating the difference between averaged obs confidence and agent confidence - confidence for the same action 
sinout$diff_conf = sinout$conf_aveBlock-sinout$agent_confidence
#calculating the difference in movement time between the agents in a pair - absolute value
sinout$diff_mt   = round(abs(sinout$A1_mtKin - sinout$A2_mtKin),2)
#calculating the difference in movement time between the agents in a pair - signed values
sinout$diff_mt_signed   = round(sinout$A1_mtKin - sinout$A2_mtKin,2)

## Selection of only 1 block because the values of confidence are averaged across blocks 
sinout_1block = sinout[sinout$block_obs==1,] 



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
print(ggplot(mt_rt_confObs_sum, aes(x=observer_confidence, y=var, color=var_lab, group=var_lab)) + 
  geom_errorbar(aes(ymin=var-se, ymax=var+se), size=0.7, width=.01, position=pd) +
  scale_y_continuous(limits = c(0.25,1.9), breaks=seq(0.25,1.9, by=0.25)) +
  scale_x_discrete(limits = factor(c(1,2,3,4,5,6)), breaks=conf_break) +
  geom_point(aes(shape=var_lab, color=var_lab, size=var_lab), position=pd) +
  geom_line(aes(linetype=var_lab, color=var_lab), size=1, position=pd) +
  scale_shape_manual(values=c(15, 16)) +
  scale_color_manual(values=c("grey", "black")) +
  scale_linetype_manual(values=c("dotted","solid")) +
  scale_size_manual(values=c(3,3)) +
  xlab("observer confidence") + ylab("time [s]") +   # Set axis labels
  ggtitle("MT/RT as a function of confidence (individual 2nd)") + theme_custom())
ggsave(file=sprintf(paste0("%stime_obs_conf",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


#### Plot agent confidence vs observer confidence (all agents together)
# Linear regression: take observed conf. as predictor for subjective conf.
fit <- lm(sinout$agent_confidence ~ sinout$observer_confidence)
summary(fit)
Rsquared <- summary(fit)$r.squared
print(Rsquared,digits=3)
## Scatterplot
# include linear trend + confidence interval (se)
# jitter the points to avoid overlay of data points (jitter range: 0.5 on both axes)
conf_exe_obs = ggplot(sinout, aes(x = observer_confidence, y = agent_confidence)) +
  geom_point(shape = 1,   # Use hollow circles
    position = position_jitter(width = 0.1, height = .1)) +
  geom_smooth(method = lm, # Add linear regression line
    color = "blue", fill = "#69b3a2",se = TRUE) +
  annotate("text", x=1.5, y=6, label = paste("R2 = ", format(summary(fit)$r.squared,digits=3)), col="black", cex=6)+
  ggtitle("Agent confidence vs observer confidence")
ggsave(file=sprintf(paste0("%sexeconf_vs_obsconf",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
print(conf_exe_obs)


## Scatterplot - average value of confidence for Observation
# Linear regression: take observed conf. as predictor for subjective conf.
fit_ave <- lm(sinout_1block$conf_aveBlock ~ sinout_1block$agent_confidence) 
summary(fit_ave)
Rsquared <- summary(fit_ave)$r.squared
print(Rsquared,digits=3)
conf_exe_obsAve = ggplot(sinout_1block, aes(x = agent_confidence, y = conf_aveBlock)) +
  geom_point(shape = 1,   # Use hollow circles
             position = position_jitter(width = 0.1, height = .1)) +
  scale_y_discrete(limits = factor(c(1,2,3,4,5,6)), breaks=conf_break) +
  scale_x_discrete(limits = factor(c(1,2,3,4,5,6)), breaks=conf_break) +
  geom_smooth(method = lm, # Add linear regression line
              color = "blue", fill = "#69b3a2",se = TRUE) +
  annotate("text", x=5, y=1, label = paste("R2 = ", format(summary(fit_ave)$r.squared,digits=3)), col="black", cex=6)+
  ggtitle("Observer confidence vs Agent confidence")
ggsave(file=sprintf(paste0("%sexeconf_vs_obsconfAveraged",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
print(conf_exe_obsAve + labs(y = "Mean observer confidence", x = "agent confidence"))


## multiple facets with all the agents
#https://r-graphics.org/recipe-annotate-facet
# lm_labels <- function(sinout) {
#   mod <- lm(agent_confidence ~ observer_confidence, data = sinout)
#   formula <- sprintf("italic(y) == %.2f %+.2f * italic(x)",
#                      round(coef(mod)[1], 3), round(coef(mod)[2], 3))
#   r <- cor(sinout$observer_confidence, sinout$agent_confidence, use="complete.obs")
#   r2 <- sprintf("R^2 == %.2f", r^2)
#   data.frame(formula = formula, r2 = r2, stringsAsFactors = FALSE)
# }
# 
# 
# labels <- sinout %>%
#   group_by(interaction(pair_obs,Oagent))%>%
#   summarise(lm_labels)


mpg_plot <- ggplot(sinout, aes(x = observer_confidence, y = agent_confidence)) +
  geom_point() +
  facet_grid(. ~ interaction(pair_obs,Oagent))+#rows = 2, cols = 4,
  geom_point(shape = 1,   # Use hollow circles
             position = position_jitter(width = 0.1, height = .1)) +
  geom_smooth(method = lm, # Add linear regression line
              color = "blue", fill = "#69b3a2",se = TRUE) 
ggsave(file=sprintf(paste0("%sexeconf_vs_obsconf_perPair",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 80)
print(mpg_plot)



#### Plot (averaged obs conf - agent conf) vs contrast level
# (averaged obs conf - agent conf) vs contrast level - calc the average, se, ci
diffConf_targ  = sinout_1block[,c("targetContrast","diff_conf","pair_obs","Oagent")]
diffConf_targ_sum = summarySE(diffConf_targ,measurevar="diff_conf",groupvars=c("targetContrast","pair_obs","Oagent"))

print(ggplot(diffConf_targ_sum, aes(x=targetContrast, y=diff_conf, color=interaction(Oagent,pair_obs))) + 
  geom_errorbar(aes(ymin=diff_conf-se, ymax=diff_conf+se), size=0.7, width=.01, position=pd) +
  scale_y_continuous(limits = c(-0.2,2.8), breaks=seq(-0.2,2.8, by=0.2)) +
  scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
  geom_point(aes(color=interaction(Oagent,pair_obs))) + 
  ylab("(mean obs confidence - agent confidence) ") +
  geom_line(aes(linetype=interaction(Oagent,pair_obs), color=interaction(Oagent,pair_obs)), size=1)+
  scale_color_brewer(palette = "Paired"))
ggsave(file=sprintf(paste0("%sdiffConf_vs_contrasts",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)


## (averaged obs conf - agent conf) vs movement time
## averaged movement time - divided by CONTRAST/agent/group
diffConf_mt  = sinout_1block[,c("targetContrast","diff_conf","diff_mt","pair_obs","Oagent")]
diffConf_mt_sum = summarySE(diffConf_mt,measurevar="diff_mt",groupvars=c("targetContrast","pair_obs","Oagent"))
diffConf_mt_sum$diff_conf = diffConf_targ_sum$diff_conf

## averaged movement time - divided by AGENT/group
diffConf_diffMt  = sinout_1block[,c("diff_conf","diff_mt","pair_obs","Oagent")]
sub_mt           = summarySE(diffConf_diffMt,measurevar="diff_mt",groupvars=c("pair_obs"));names(sub_mt)=c("pair_obs","N_mt","diff_mt","sd_mt","se_mt","ci_mt")
sub_mt           = sub_mt[rep(seq_len(nrow(sub_mt)), each = 2), ]
sub_conf         = summarySE(diffConf_diffMt,measurevar="diff_conf",groupvars=c("pair_obs","Oagent"));names(sub_conf)=c("pair_obs","Oagent","N_conf","diff_conf","sd_conf","se_conf","ci_conf")
diffConf_diffMt_sum  = cbind(sub_mt,sub_conf[,c("Oagent","N_conf","diff_conf","sd_conf","se_conf","ci_conf")])

#fitting a line
fit_ave_confMt <- lm(diffConf_diffMt$diff_mt ~ diffConf_diffMt$diff_conf) 
summary(fit_ave_confMt)
Rsquared <- summary(fit_ave_confMt)$r.squared


# scatterplot - check each agent
# difference in MT include 1st and 2nd decision
# difference in confidence is always referred to the 2nd decision
print(ggplot(diffConf_diffMt_sum, aes(x=diff_mt, y=diff_conf, color=interaction(Oagent,pair_obs))) + 
  geom_errorbar(aes(ymin=diff_conf-se_conf, ymax=diff_conf+se_conf), size=0.7, width=.01, position=pd) +
  geom_point(aes(color=interaction(Oagent,pair_obs))) + 
  scale_color_brewer(palette = "Paired"))
ggsave(file=sprintf(paste0("%sdiffConf_vs_diffMt",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)



#######
sub_s         = sinout_1block[,c("pair_obs","Pagent","Oagent","agent_confidence","conf_aveBlock","diff_mt_signed")]
sub_s         = transformBy(~pair_obs,data=sub_s, diff_mt_signedAve = round(mean(as.numeric(diff_mt_signed),na.rm=T),3))

pcon_A1_all   = sub_s[sub_s$Pagent==1,c("pair_obs","agent_confidence","diff_mt_signedAve")] 
pcon_A1_long  = melt(pcon_A1_all, id="pair_obs")
pcon_A1       = summarySE(pcon_A1_long,measurevar="value",groupvars=c("pair_obs","variable"))
pcon_A1$agent = rep(1,dim(pcon_A1)[1])

pcon_A2_all = sub_s[sub_s$Pagent==2,c("pair_obs","agent_confidence","diff_mt_signedAve")]
pcon_A2_long = melt(pcon_A2_all, id="pair_obs")
pcon_A2     = summarySE(pcon_A2_long,measurevar="value",groupvars=c("pair_obs","variable"))
pcon_A2$agent = rep(2,dim(pcon_A2)[1])

icon_A1_all = sub_s[sub_s$Oagent==1,c("pair_obs","conf_aveBlock","diff_mt_signedAve")] 
icon_A1_long = melt(icon_A1_all, id="pair_obs")
icon_A1     = summarySE(icon_A1_long,measurevar="value",groupvars=c("pair_obs","variable"))
icon_A1$agent = rep(1,dim(icon_A1)[1])

icon_A2_all = sub_s[sub_s$Oagent==2,c("pair_obs","conf_aveBlock","diff_mt_signedAve")] 
icon_A2_long = melt(icon_A2_all, id="pair_obs")
icon_A2     = summarySE(icon_A2_long,measurevar="value",groupvars=c("pair_obs","variable"))
icon_A2$agent = rep(2,dim(icon_A2)[1])


#merge
pcon                = rbind(pcon_A1,pcon_A2); names(pcon) = c("pair","var_pCon","N_pCon","pCon","sd_pCon","se_pCon","ci_pCon","agent")
icon                = rbind(icon_A1,icon_A2); names(icon) = c("pair","var_iCon","N_iCon","iCon","sd_iCon","se_iCon","ci_iCon","agent");icon = icon[,c("var_iCon","N_iCon","iCon","sd_iCon","se_iCon","ci_iCon")];
mergissimo          = cbind(pcon,icon)
mergissimo_sub      = mergissimo[mergissimo$var_pCon!="diff_mt_signedAve",]
mergissimo_sub$iconHigh = as.numeric(mergissimo_sub$pCon[mergissimo_sub$var_pCon=="agent_confidence"] < mergissimo_sub$iCon[mergissimo_sub$var_iCon=="conf_aveBlock"])
mergissimo_mt       = mergissimo[mergissimo$var_pCon=="diff_mt_signedAve",]
mergissimo_mt       = mergissimo_mt[,"pCon"]
pCon_iCon           = cbind(mergissimo_sub,mergissimo_mt); names(pCon_iCon)[names(pCon_iCon)=="mergissimo_mt"]="diff_mt_signedAve"

pCon_iCon$diff_mt_signedAve[pCon_iCon$agent==2] = -(pCon_iCon$diff_mt_signedAve[pCon_iCon$agent==2])

inter_agent_pair    = interaction(pCon_iCon$agent,pCon_iCon$pair)
inter_agent_pair    = factor(inter_agent_pair, levels = c("1.100", "1.101", "1.103","2.100", "2.101", "2.103"))

print(ggplot(pCon_iCon, aes(x=inter_agent_pair, y=diff_mt_signedAve, color=inter_agent_pair, shape=as.factor(iconHigh))) + 
        geom_point(aes(color=inter_agent_pair,shape=as.factor(iconHigh),size=3)) + 
        labs( y = "Difference in MT (A1 - A2)", x = "Agent and Pair"))
        # scale_color_brewer(palette = "Paired"))
ggsave(file=sprintf(paste0("%sdiff_mt_pCon_iCon",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)


# if (all_script){
# ## BELOW ARE THE PLOTS THAT WE DID FOR THE PREVIOUS VERSION OF THE RT ######################################
# 
# # reshape data to long format, to include A1, A2, and Coll in one plot
# ##################  ACCURACY  ################## 
# accuracy_all <- curdat_filt[,c("targetContrast","A1_accuracy","A2_accuracy","Coll_accuracy")]
# accuracy_all_long <- melt(accuracy_all, id="targetContrast")  # convert to long format
# accuracy_all_sum = summarySE(accuracy_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
# # rename variables
# names(accuracy_all_sum)[names(accuracy_all_sum)=='value'] <- 'Accuracy'
# names(accuracy_all_sum)[names(accuracy_all_sum)=='variable'] <- 'Agent'
# # rename factor levels
# levels(accuracy_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
# 
# # plot for each pair
# group_acc <- accuracy_all_sum
# ggplot(group_acc, aes(x=targetContrast, y=Accuracy, color=Agent, group=Agent)) + 
#   geom_errorbar(aes(ymin=Accuracy-se, ymax=Accuracy+se), size=0.7, width=.01, position=pd) +
#   scale_y_continuous(limits = c(0.4,1.0), breaks=seq(0.3,1.1, by=0.1)) +
#   scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
#   geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
#   geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
#   scale_shape_manual(values=c(15, 16, 17)) +
#   scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
#   scale_linetype_manual(values=c("dotted","dashed","solid")) +
#   scale_size_manual(values=c(3,3,3)) +
#   xlab("contrast level") + ylab("mean accuracy") +   # Set axis labels
#   ggtitle("Perceptual accuracy") + theme_custom()) 
# #legend.position=c(1,0) / scale_fill_discrete(labels = c("A", "B", "C"))
# 
# # save plots XXX adjust this to save for each pair
# #ggsave(pilotAcc, file=sprintf("%spilotAcc.png",PlotDir), dpi = 300, units=c("cm"), height =20, width = 12)
# 
# ################## REACTION TIME ##################
# rt_all <- curdat_filt[,c("targetContrast","A1_RT","A2_RT","Coll_RT")]
# rt_all_long <- melt(rt_all, id="targetContrast")  # convert to long format
# rt_all_sum = summarySE(rt_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
# # rename variables
# names(rt_all_sum)[names(rt_all_sum)=='value'] <- 'RT'
# names(rt_all_sum)[names(rt_all_sum)=='variable'] <- 'Agent'
# # rename factor levels
# levels(rt_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
# 
# # plot for each pair
# group_rt <- rt_all_sum
# pd <- position_dodge(0.001) 
# ggplot(group_rt, aes(x=targetContrast, y=RT, color=Agent, group=Agent)) + 
#   geom_errorbar(aes(ymin=RT-se, ymax=RT+se), size=0.7, width=.01, position=pd) +
#   scale_y_continuous(limits = c(0,3000), breaks=seq(0,3000, by=500)) +
#   scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
#   geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
#   geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
#   scale_shape_manual(values=c(15, 16, 17)) +
#   scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
#   scale_linetype_manual(values=c("dotted","dashed","solid")) +
#   scale_size_manual(values=c(3,3,3)) +
#   xlab("contrast level") + ylab("mean RT (ms)") +   # Set axis labels
#   ggtitle("Reaction time") + theme_custom())
# 
# ################## MOVEMENT TIME ##################
# mt_all <- curdat_filt[,c("targetContrast","A1_MT","A2_MT","Coll_MT")]
# mt_all_long <- melt(mt_all, id="targetContrast")  # convert to long format
# mt_all_sum = summarySE(mt_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
# # rename variables
# names(mt_all_sum)[names(mt_all_sum)=='value'] <- 'MT'
# names(mt_all_sum)[names(mt_all_sum)=='variable'] <- 'Agent'
# # rename factor levels
# levels(mt_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
# 
# # plot for each pair
# group_mt <- mt_all_sum
# pd <- position_dodge(0.001) 
# ggplot(group_mt, aes(x=targetContrast, y=MT, color=Agent, group=Agent)) + 
#   geom_errorbar(aes(ymin=MT-se, ymax=MT+se), size=0.7, width=.01, position=pd) +
#   scale_y_continuous(limits = c(250,1750), breaks=seq(250,1750, by=250)) +
#   scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
#   geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
#   geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
#   scale_shape_manual(values=c(15, 16, 17)) +
#   scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
#   scale_linetype_manual(values=c("dotted","dashed","solid")) +
#   scale_size_manual(values=c(3,3,3)) +
#   xlab("contrast level") + ylab("mean MT (ms)") +   # Set axis labels
#   ggtitle("Movement time") + theme_custom())


# ##################  CONFIDENCE   ################## 
# conf_all <- curdat_filt[,c("targetContrast","A1_Confidence","A2_Confidence","Coll_Confidence")]
# conf_all_long <- melt(conf_all, id="targetContrast")  # convert to long format
# conf_all_sum = summarySE(conf_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
# # rename variables
# names(conf_all_sum)[names(conf_all_sum)=='value'] <- 'Confidence'
# names(conf_all_sum)[names(conf_all_sum)=='variable'] <- 'Agent'
# # rename factor levels
# levels(conf_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
# 
# # plot for each pair
# group_conf <- conf_all_sum
# pd <- position_dodge(0.001) 
# ggplot(group_conf, aes(x=targetContrast, y=Confidence, color=Agent, group=Agent)) + 
#   geom_errorbar(aes(ymin=Confidence-se, ymax=Confidence+se), size=0.7, width=.01, position=pd) +
#   scale_y_continuous(limits = conf_lim, breaks=conf_break) +
#   scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
#   geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
#   geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
#   scale_shape_manual(values=c(15, 16, 17)) +
#   scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
#   scale_linetype_manual(values=c("dotted","dashed","solid")) +
#   scale_size_manual(values=c(3,3,3)) +
#   xlab("contrast level") + ylab("mean confidence") +   # Set axis labels
#   ggtitle("Confidence level (1-6)") + theme_custom())
# 
# ##################  CONFIDENCE per RT XXX   ################## 
# conf_all <- curdat_filt[,c("targetContrast","A1_Confidence","A2_Confidence","Coll_Confidence")]
# conf_all_long <- melt(conf_all, id="targetContrast")  # convert to long format
# conf_all_sum = summarySE(conf_all_long,measurevar="value",groupvars=c("variable","targetContrast"))
# # rename variables
# names(conf_all_sum)[names(conf_all_sum)=='value'] <- 'Confidence'
# names(conf_all_sum)[names(conf_all_sum)=='variable'] <- 'Agent'
# # rename factor levels
# levels(conf_all_sum$Agent) <- c("Agent 1", "Agent 2", "Collective")
# 
# # plot for each pair
# group_conf <- conf_all_sum
# pd <- position_dodge(0.001) 
# ggplot(group_conf, aes(x=targetContrast, y=Confidence, color=Agent, group=Agent)) + 
#   geom_errorbar(aes(ymin=Confidence-se, ymax=Confidence+se), size=0.7, width=.01, position=pd) +
#   scale_y_continuous(limits = conf_lim, breaks=conf_break) +
#   scale_x_continuous(limits = c(0.1,0.265), breaks=seq(0.1,0.265, by=0.05)) +
#   geom_point(aes(shape=Agent, color=Agent, size=Agent), position=pd) +
#   geom_line(aes(linetype=Agent, color=Agent), size=1, position=pd) +
#   scale_shape_manual(values=c(15, 16, 17)) +
#   scale_color_manual(values=c("blue3", "gold2", "darkgreen")) +
#   scale_linetype_manual(values=c("dotted","dashed","solid")) +
#   scale_size_manual(values=c(3,3,3)) +
#   xlab("contrast level") + ylab("mean confidence") +   # Set axis labels
#   ggtitle("Confidence level (1-6)") + theme_custom())
# 
# ##################  CONFIDENCE distribution  ##################
# conf_all <- curdat_filt[,c("targetContrast","A1_Confidence","A2_Confidence","Coll_Confidence")]
# conf_all_long <- melt(conf_all, id="targetContrast")  # convert to long format
# # rename variables
# names(conf_all_long)[names(conf_all_long)=='value'] <- 'Confidence'
# names(conf_all_long)[names(conf_all_long)=='variable'] <- 'Agent'
# # rename factor levels
# levels(conf_all_long$Agent) <- c("Agent 1", "Agent 2", "Collective")
# 
# conf_dist <- conf_all_long
# ggplot(conf_dist, aes(x=Confidence, fill=Agent)) +
#   #scale_x_continuous(limits = c(0,7), breaks=seq(1,6,by=1)) +
#   #scale_y_continuous(limits = c(0,105), breaks=seq(0,105, by=25)) +
#   geom_histogram(color = 1, binwidth=0.5, alpha=.5, position="dodge", linetype = 0.5) +
#   scale_fill_manual(values = c("blue3", "gold2", "darkgreen"))
# 
# #https://es.sonicurlprotection-fra.com/click?PV=2&MSGID=202301111614160142157&URLID=1&ESV=10.0.19.7431&IV=BAD6512CAE5511F393A81FF3342D7CF1&TT=1673453657212&ESN=6RqFVHQ3UCp8TU9tR5eie7OtUmOEYnwkhc24442tYcU%3D&KV=1536961729280&B64_ENCODED_URL=aHR0cHM6Ly9yLWNoYXJ0cy5jb20vZGlzdHJpYnV0aW9uL2hpc3RvZ3JhbS1ncm91cC1nZ3Bsb3QyLw&HK=DC2FA2A0C28F7BA64EE2B6864EF8555DD2A90BFA1F64E405B62B31A19F8B5F11
# 
# ##################
# collect_dat = data.frame(matrix(ncol = 0, nrow = 0))
# collect_dat = rbind(collect_dat, curdat_filt) # combine all subjects' data
# 
# 
# ################################################################################
# #################### plot as a function of difficulty ##########################
# ################################################################################
# 
# 
# 
# 
# ################## go on to work with means ################## 
# 
# # filter rt?
# #collect_dat$RT <- collect_dat$response.rt 
# #collect_dat_RTcorrect <- collect_dat[collect_dat$Accuracy == 1 & collect_dat$RT < 0.8 & collect_dat$RT >= 0.1,]
# 
# #### compute means ####
# # compute means per subject and contrast level
# #Accuracy
# Data_sub_acc_A1 = summarySE(collect_dat,measurevar="A1_accuracy",groupvars=c("GroupID","targetContrast"))
# Data_sub_acc_A2 = summarySE(collect_dat,measurevar="A2_accuracy",groupvars=c("GroupID","targetContrast"))
# Data_sub_acc_Coll = summarySE(collect_dat,measurevar="Coll_accuracy",groupvars=c("GroupID","targetContrast"))
# #RT
# Data_sub_RT_A1 = summarySE(collect_dat,measurevar="A1_RT",groupvars=c("GroupID","targetContrast"))
# Data_sub_RT_A2 = summarySE(collect_dat,measurevar="A2_RT",groupvars=c("GroupID","targetContrast"))
# Data_sub_RT_Coll = summarySE(collect_dat,measurevar="Coll_RT",groupvars=c("GroupID","targetContrast"))
# #MT
# Data_sub_MT_A1 = summarySE(collect_dat,measurevar="A1_MT",groupvars=c("GroupID","targetContrast"))
# Data_sub_MT_A2 = summarySE(collect_dat,measurevar="A2_MT",groupvars=c("GroupID","targetContrast"))
# Data_sub_MT_Coll = summarySE(collect_dat,measurevar="Coll_MT",groupvars=c("GroupID","targetContrast"))
# #Confidence
# Data_sub_Conf_A1 = summarySE(collect_dat,measurevar="A1_Confidence",groupvars=c("GroupID","targetContrast"))
# Data_sub_Conf_A2 = summarySE(collect_dat,measurevar="A2_Confidence",groupvars=c("GroupID","targetContrast"))
# Data_sub_Conf_Coll = summarySE(collect_dat,measurevar="Coll_Confidence",groupvars=c("GroupID","targetContrast"))
# 
# # try plotting
# ggplot(Data_sub_acc_A1, aes(x=targetContrast, y=A1_accuracy, colour=GroupID)) + 
#   geom_errorbar(aes(ymin=A1_accuracy-se, ymax=A1_accuracy+se), width=.1) +
#   geom_line() +
#   geom_point()
# 
# 
# # compute overall means+SD+SE+CI XXX
# Data_individual_acc <- cbind2(collect_dat$A1_accuracy,collect_dat$A2_accuracy)
# Data_collective_acc = 
#   Data_overall_acc = summarySE(Data_sub_acc,measurevar="Accuracy")
# Data_overall_acc_cond = summarySE(Data_sub_acc_cond,measurevar="Accuracy",groupvars=c("Gazecue_Target_Congruency"))
# Data_overall_rt = summarySE(Data_sub_rt,measurevar="RT")
# Data_overall_rt_cond = summarySE(Data_sub_rt_cond,measurevar="RT",groupvars=c("Gazecue_Target_Congruency"))
# 
# 
# 
# 
# ################################################################################
# 
# 
# #### create Excel file for students ####
# Data_prep_analysis <- Data_sub_rt
# Data_prep_analysis$RTCongruent <- Data_sub_rt_cond$RT[Data_sub_rt_cond$Gazecue_Target_Congruency == "Congruent"]
# Data_prep_analysis$RTIncongruent <- Data_sub_rt_cond$RT[Data_sub_rt_cond$Gazecue_Target_Congruency == "Incongruent"]
# Data_prep_analysis$AccuracyCongruent <- Data_sub_acc_cond$Accuracy[Data_sub_acc_cond$Gazecue_Target_Congruency == "Congruent"]
# Data_prep_analysis$AccuracyIncongruent <- Data_sub_acc_cond$Accuracy[Data_sub_acc_cond$Gazecue_Target_Congruency == "Incongruent"]
# 
# Data_prep_analysis$Nr <- Data_prep_analysis$Subnum #rename "Subnum" to "Nr"
# 
# 
# Data_analysis <- Data_prep_analysis[,c("Nr","VP","Sportart","RT","RTCongruent","RTIncongruent","AccuracyCongruent","AccuracyIncongruent")]
# 
# write.csv(Data_analysis,sprintf("%sResults/GazeData.csv",DataDir))
# write_xlsx(Data_analysis,sprintf("%sResults/GazeData.xlsx",DataDir))
# }
# 
# 
# 
# 
# 
# # colnames(curdat_filt) <-
# #   c(
# #     "targetContrast",
# #     "targetInterval",
# #     "targetLocation",
# #     "A1_decision",
# #     "A1_accuracy",
# #     "A1_RT",
# #     "A1_MT",
# #     "A1_Confidence",
# #     "A1_ConfRT",
# #     "A2_decision",
# #     "A2_accuracy",
# #     "A2_RT",
# #     "A2_MT",
# #     "A2_Confidence",
# #     "A2_ConfRT",
# #     "Coll_decision",
# #     "Coll_accuracy",
# #     "Coll_RT",
# #     "Coll_MT",
# #     "Coll_Confidence",
# #     "Coll_ConfRT",
# #     "Agent1stDecision",
# #     "Agent2ndDecision" ,
# #     "AgentCollDecision",
# #     "rt_final1","rt_final2","rt_finalColl","mt_final1","mt_final2","mt_finalColl"
# #     )
