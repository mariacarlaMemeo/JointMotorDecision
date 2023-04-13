# ==============================================================================
# Analysis of pilot data for JMD study (JMD=joint motor decision)
# Data: collected in November 2022 @IIT Genova
# Participants: N=8 (4 pairs) -> 1 pair (102) excluded
# Script: written by Mariacarla Memeo & Laura Schmitz
# ==============================================================================


# Preparatory steps
# -----------------

# Remove variables and plots
rm(list = ls())
graphics.off()

# Import libraries and load packages
library(doBy)
pckgs = c("data.table","lattice","lme4", "nlme","emmeans","doBy","effsize","ez","MuMIn","BayesFactor","permuco","RVAideMemoire","this.path",
          "ggiraphExtra","RColorBrewer","readxl","stringr","knitr","multcomp","ggplot2","car","dplyr", "plyr","lmerTest","ggrepel","sjstats","reshape2","writexl")
# further potentially useful packages for plotting:
# install.packages("remotes")
# remotes::install_github("coolbutuseless/ggpattern")

# Check how many packages failed the loading
sum(lapply(pckgs, require, character.only = TRUE)==FALSE)

# Flags
local_user = 1;    # set current user (1=MC, 2=LA)
schon_data = TRUE  # if TRUE: EXCLUDE pair 102 (because 102 is not schön)
patel_mt   = FALSE # if TRUE: Does difference in MT predict inferred confidence? (see Patel et al., 2012)

# Set paths (*** ADJUST TO LOCAL COMPUTER with flag local_user ***)
if (local_user == 1) {
  # Retrieve directory of current file and create main directory path
  slash      = this.path()
  DataDir    = substr(slash,1,114) 
  DataDirObs = paste0(DataDir,"data_obs/") # retrieve observation data
  PlotDir    = paste0(DataDir,"plot/") # save plots here
} else {
  # Set directories manually
  DataDir    = "C:/Users/Laura/GitHub/JointMotorDecision/analyses/"
  DataDirObs = "C:/Users/Laura/GitHub/JointMotorDecision/analyses/data_obs/"
  PlotDir    = "C:/Users/Laura/GitHub/JointMotorDecision/analyses/plot/"
}

# Call needed functions/scripts 
source(paste0(DataDir,'read_all_sheets.R'))
source(paste0(DataDir,'summarySE.R'))
source(paste0(DataDir,'theme_custom.R'))
source(paste0(DataDir,'plotSE.R'))
source(paste0(DataDir,'final_rtmt_byAgent.R'))

# Initialize variables
decision1 = c()
conf1     = c()
acc1      = c()
decision2 = c()
conf2     = c()
acc2      = c()


#################################################################################################################################
### EXECUTION DATA (collective decision-making)

# Create data frame with execution data.
# Retrieve data from an Excel file that was manually created by merging the single pair files. 
# Single pair files were created with Matlab script movement_onset.m, which takes as input
# the original .mat files created during the experiment.
# -------------------------------------------------------------------------------------------

# Use following Excel file: pilotData_all_BY.xlsx
# B=blue participant (previously A1) - now A1 is agent taking 1st decision
# Y=yellow participant (previously A2) - now A2 is agent taking 2nd decision
cursub    = "pilotData_all_BY.xlsx"
Filetmp   = sprintf('%s%s', DataDir, cursub) # create path to access Excel file

# Read all sheets (only selected columns) and create main data frame ("curdat")
dat       = read_all_sheets(Filetmp,"P","A:AH")
list_size = lapply(dat,lengths)
group     = c(rep(100,list_size[[1]][[1]]),rep(101,list_size[[2]][[1]]),rep(102,list_size[[3]][[1]]),rep(103,list_size[[4]][[1]]))
trial     = c(1:list_size[[1]][[1]],1:list_size[[2]][[1]],1:list_size[[3]][[1]],1:list_size[[4]][[1]])
# Bind all data by row (rbind)
curdat    = rbindlist(dat)
curdat    = cbind(group,trial,curdat) # add "group" (=pair) and "trial" as 1st/2nd column


# Add additional info to the data frame
# -------------------------------------

# Add a column (at the end) that expresses whether agents Y and b agree in their decisions [1=agreement, -1=disagreement]
curdat$agree                  = as.integer(curdat$B_decision == curdat$Y_decision)
curdat$agree[curdat$agree==0] =-1

# Add columns where decision, confidence, and accuracy are reported per 1st/2nd decision (rather than tied to agent Y and B)
for (row in 1:dim(curdat)[1])
{
  f_dec = curdat[row,AgentTakingFirstDecision]#agent taking first decision
  if (f_dec=="B") {
    decision1[row] = curdat[row,B_decision]
    conf1[row]     = curdat[row,B_conf]
    acc1[row]      = curdat[row,B_acc]} else {
    decision1[row] = curdat[row,Y_decision]
    conf1[row]     = curdat[row,Y_conf]
    acc1[row]      = curdat[row,Y_acc]
  }
  
  s_dec = curdat[row,AgentTakingSecondDecision]#agent taking second decision
  if (s_dec=="B") {
    decision2[row] = curdat[row,B_decision]
    conf2[row]     = curdat[row,B_conf]
    acc2[row]      = curdat[row,B_acc]} else {
    decision2[row] = curdat[row,Y_decision]
    conf2[row]     = curdat[row,Y_conf]
    acc2[row]      = curdat[row,Y_acc]
  }
}
# Add the computed values (decision, confidence, accuracy) for 1st/2nd decision to curdat
curdat$decision1   = decision1
curdat$decision2   = decision2
curdat$confidence1 = conf1
curdat$confidence2 = conf2
curdat$accuracy1   = acc1
curdat$accuracy2   = acc2
# Sanity check: confirm that Y/B decisions correspond to 1st/2nd decision (must be TRUE)
all(as.integer(curdat$B_decision == curdat$Y_decision) == as.integer(curdat$decision1 == curdat$decision2))

# Add a column that indicates whether 1st and collective decision differ,
# i.e., whether A1 switched her decision (changed her mind) [1=switch, -1=no switch]
curdat$switch                   = as.integer(curdat$decision1 != curdat$Coll_decision)
curdat$switch[curdat$switch==0] = -1

# Remove pair 102 - didn't follow the instructions
if (schon_data) {
  curdat    = curdat[curdat$group!=102,]
  schon_lab = "noPair102"
} else {
  schon_lab = ""
}


# Check PROPORTIONS: high/low confidence, agreement/disagreement, switch/no switch
# --------------------------------------------------------------------------------
# High/low confidence: Select high/low confidence trials for each agent and average the values
perc_conf_lo = round(100*(dim(curdat[(curdat$B_conf==c(1) | curdat$B_conf==c(2) | curdat$B_conf==c(3))])[1]+dim(curdat[(curdat$Y_conf==c(1) | curdat$Y_conf==c(2) | curdat$Y_conf==c(3))])[1])/(2*dim(curdat)[1]))
perc_conf_hi = round(100*(dim(curdat[(curdat$B_conf==c(4) | curdat$B_conf==c(5) | curdat$B_conf==c(6)) ])[1]+dim(curdat[(curdat$Y_conf==c(4) | curdat$Y_conf==c(5) | curdat$Y_conf==c(6))])[1])/(2*dim(curdat)[1]))
sprintf("Low confidence trials: %d %s", perc_conf_lo, "%")
sprintf("High confidence trials: %d %s", perc_conf_hi, "%")

# Sub-select agreement/disagreement trials
at      = curdat[curdat$agree==1,]
dt      = curdat[curdat$agree==-1,]
# plot disagreement according to target contrast
hist(dt$targetContrast) 
# Percentage of (dis)agreement trials relative to all trials
perc_dt          = round(100*(dim(dt)[1]/dim(curdat)[1])) #39%
perc_at          = round(100*(dim(at)[1]/dim(curdat)[1])) #61%
sprintf("Disagreement trials: %d %s", perc_dt, "%")
sprintf("Agreement trials: %d %s", perc_at, "%")

# Percentage of switch/noswitch in case of disagreement (and for all trials)
dt_switch         = dt[dt$switch==1]
dt_noswitch       = dt[dt$switch==-1]
perc_dt_switch    = round(100*(dim(dt_switch)[1]/dim(dt)[1]))     #64%
perc_dt_noswitch  = round(100*(dim(dt_noswitch)[1]/dim(dt)[1]))   #36%
perc_all_switch   = round(100*(dim(dt_switch)[1]/dim(curdat)[1])) #25%
perc_all_noswitch = round(100*(dim(dt_noswitch)[1]/dim(curdat)[1])+100*(dim(at)[1]/dim(curdat)[1])) #75%
sprintf("Switch as proportion of disagreement trials: %d %s", perc_dt_switch, "%")
sprintf("No switch as proportion of disagreement trials: %d %s", perc_dt_noswitch, "%")
sprintf("Switch/no switch as proportion of all trials: %d %s %d %s", perc_all_switch, "% /", perc_all_noswitch, "%")
# Check if there is switching in case of agreement (1st = 2nd decision)
at_switch = at[at$switch==1] # should be empty (no switch if agreement)
if (nrow(at_switch) == 0) {
  print("ALL GOOD: No switches if co-actors agree!")
} else {
  print("WHAAAT? Switches even if agreement?")
}


# Comparisons between more vs. less sensitive dyad members
# --------------------------------------------------------
source(paste0(DataDir,'goodVSbadGuys.R')) # call separate script good vs. bad


# Configure plot parameters
# -------------------------
pd           = position_dodge(0.001)
acc_scale    = list("lim"=c(0,1),"breaks"=seq(0,1, by=0.2))
acc_scale2   = list("lim"=c(0,0.85),"breaks"=seq(0,0.85, by=0.1)) # for mean values up to ~0.8
target_scale = list("breaks"=unique(curdat$targetContrast),"labels"=unique(curdat$targetContrast))
conf_scale   = list("lim"=c(1,6),"breaks"=seq(1,6, by=1))
conf_scale2  = list("lim"=c(1,4.5),"breaks"=seq(1,4.5, by=1)) # for mean values up to ~4
time_scale   = list("lim"=c(0,2),"breaks"=seq(0,2, by=0.25))
mov_scale    = list("lim"=c(0.5,1.75),"breaks"=seq(0.5,1.75, by=0.25))


# List of plots
#--------------
#1. CONFIDENCE as a function of TARGET CONTRAST
#2. ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH
#3. mean ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH (bar plots)
#4. CONFIDENCE DIFFERENCE for A1 and A2
#5. RT and MT as a function of CONFIDENCE (for 2nd decision only)
#6. RT and MT as a function of TARGET CONTRAST

# XXX check from line 534 onward (observation part)


# START PLOTTING
# ------------------------------------------------------------------------------


# 1. CONFIDENCE as a function of TARGET CONTRAST
# 1a. Split by agreement (only A1 and collective decisions)
# ---------------------------------------------------------
conf_all <- curdat[,c("targetContrast","confidence1","Coll_conf","agree")]
conf_all_long <- melt(conf_all, id=c("targetContrast","agree"))  # convert to long format
levels(conf_all_long$variable) <- c("Individual_A1", "Collective")
conf_all_sum = summarySE(conf_all_long,measurevar="value",groupvars=c("variable","targetContrast","agree"))
# rename variables
names(conf_all_sum)[names(conf_all_sum)=='value']    <- 'Confidence'
names(conf_all_sum)[names(conf_all_sum)=='variable'] <- 'DecisionType'
# rename factor levels
conf_all_sum$agree = as.factor(conf_all_sum$agree)
levels(conf_all_sum$agree) <- c("disagree", "agree")

# plot - Confidence level by target contrast and agreement 
print(plotSE(df=conf_all_sum,xvar=conf_all_sum$targetContrast,yvar=conf_all_sum$Confidence,
             colorvar=conf_all_sum$DecisionType,shapevar=conf_all_sum$agree,
             xscale=target_scale,yscale=conf_scale,titlestr="Confidence level by agreement",
             manual_col=c("steelblue1", "darkgreen"),linevar=c("dotted","solid"),sizevar=c(3,3),disco=FALSE)+
             scale_shape_manual(values=c(16,16))+
             xlab("Target contrasts") + ylab("Confidence level") + theme_custom())
ggsave(file=paste0(PlotDir,"conf_agree",schon_lab,".png"), dpi = 300, units=c("cm"), height =20, width = 20)


# 1b. Split by agreement and accuracy (only collective decision)
# --------------------------------------------------------------
conf_all_acc      = curdat[,c("targetContrast","Coll_acc","Coll_conf","agree")]
conf_all_long_acc = melt(conf_all_acc, id=c("targetContrast","agree","Coll_acc"))
conf_all_sum_acc  = summarySE(conf_all_long_acc,measurevar="value",groupvars=c("targetContrast","agree","Coll_acc"))
# rename variables
names(conf_all_sum_acc)[names(conf_all_sum_acc)=='value']    <- 'Confidence'
names(conf_all_sum_acc)[names(conf_all_sum_acc)=='Coll_acc'] <- 'Accuracy'
# factorize and rename factor levels
conf_all_sum_acc$agree            = as.factor(conf_all_sum_acc$agree)
levels(conf_all_sum_acc$agree)    = c("disagree", "agree")
conf_all_sum_acc$Accuracy         = as.factor(conf_all_sum_acc$Accuracy)
levels(conf_all_sum_acc$Accuracy) = c("incorrect", "correct")

# plot - Confidence level by target contrasts and agreement and accuracy (only collective decision)
print(plotSE(df=conf_all_sum_acc,xvar=conf_all_sum_acc$targetContrast,yvar=conf_all_sum_acc$Confidence,
             colorvar=conf_all_sum_acc$Accuracy,shapevar=conf_all_sum_acc$agree,
             xscale=target_scale,yscale=conf_scale,titlestr="Confidence level by agreement",
             manual_col=c("red", "green"),linevar=c("dotted","solid"),sizevar=c(3,3),disco=FALSE)+
             scale_shape_manual(values=c(16,16))+
             xlab("Target contrasts") + ylab("Confidence level") + theme_custom())
ggsave(file=paste0(PlotDir,"conf_agree_acc_coll",schon_lab,".png"), dpi = 300, units=c("cm"), height =20, width = 20)


# 2. ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH
# 2a. Accuracy split by agreement and switch (only A1 and collective decisions)
# --------------------------------------------------------------------------------
acc_sw               = curdat[,c("targetContrast","switch","agree","accuracy1","Coll_acc")]
conf_all_long_acc_sw = melt(acc_sw, id=c("targetContrast","switch","agree"))
conf_all_sum_acc_sw  = summarySE(conf_all_long_acc_sw,measurevar="value",groupvars=c("targetContrast","switch","agree","variable"))
# factorize and rename factor levels
conf_all_sum_acc_sw$switch         = as.factor(conf_all_sum_acc_sw$switch)
levels(conf_all_sum_acc_sw$switch) = c("no_switch","switch")
conf_all_sum_acc_sw$agree          = as.factor(conf_all_sum_acc_sw$agree)
levels(conf_all_sum_acc_sw$agree)  = c("disagree","agree")

# plot - Accuracy as a function of agreement and switch
ggplot(conf_all_sum_acc_sw, aes(x=targetContrast, y=value, color=variable, shape=switch)) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), size=0.7, width=.01, position=pd) +
  geom_point(aes(shape=switch, color=variable), size = 5,position=pd) +
  geom_line(aes(linetype=agree), size=1, position=pd) +
  scale_color_manual(values=c("steelblue1", "darkgreen")) +
  scale_linetype_manual(values=c("dotted","solid")) + 
  scale_shape_manual(values=c(1,16)) +
  ggtitle("Accuracy agreement and switch")+
  scale_y_continuous(limits = acc_scale$lim, breaks=acc_scale$breaks)+
  scale_x_continuous(breaks=target_scale$breaks, labels = target_scale$labels)+
  xlab("Target contrasts") + ylab("Accuracy") + theme_custom()
ggsave(file=paste0(PlotDir,"acc_agree_switch.png"), dpi = 300, units=c("cm"), height =20, width = 20)


# 2b. Confidence split by agreement and switch (only A1 and collective decisions)
# --------------------------------------------------------------------------------
conf_sw          = curdat[,c("targetContrast","switch","agree","confidence1","Coll_conf")]
conf_all_long_sw = melt(conf_sw, id=c("targetContrast","switch","agree"))
conf_all_sum_sw  = summarySE(conf_all_long_sw,measurevar="value",groupvars=c("targetContrast","switch","agree","variable"))
# factorize and rename factor levels
conf_all_sum_sw$switch         = as.factor(conf_all_sum_sw$switch)
levels(conf_all_sum_sw$switch) = c("no_switch","switch")
conf_all_sum_sw$agree          = as.factor(conf_all_sum_sw$agree)
levels(conf_all_sum_sw$agree)  = c("disagree","agree")

# plot - Confidence as a function of agreement and switch
ggplot(conf_all_sum_sw, aes(x=targetContrast, y=value, color=variable, shape=switch)) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), size=0.7, width=.01, position=pd) +
  geom_point(aes(shape=switch, color=variable), size = 5,position=pd) +
  geom_line(aes(linetype=agree), size=1, position=pd) +
  scale_color_manual(values=c("steelblue1", "darkgreen")) +
  scale_linetype_manual(values=c("dotted","solid")) + 
  scale_shape_manual(values=c(1,16)) +
  ggtitle("Confidence agreement and switch")+
  scale_y_continuous(limits = conf_scale$lim, breaks=conf_scale$breaks)+
  scale_x_continuous(breaks=target_scale$breaks, labels = target_scale$labels)+
  xlab("Target contrasts") + ylab("Confidence") + theme_custom()
ggsave(file=paste0(PlotDir,"conf_agree_switch.png"), dpi = 300, units=c("cm"), height =20, width = 20)


# 3. mean ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH (bar plots)
# 3a. Confidence split by agreement and switch (only A1 and collective decisions)
# --------------------------------------------------------------------------------
# x-axis: individual/collective
# color:  agree/disagree
# panels: switch/no switch
# bars:   light gray (agree) vs. dark gray (disagree)
# panels: green (switch) vs. red (no switch)
bar_colors = c("gray88", "gray44", "lightcoral", "lightgreen")

# prep confidence bars
conf_targ_sw              = curdat[,c("switch","agree","confidence1","Coll_conf")]
conf_all_targ_long_sw     = melt(conf_targ_sw, id=c("switch","agree"))
conf_all_targ_sum_acc_sw  = summarySE(conf_all_targ_long_sw,measurevar="value",groupvars=c("switch","agree","variable"))
csa_data                  = conf_all_targ_sum_acc_sw
# factorize and rename factor levels
csa_data$switch           = as.factor(csa_data$switch)
levels(csa_data$switch)   = c("No switch","Switch")
csa_data$switch           <- factor(csa_data$switch, levels = c("Switch","No switch")) # change order
csa_data$agree            = as.factor(csa_data$agree)
levels(csa_data$agree)    = c("Disagree","Agree")
csa_data$agree            <- factor(csa_data$agree, levels = c("Agree","Disagree")) # change order
csa_data$variable         = as.factor(csa_data$variable)
levels(csa_data$variable) = c("Individual","Collective")
# plot confidence bars
# variable = individual vs. collective, value = confidence 
ggplot(data=csa_data, aes(x=variable, y=value, fill=agree)) +
  ggtitle("Confidence by agreement and switch") +
  geom_rect(aes(fill=switch),xmin =-Inf,xmax=Inf,ymin=-Inf,ymax=Inf,alpha = 0.3) + #alpha = background opacity
  geom_bar(stat="identity", position=position_dodge2(width = 0.5, preserve = "single"), color = "black") +
  scale_fill_manual(values=bar_colors) +
  geom_errorbar(data=csa_data, mapping=aes(x=variable, ymin=value-se, ymax=value+se), size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
  facet_grid(. ~ as.factor(switch)) + # separate facets for switch / no switch
  scale_y_discrete(limits = factor(conf_scale2$breaks), breaks=conf_scale2$breaks) +
  xlab("Decision") + ylab("Confidence") + 
  theme(panel.grid.major = element_line(color = "black", size = .5),
        panel.grid.minor = element_line(color = "black", size = .25),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
ggsave(file=paste0(PlotDir,"Confidence_Agree+Switch.png"), dpi = 300, units=c("cm"), height =20, width = 30)


# 3b. Accuracy split by agreement and switch (only A1 and collective decisions)
# --------------------------------------------------------------------------------
# prep accuracy bars
acc_tar_sw               = curdat[,c("switch","agree","accuracy1","Coll_acc")]
conf_all_long_acc_tar_sw = melt(acc_tar_sw, id=c("switch","agree"))  # convert to long format
conf_all_sum_acc_tar_sw  = summarySE(conf_all_long_acc_tar_sw,measurevar="value",groupvars=c("switch","agree","variable"))
csaAcc_data              = conf_all_sum_acc_tar_sw
# factorize and rename factor levels
csaAcc_data$switch           = as.factor(csaAcc_data$switch)
levels(csaAcc_data$switch)   = c("No switch","Switch")
csaAcc_data$switch           <- factor(csaAcc_data$switch, levels = c("Switch","No switch")) # change order
csaAcc_data$agree            = as.factor(csaAcc_data$agree)
levels(csaAcc_data$agree)    = c("Disagree","Agree")
csaAcc_data$agree            <- factor(csaAcc_data$agree, levels = c("Agree","Disagree")) # change order
csaAcc_data$variable         = as.factor(csaAcc_data$variable)
levels(csaAcc_data$variable) = c("Individual","Collective")
# plot accuracy bars
# variable = individual vs. collective, value = accuracy 
ggplot(data=csaAcc_data, aes(x=variable, y=value, fill=agree)) +
  ggtitle("Accuracy by agreement and switch") +
  geom_rect(aes(fill=switch),xmin =-Inf,xmax=Inf,ymin=-Inf,ymax=Inf,alpha = 0.3) + #alpha = background opacity
  geom_bar(stat="identity", position=position_dodge2(width = 0.5, preserve = "single"), color = "black") +
  scale_fill_manual(values=bar_colors) +
  geom_errorbar(data=csaAcc_data, mapping=aes(x=variable, ymin=value-se, ymax=value+se), size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
  facet_grid(. ~ as.factor(switch)) +
  scale_y_continuous(limits = acc_scale2$lim, breaks=acc_scale2$breaks)+
  xlab("Decision") + ylab("Accuracy") + 
  theme(panel.grid.major = element_line(color = "black", size = .5),
        panel.grid.minor = element_line(color = "black", size = .25),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
ggsave(file=paste0(PlotDir,"Accuracy_Agree+Switch.png"), dpi = 300, units=c("cm"), height =20, width = 30)


# 4. CONFIDENCE DIFFERENCE for A1 and A2
# Show confidence for both individual decisions (A1 and A2).
# Plot per pair, separate plots for switch/no switch. Only disagreement trials.
# --------------------------------------------------------------------------------

coll = FALSE # include also the collective decision?
if (coll) {
  dt_long  = melt(dt[,c("group","trial","confidence1","confidence2","Coll_conf","switch")], id=c("group","trial","switch"))
  coll_lab = "_3conf"} else {
  dt_long  = melt(dt[,c("group","trial","confidence1","confidence2","switch")], id=c("group","trial","switch"))
  coll_lab = ""
}

# No switch plots, per pair (disagreement trials)
for(p in unique(dt_long$group)){
  no_switch_100=dt_long[dt_long$group==p & dt_long$switch==-1,]
  print(ggplot(no_switch_100, aes(x=variable, y=value,shape=variable)) +
          geom_line(aes(group=trial,color=as.factor(trial)),position=position_jitter(width = .01, height = .01))+
          geom_point(size = 2, position=position_jitter(width = .1, height = .1)) +
          scale_y_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks)+
          xlab("decision")+ylab("Confidence level")+
          ggtitle(paste0("Confidence with no switch - disagreement trials n.",as.character(p))))
  ggsave(file=sprintf(paste0("%sconf_noSwitch_disagree ",as.character(p),coll_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
}

# Switch plots, per pair (disagreement trials)
for(p in unique(dt_long$group)){
  switch_100=dt_long[dt_long$group==p & dt_long$switch==1,]
  print(ggplot(switch_100, aes(x=variable, y=value,shape=variable)) +
          geom_line(aes(group=trial,color=as.factor(trial)),position=position_jitter(width = .01, height = .01))+
          geom_point(size = 2, position=position_jitter(width = .1, height = .1)) +
          scale_y_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks)+
          xlab("decision")+ylab("Confidence level")+
          ggtitle(paste0("Confidence with switch - disagreement trials n.",as.character(p))))
  ggsave(file=sprintf(paste0("%sconf_Switch_disagree ",as.character(p),coll_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
}


# 5. RT and MT as a function of CONFIDENCE (for 2nd decision only!!!)
# "B_rt" and "Y_rt" (previously "A1_rt" and "A2_rt") refer to RT calculated for each agent during acquisition (the same for mt). 
# In the post-processing we re-calculated rt and mt for each decision ("rt_final1" and "rt_final2").
# The new calculation is based on a velocity threshold: from now, we will use this final rt/mt. 
# NOTE: The variables are related to the rt of the 1st and 2nd decision respectively (not to the agent).
# ------------------------------------------------------------------------------------------------------------------------------

# rt 2nd decision - calc the average, se, ci
rt_conf_2d                = curdat[,c("confidence2","rt_final2")]
rt_conf_2d_sum            = summarySE(rt_conf_2d,measurevar="rt_final2",groupvars=c("confidence2"))
# mt 2nd decision - calc the average, se, ci
mt_conf_2d                = curdat[,c("confidence2","mt_final2")]
mt_conf_2d_sum            = summarySE(mt_conf_2d,measurevar="mt_final2",groupvars=c("confidence2"))
# rename variables
names(rt_conf_2d_sum)     = c("conf2","N","var","sd","se","ci")
names(mt_conf_2d_sum)     = c("conf2","N","var","sd","se","ci")
mt_rt_conf_2d_sum         = rbind(rt_conf_2d_sum,mt_conf_2d_sum); 
mt_rt_conf_2d_sum$var_lab = c(replicate(length(rt_conf_2d_sum), "rt"),replicate(length(mt_conf_2d_sum), "mt"))
d                         = mt_rt_conf_2d_sum # shorter name for convenience

# plot - RT and MT as a function of confidence level (across participants)
print(plotSE(df=d,xvar=d$conf2,yvar=d$var,
             colorvar=d$var_lab,shapevar=d$var_lab,
             xscale=conf_scale,yscale=time_scale,titlestr=paste0("MT/RT as a function of confidence (2nd decision) ",schon_lab),
             manual_col=c("grey", "black"),linevar=c("dashed","solid"),sizevar=c(3,3),disco=TRUE) +
             xlab("agent confidence") + ylab("time [s]") + theme_custom())
ggsave(file=sprintf(paste0("%stime_conf_2d",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


# 6. RT and MT as a function of TARGET CONTRAST
# 6a. RT and MT means (across participants)
# ----------------------------------------------

# plot for RT (v=1) and MT (v=2)
for (v in 1:2) {
  
  if (v==1) {
    lab ="RT"
    all <- curdat[,c("targetContrast","rt_final1","rt_final2","rt_finalColl")]} else {
    lab="MT"
    all <- curdat[,c("targetContrast","mt_final1","mt_final2","mt_finalColl")]
  }
  
  # prep data
  all_long <- melt(all, id="targetContrast")
  # rename factor levels
  levels(all_long$variable) <- c("Individual", "Individual", "Collective")
  all_sum = summarySE(all_long,measurevar="value",groupvars=c("variable","targetContrast"))
  
  var = all_sum$value
  # rename variables
  names(all_sum)[names(all_sum)=='value'] <- lab
  names(all_sum)[names(all_sum)=='variable'] <- 'DecisionType'
  
  # plot average values (one plot for RT, one plot for MT)
  print(plotSE(df=all_sum,xvar=all_sum$targetContrast,yvar=var,
               colorvar=all_sum$DecisionType,shapevar=all_sum$DecisionType,
               xscale=target_scale,yscale=mov_scale,titlestr=paste(lab," as a function of task difficulty"),
               manual_col=c("steelblue1", "darkgreen"),linevar=c("dashed","solid"),sizevar=c(3,3),disco=FALSE)+
               xlab("Target contrasts") + ylab(paste("Mean ",lab," [s]")) + theme_custom())
  ggsave(file=sprintf(paste0("%s",lab,"_ave.png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
}

# 6b. RT and MT per pair
# Plots show B, Y, and Collective RT/MT
# ---------------------------------------

# Add 4 columns with rt/mt split by agent
curdat = final_rtmt_byAgent(curdat)

# plot for RT (m=1) and MT (m=2)
for (m in 1:2){
  
  if (m==1) {
    lab ="RT"
    all <- curdat[,c("targetContrast","B_rtKin","Y_rtKin","rt_finalColl","group")]
    mov_scale = list("lim"=c(0,1.8),"breaks"=seq(0,1.8, by=0.2))} else {
    lab="MT"
    all <- curdat[,c("targetContrast","B_mtKin","Y_mtKin","mt_finalColl","group")]
    mov_scale = list("lim"=c(0.5,2.5),"breaks"=seq(0.5,2.5, by=0.25))
  }
  
  # prep data
  all$group=as.factor(all$group)
  if (schon_data) {
    all_pairs = c(100,101,103) } else {
    all_pairs = c(100,101,102,103)
  }
  
  for (g in all_pairs) {
    
    sub_all=all[all$group==g,]
    sub_all=subset(sub_all, select = -c(group) )
    all_long <- melt(sub_all, id="targetContrast")
    # rename factor levels
    levels(all_long$variable) <- c("B", "Y", "Collective")
    
    pair_sum = summarySE(all_long,measurevar="value",groupvars=c("variable","targetContrast"))
    var = pair_sum$value
        # rename variables
    names(pair_sum)[names(pair_sum)=='value'] <- lab
    names(pair_sum)[names(pair_sum)=='variable'] <- 'DecisionType'
    
    # one plot for each pair (different colors for B, Y, Collective)
    print(plotSE(df=pair_sum,xvar=pair_sum$targetContrast,yvar=var,
                 colorvar=pair_sum$DecisionType,shapevar=pair_sum$DecisionType,
                 xscale=target_scale,yscale=mov_scale,titlestr=paste(as.character(g)," ",lab," as a function of task difficulty"),
                 manual_col=c("blue3", "gold2", "darkgreen"),linevar=c("dotted","dashed","solid"),sizevar=c(3,3,3),disco=FALSE)+
            xlab("Target contrasts") + ylab(paste("Mean ",lab," [s]")) + theme_custom())
    ggsave(file=sprintf(paste0("%s",as.character(g),"_",lab,"_ave.png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  }
}




#################################################################################################################################
### OBSERVATION DATA (individual confidence estimation)

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

#Combine execution and observation data sets
#First remove the trials in which the video was not recorded during execution
exedat       = curdat[-c(2,6,8),]
exedat       = as.data.frame(lapply(exedat, rep, each=4)) #repeat each row 4 times to match the observation data (4 blocks ordered in Excel so that each the first 4 rows represent trial1 from block 1-2-3-4)
asec         = as.factor(exedat$AgentTakingSecondDecision)
levels(asec) = c(1,2)
exedat$asec  = as.numeric(asec)
exedat_yb    = with(exedat, exedat[order(group,-asec),])#first agent YELLOW(Y) acting second, observed by agent BLUE(b) (to align with obsdat)
names(exedat_yb)[names(exedat_yb)=="trial"] <- "trial_exe"
names(exedat_yb)[names(exedat_yb)=="group"] <- "pair_exe"

#Check if the order of agents is the same
all(exedat_yb$asec==curdatObs$Pagent) #THIS CHECK FAILS - because we didn't update the obs results file (curobs); it's wrong because of P101
afirst        = as.factor(exedat$AgentTakingFirstDecision);levels(afirst) = c(1,2)
exedat$afirst = as.numeric(afirst)
all(exedat_yb$afirst==curdatObs$Oagent)
if (dim(exedat_yb)[1] == dim(curdatObs)[1]){merge = 1}

#merge execution and observation
if (merge) {inout = cbind(exedat_yb,curdatObs)}

sinout = inout[,c("pair_exe","pair_obs","Pagent","Oagent","trial_exe","trial_obs","block_obs","Video","targetContrast","firstSecondInterval",
                  "agent_confidence","observer_confidence","observer_acc","observer_RTnorm",
                  "B_acc","B_conf","B_confRT","Y_acc","Y_conf","Y_confRT","Coll_acc","Coll_conf","Coll_confRT",
                  "AgentTakingSecondDecision","asec","rt_final2","mt_final2","B_rtKin","Y_rtKin","B_mtKin","Y_mtKin",
                  "decision1","decision2","Coll_decision","agree","switch","confidence1","confidence2",
                  "accuracy1", "accuracy2")]

#calculating average values of confidence for each video because in observation we show videos 4 times
sinout = transformBy(~Video+pair_obs,data=sinout, conf_aveBlock = round(mean(as.numeric(observer_confidence),na.rm=T),1))
#calculating the difference between averaged obs confidence (conf_aveBlock) and agent confidence - confidence for the same action 
#conf_aveBlock>0 means the inferred confidence in observation is higher than confidence in the execution (different agents, same action)
sinout$diff_conf = sinout$conf_aveBlock-sinout$agent_confidence # inferred-subjective confidence
#calculating the difference in movement time between the agents in a pair - absolute value
sinout$diff_mt   = round(abs(sinout$B_mtKin - sinout$Y_mtKin),2)
#calculating the difference in movement time between the agents in a pair - signed values
#diff_mt_signed>0 means blue agent is slower (=larger MT) than yellow agent 
sinout$diff_mt_signed   = round(sinout$B_mtKin - sinout$Y_mtKin,2)

# add columns for the confidence difference values (deltas):
# confidence2 - confidence1:
# deltaC2C1 < 0 = conf2 < conf1; deltaC2C1 > 0 = conf2 > conf1
sinout$deltaC2C1 = sinout$confidence2-sinout$confidence1 
# collective confidence - confidence1:
# deltaCcC1 < 0 = coll conf < conf1; deltaCcC1 > 0 = coll conf > conf1
sinout$deltaCcC1 = sinout$Coll_conf-sinout$confidence1
# inferred confidence - confidence1 (already calculated above; just rename for consistency)
# deltaCiC1 < 0 = inf. conf < conf1; deltaCiC1 > 0 = inf. conf > conf1
sinout$deltaCiC1 = sinout$conf_aveBlock-sinout$confidence1


## Selection of only 1 block because the values of confidence are averaged across blocks 
sinout_1block = sinout[sinout$block_obs==1,] 



############## SWITCHING AS A FUNCTION OF CONFIDENCE DIFF (conf 1st decision and inferred confidence) ##############################
# Select only disagreement trials
dti            = sinout_1block[sinout_1block$agree==-1,]
# Percentage of disagreement trials from total amount of trials
perc_dti       = round(100*(dim(dti)[1]/dim(sinout_1block)[1]))
# Percentage of switch trials among the disagreement trials
perc_dti_switch = round(100*(dim(dti[dti$switch==1,])[1]/dim(dti)[1]))


if(coll){dti_long = melt(dti[,c("pair_obs","trial_exe","confidence1","conf_aveBlock","Coll_conf","switch")], id=c("pair_obs","trial_exe","switch"))
         coll_lab = "_3conf"} else{
         dti_long = melt(dti[,c("pair_obs","trial_exe","confidence1","conf_aveBlock","switch")], id=c("pair_obs","trial_exe","switch"))
         coll_lab = ""}

#no switch
for(p in unique(dti_long$pair_obs)){
  no_switch_100i = dti_long[dti_long$pair_obs==p & dti_long$switch==-1,]
  print(ggplot(no_switch_100i, aes(x=variable, y=value, shape=variable)) +
          geom_line(aes(group=trial_exe,color=as.factor(trial_exe)),position=position_jitter(width = .01, height = .01))+
          geom_point(size = 2,position=position_jitter(width = .1, height = .1))+ 
          scale_y_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks)+
          xlab("decision")+ylab("Confidence level")+
          ggtitle(paste0("Confidence with no switch - disagreement trials n.",as.character(p))))
  # ggsave(file=sprintf(paste0("%siconf_noSwitch_disagree ",as.character(p),coll_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
}

#switch
for(p in unique(dti_long$pair_obs)){
  switch_100i = dti_long[dti_long$pair_obs==p & dti_long$switch==1,]
  print(ggplot(switch_100i, aes(x=variable, y=value, shape=variable)) +
          geom_line(aes(group=trial_exe,color=as.factor(trial_exe)),position=position_jitter(width = .01, height = .01))+
          geom_point(size = 2,position=position_jitter(width = .1, height = .1))+ 
          scale_y_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks)+
          xlab("decision")+ylab("Confidence level")+
          ggtitle(paste0("Confidence with switch - disagreement trials n.",as.character(p))))
  ggsave(file=sprintf(paste0("%siconf_Switch_disagree ",as.character(p),coll_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
}


################################################################################
# START SWITCH BAR PLOTS

# add confidence deltas to long format (only disagreement trials)
# with collective
dti_long_delta_coll = melt(dti[,c("pair_obs","trial_exe","deltaC2C1","deltaCcC1","deltaCiC1","switch")], id=c("pair_obs","trial_exe","switch"))
switch_sum_coll  = summarySE(dti_long_delta_coll,measurevar="value",groupvars=c("switch","variable"))
# without collective
dti_long_delta = melt(dti[,c("pair_obs","trial_exe","deltaC2C1","deltaCiC1","switch")], id=c("pair_obs","trial_exe","switch"))
switch_sum  = summarySE(dti_long_delta,measurevar="value",groupvars=c("switch","variable"))

# change factor level names
switch_sum$switch = as.factor(switch_sum$switch)
levels(switch_sum$switch) = c("No switch","Switch")
switch_sum$switch <- factor(switch_sum$switch, levels = c("Switch","No switch")) # change order
switch_sum$variable = as.factor(switch_sum$variable)
levels(switch_sum$variable) = c("Conf. 2 - Conf. 1","inferred Conf. - Conf. 1")

# scale for confidence delta
delta_scale = list("lim"=c(-2,2.5),"breaks"=seq(-2,2.5, by=0.5))
# colors
delta_colors = c("springgreen4", "springgreen")

# variable = subjective vs. inferred, value = confidence delta 
print(ggplot(data=switch_sum, aes(x=switch, y=value, fill=variable, color = variable)) +
  ggtitle("Switching as a function of confidence delta (only disagreement)") +
  geom_bar(stat="identity", position="dodge", alpha = 0.5, color = "black") +
  scale_fill_manual(values=delta_colors) +
  geom_errorbar(aes(ymin=value-se, ymax=value+se), size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
  scale_y_continuous(limits = delta_scale$lim, breaks=delta_scale$breaks) +
  xlab("Switching") + ylab("Confidence delta") + 
  theme(panel.grid.major = element_line(color = "black", size = .5),
        panel.grid.minor = element_line(color = "black", size = .25),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()) +
  theme(legend.position = "none")
)
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_Switching.png"), dpi = 300, units=c("cm"), height =20, width = 20)


# END SWITCH BAR PLOTS
###############################################################################

################################################################################
# START COLLECTIVE ADJUSTMENT PLOTS
delta_all = sinout_1block # include all data (agree and disagree)
switch_delta_all = delta_all[delta_all$switch==1,c("pair_obs","trial_exe","agree","switch","accuracy1", "accuracy2","Coll_acc", "confidence2", "Coll_conf",  "conf_aveBlock","confidence1", "deltaC2C1","deltaCiC1","deltaCcC1")] # only switch trials
noswitch_delta_all = delta_all[delta_all$switch==-1,c("pair_obs","trial_exe","agree","switch","accuracy1", "accuracy2","Coll_acc","confidence2", "Coll_conf",  "conf_aveBlock","confidence1", "deltaC2C1","deltaCiC1","deltaCcC1")] # only no switch trials
delta_disagree = delta_all[delta_all$agree==-1,c("pair_obs","trial_exe","agree","switch","accuracy1", "accuracy2","Coll_acc", "confidence2", "Coll_conf",  "conf_aveBlock","confidence1", "deltaC2C1","deltaCiC1","deltaCcC1")] # only switch trials

#rename and factorize levels
switch_delta_all$agree = as.factor(switch_delta_all$agree)
noswitch_delta_all$agree = as.factor(noswitch_delta_all$agree)
delta_disagree$agree = as.factor(delta_disagree$agree)
delta_disagree$switch = as.factor(delta_disagree$switch)
names(switch_delta_all) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy", "Confidence2", "Coll. Confidence",  "inf. Confidence","Confidence1", "Conf. 2 - Conf. 1","inferred Conf. - Conf. 1","coll. Conf. - Conf. 1")
names(noswitch_delta_all) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy","Confidence2", "Coll. Confidence",  "inf. Confidence","Confidence1", "Conf. 2 - Conf. 1","inferred Conf. - Conf. 1","coll. Conf. - Conf. 1")
names(delta_disagree) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy","Confidence2", "Coll. Confidence",  "inf. Confidence","Confidence1", "Conf. 2 - Conf. 1","inferred Conf. - Conf. 1","coll. Conf. - Conf. 1")
levels(switch_delta_all[,"Agreement"]) = c("disagree")
levels(delta_disagree[,"Agreement"]) = c("disagree")
levels(delta_disagree[,"Switch"]) = c("no switch", "switch")
levels(noswitch_delta_all[,"Agreement"]) = c("disagree", "agree")
noswitch_delta_all[,"Agreement"] <- factor(noswitch_delta_all[,"Agreement"], levels = c("agree","disagree")) # change order
delta_disagree[,"Switch"] <- factor(delta_disagree[,"Switch"], levels = c("switch","no switch")) # change order


# DISAGREEMENT TRIALS ONLY, split into switch vs. no switch
print(ggplot(delta_disagree, aes(x=delta_disagree[,"Conf. 2 - Conf. 1"], y=delta_disagree[,"coll. Conf. - Conf. 1"], color = delta_disagree[,"Switch"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1)) + 
        stat_smooth(method="lm", aes(x=delta_disagree[,"Conf. 2 - Conf. 1"], y=delta_disagree[,"coll. Conf. - Conf. 1"]), inherit.aes= F, se=T) +
        scale_color_manual(values=c("lightgreen", "lightcoral")) +
        scale_y_continuous(limits = c(-5.5,3.5), breaks=seq(-5.5,3.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5), breaks=seq(-5.5,5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, disagreement trials") +
        theme(legend.position = "none"))
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_Disagree.png"), dpi = 300, units=c("cm"), height =20, width = 20)


# SWITCH: subjective confidence
print(ggplot(switch_delta_all, aes(x=switch_delta_all[,"Conf. 2 - Conf. 1"], y=switch_delta_all[,"coll. Conf. - Conf. 1"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1))+ 
        stat_smooth(method="lm",se=TRUE) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, switch trials"))
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_Switch.png"), dpi = 300, units=c("cm"), height =20, width = 20)

# NO SWITCH: subjective confidence
print(ggplot(noswitch_delta_all, aes(x=noswitch_delta_all[,"Conf. 2 - Conf. 1"], y=noswitch_delta_all[,"coll. Conf. - Conf. 1"], color = noswitch_delta_all[,"Agreement"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1)) + 
        stat_smooth(method="lm",se=TRUE) +
        scale_color_manual(values=c("limegreen","red4")) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, no switch trials") +
        theme(legend.position = "none"))
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_NoSwitch.png"), dpi = 300, units=c("cm"), height =20, width = 20)

# SWITCH: inferred confidence
print(ggplot(switch_delta_all, aes(x=switch_delta_all[,"inferred Conf. - Conf. 1"], y=switch_delta_all[,"coll. Conf. - Conf. 1"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1))+ 
        stat_smooth(method="lm",se=TRUE) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("inferred Confidence - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("inferred Conf. - Conf. 1, switch trials"))
ggsave(file=paste0(PlotDir,"deltaInfConf-Conf1_CollConf_Switch.png"), dpi = 300, units=c("cm"), height =20, width = 20)

# NO SWITCH: inferred confidence
print(ggplot(noswitch_delta_all, aes(x=noswitch_delta_all[,"inferred Conf. - Conf. 1"], y=noswitch_delta_all[,"coll. Conf. - Conf. 1"], color = noswitch_delta_all[,"Agreement"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1)) + 
        stat_smooth(method="lm",se=TRUE) +
        scale_color_manual(values=c("limegreen","red4")) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("inferred Confidence - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("inferred Conf. - Conf. 1, no switch trials") +
        theme(legend.position = "none"))
ggsave(file=paste0(PlotDir,"deltaInfConf-Conf1_CollConf_NoSwitch.png"), dpi = 300, units=c("cm"), height =20, width = 20)


# END COLLECTIVE ADJUSTMENT PLOTS
################################################################################



########################################################################################

###################### RT and MT BY CONFIDENCE -OBSERVATION- ###################################
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


# plot the rt/mt according to inferred confidence (observation task)
print(plotSE(df=mt_rt_confObs_sum,xvar=mt_rt_confObs_sum$observer_confidence,yvar=mt_rt_confObs_sum$var,
             colorvar=mt_rt_confObs_sum$var_lab,shapevar=mt_rt_confObs_sum$var_lab,
             xscale=conf_scale,yscale=time_scale,titlestr=paste0("MT/RT as a function of confidence (individual 2nd) ",schon_lab),
             manual_col=c("grey", "black"),linevar=c("dashed","solid"),sizevar=c(3,3),disco=TRUE) +
        xlab("observer confidence") + ylab("time [s]") + theme_custom())
ggsave(file=sprintf(paste0("%stime_obs_conf",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


## Scatterplot - average value of confidence for Observation
# Linear regression: take observed conf. as predictor for subjective conf.
fit_ave <- lm(sinout_1block$conf_aveBlock ~ sinout_1block$agent_confidence) 
conf_exe_obsAve = ggplot(sinout_1block, aes(x = agent_confidence, y = conf_aveBlock)) +
  geom_point(shape = 1, position=position_jitter(width = 0.1, height = .01)) + 
  scale_y_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks) +
  scale_x_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks) +
  geom_smooth(method = lm, color = "blue", fill = "#69b3a2",se = TRUE) +
  annotate("text", x=5, y=1, label = paste("R2 = ", format(summary(fit_ave)$r.squared,digits=3)), col="black", cex=6)+
  ggtitle("Observer confidence vs Agent confidence")
print(conf_exe_obsAve + labs(y = "Mean observer confidence", x = "agent confidence"))
ggsave(file=sprintf(paste0("%sexeconf_vs_obsconfAveraged",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


# multiple facets with all the agents
# https://r-graphics.org/recipe-annotate-facet
mpg_plot <- ggplot(sinout, aes(x=agent_confidence, y=conf_aveBlock)) +
  geom_point() +
  facet_grid(. ~ interaction(pair_obs,Oagent)) +
  geom_point(shape = 1, position = position_jitter(width = 0.1, height = .1)) +
  geom_smooth(method = lm, color = "blue", fill = "#69b3a2",se = TRUE) 
print(mpg_plot)
ggsave(file=sprintf(paste0("%sexeconf_vs_obsconf_perPair_",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20*length(levels(interaction(sinout$pair_obs,sinout$Oagent))))

#### COLLECTIVE AND INDIVIDUAL(COLLECTIVE) BENEFIT ####
coll_benefit     = c(0.924,1.01,0.798)
coll_benefit2    = c(0.924,0.924,1.01,1.01,0.798,0.798)
ind_coll_benefit = c(1.9,0.86,1.12,1.45,0.89,1.46) #100:Blue, Yellow; 101:Blue, Yellow; 103:Blue, Yellow
r2               = c(0.42,0.37,0.02,0.04,0.34,0.46)
acc              = c(0.66,0.71,0.64,0.66,0.81,0.68) #100:Blue, Yellow; 101:Blue, Yellow; 103:Blue, Yellow
df = as.data.frame(cbind(ind_coll_benefit,r2,acc))

#multiple regression
fit1=lm(ind_coll_benefit~(r2*acc))
summary(fit1)

ggplot(df,aes(y=ind_coll_benefit,x=r2,color=acc))+geom_point()+stat_smooth(method="lm",se=FALSE)
# ggPredict(fit1,interactive=TRUE)

# plot(r2,ind_coll_benefit,xlim=c(0,0.5),ylim=c(0,2));abline(fit1)
# plot(r2,coll_benefit2,xlim=c(0,0.5),ylim=c(0,1.2))
#######################################################


#### Plot (averaged obs conf - agent conf) vs contrast level
# (averaged obs conf - agent conf) vs contrast level - calc the average, se, ci
diffConf_targ  = sinout_1block[,c("targetContrast","diff_conf","pair_obs","Oagent")]
diffConf_targ_sum = summarySE(diffConf_targ,measurevar="diff_conf",groupvars=c("targetContrast","pair_obs","Oagent"))

diff_scale = list("lim"=c(-0.2,2.8),"breaks"=seq(-0.2,2.8, by=0.2))
print(plotSE(df=diffConf_targ_sum,xvar=diffConf_targ_sum$targetContrast,yvar=diffConf_targ_sum$diff_conf,
             colorvar=interaction(diffConf_targ_sum$Oagent,diffConf_targ_sum$pair_obs),
             shapevar=NULL,
             xscale=target_scale,yscale=diff_scale,titlestr="Confidence difference per contrast levels",
             manual_col=interaction(diffConf_targ_sum$Oagent,diffConf_targ_sum$pair_obs),
             linevar=interaction(diffConf_targ_sum$Oagent,diffConf_targ_sum$pair_obs),sizevar=c(3,3),disco=FALSE) +
        xlab("Target Contrasts") + ylab("(mean obs confidence - agent confidence) ") + 
        scale_color_brewer(palette = "Paired")) + theme_custom()
ggsave(file=sprintf(paste0("%sdiffConf_vs_contrasts_",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)


## (averaged obs conf - agent conf) vs movement time
## averaged movement time - divided by CONTRAST/agent/group
diffConf_mt  = sinout_1block[,c("targetContrast","diff_conf","diff_mt_signed","pair_obs","Oagent")]
diffConf_mt_sum = summarySE(diffConf_mt,measurevar="diff_mt_signed",groupvars=c("targetContrast","pair_obs","Oagent"))
diffConf_mt_sum$diff_conf = diffConf_targ_sum$diff_conf

## averaged movement time - divided by AGENT/group
diffConf_diffMt  = sinout_1block[,c("diff_conf","diff_mt_signed","pair_obs","Oagent")]
sub_mt           = summarySE(diffConf_diffMt,measurevar="diff_mt_signed",groupvars=c("pair_obs"));names(sub_mt)=c("pair_obs","N_mt","diff_mt_signed","sd_mt","se_mt","ci_mt")
sub_mt           = sub_mt[rep(seq_len(nrow(sub_mt)), each = 2), ]
sub_conf         = summarySE(diffConf_diffMt,measurevar="diff_conf",groupvars=c("pair_obs","Oagent"));names(sub_conf)=c("pair_obs","Oagent","N_conf","diff_conf","sd_conf","se_conf","ci_conf")
diffConf_diffMt_sum  = cbind(sub_mt,sub_conf[,c("Oagent","N_conf","diff_conf","sd_conf","se_conf","ci_conf")])

#fitting a line
fit_ave_confMt <- lm(diffConf_diffMt$diff_mt_signed ~ diffConf_diffMt$diff_conf) 

# scatterplot - check each agent
# difference in MT include 1st and 2nd decision
# difference in confidence is always referred to the 2nd decision
print(ggplot(diffConf_diffMt_sum, aes(x=diff_mt_signed, y=diff_conf, color=interaction(Oagent,pair_obs))) + 
        geom_errorbar(aes(ymin=diff_conf-se_conf, ymax=diff_conf+se_conf), size=0.7, width=.01, position=pd) +
        geom_point(aes(color=interaction(Oagent,pair_obs))) + 
        scale_color_brewer(palette = "Paired"))
ggsave(file=sprintf(paste0("%sdiffConf_vs_diffMt",schon_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)


# XXX Do participants who rate observed decisions, on average, as more confident than their own also move more slowly than the observed actions?
# The faster agent should rate the observed action as less confident than their own (pCon > iCon). 
# However, all our pilot participants rate the observed action as more confident than their own (pCon < iCon).
# Patel, D., Fleming, S. M., & Kilner, J. M. (2012). Inferring subjective states through the observation of actions.
if(patel_mt){
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
}



################
coll_conf=lmer(Coll_conf ~ confidence1 * switch + conf_aveBlock + (1|interaction(dti$Pagent,dti$pair_obs)), data=dti)
summary(coll_conf)
# emmeans(coll_conf,pairwise~confidence1|switch)






