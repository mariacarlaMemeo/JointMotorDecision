# ==============================================================================
# Analysis of JMD study (JMD=joint motor decision)
# Data: collected in June 2022 @IIT Genova
# Participants: N=32 (16 pairs)
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
patel_mt   = FALSE # if TRUE: Does difference in MT predict inferred confidence? (see Patel et al., 2012)
pair_plots = FALSE # if TRUE: shows the confidence for each pair and each decision
rt_mt      = TRUE # if TRUE: includes the plots of RT and MT after cutting the kin trials

# Set paths (*** ADJUST TO LOCAL COMPUTER with flag local_user ***)
if (local_user == 1) {
  # set directories manually
  DataDir    = "C:/Users/MMemeo/OneDrive - Fondazione Istituto Italiano Tecnologia/Documents/GitHub/joint-motor-decision/Experiment/Data/Kinematic/" 
  AnaDir     = "C:/Users/MMemeo/OneDrive - Fondazione Istituto Italiano Tecnologia/Documents/GitHub/joint-motor-decision/Experiment/Analysis/Behavioral analysis/"
  PlotDir    = "C:/Users/MMemeo/OneDrive - Fondazione Istituto Italiano Tecnologia/Documents/GitHub/joint-motor-decision/Experiment/Analysis/Behavioral analysis/Behavioral plots/" # save plots here
} else {
  # Set directories manually
  DataDir    = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Data/Kinematic/"
  AnaDir     = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Analysis/Behavioral analysis/"
  PlotDir    = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Analysis/Behavioral analysis/Behavioral plots/"
}

# Call needed functions/scripts 
source(paste0(AnaDir,'bind_all_excel.R'))
source(paste0(AnaDir,'summarySE.R'))
source(paste0(AnaDir,'theme_custom.R'))
source(paste0(AnaDir,'plotSE.R'))
source(paste0(AnaDir,'final_rtmt_byAgent.R'))

# Initialize variables
decision1 = c()
conf1     = c()
acc1      = c()
decision2 = c()
conf2     = c()
acc2      = c()


#################################################################################################################################
### EXECUTION DATA (collective decision-making)

#XXX EDIT THE DESCRIPTION BELOW
# Goal: Create data frame with execution data.
# Steps to achieve goal:
# Retrieve data from an Excel file that was automatically created by merging the single pair files. 
# Single pair files were created with Matlab script movement_onset.m, which takes as input
# the original .mat files created during the experiment.
# -------------------------------------------------------------------------------------------

# XXXhere we should use the new kin_model Excel files
curdat=as.data.frame(bind_all_excel(DataDir))


# Add additional info to the data frame
# -------------------------------------

# Add a column (at the end) that expresses whether agents Y and B agree in their decisions [1=agreement, -1=disagreement]
curdat$agree                  = as.integer(curdat$B_decision == curdat$Y_decision)
curdat$agree[curdat$agree==0] =-1

# Add columns where decision, confidence, and accuracy are reported per 1st/2nd decision (rather than tied to agent Y and B)
for (row in 1:dim(curdat)[1])
{
  f_dec = curdat[row,"AgentTakingFirstDecision"]#agent taking first decision
  if (f_dec=="B") {
    decision1[row] = curdat[row,"B_decision"]
    conf1[row]     = curdat[row,"B_conf"]
    acc1[row]      = curdat[row,"B_acc"]} else {
    decision1[row] = curdat[row,"Y_decision"]
    conf1[row]     = curdat[row,"Y_conf"]
    acc1[row]      = curdat[row,"Y_acc"]
  }
  
  s_dec = curdat[row,"AgentTakingSecondDecision"]#agent taking second decision
  if (s_dec=="B") {
    decision2[row] = curdat[row,"B_decision"]
    conf2[row]     = curdat[row,"B_conf"]
    acc2[row]      = curdat[row,"B_acc"]} else {
    decision2[row] = curdat[row,"Y_decision"]
    conf2[row]     = curdat[row,"Y_conf"]
    acc2[row]      = curdat[row,"Y_acc"]
  }
}
# Add the computed values (decision, confidence, accuracy) for 1st/2nd decision to curdat
curdat$decision1   = decision1
curdat$decision2   = decision2
curdat$confidence1 = conf1
curdat$confidence2 = conf2
curdat$accuracy1   = acc1
curdat$accuracy2   = acc2
# add columns for the confidence difference values (deltas):
# confidence2 - confidence1:
# deltaC2C1 < 0 = conf2 < conf1; deltaC2C1 > 0 = conf2 > conf1
curdat$deltaC2C1   = curdat$confidence2-curdat$confidence1
# confidenceColl - confidence1:
# deltaCcC1 < 0 = Coll_conf < conf1; deltaCcC1 > 0 = Coll_conf > conf1
curdat$deltaCcC1   = curdat$Coll_conf-curdat$confidence1

# Sanity check: just checks trials in which B=Y -> then also decision1 must be equal to decision2
all(as.integer(curdat$B_decision == curdat$Y_decision) == as.integer(curdat$decision1 == curdat$decision2))

# Add a column that indicates whether 1st and collective decision differ,
# i.e., whether A1 switched her decision (changed her mind) [1=switch, -1=no switch]
switchR                         = as.integer(curdat$decision1 != curdat$Coll_decision)
all(curdat$switch == switchR)
# GO ON ONLY IF THE PREVIOUS IS TRUE
curdat$switch[curdat$switch==0] = -1



# Configure plot parameters
# -------------------------
pd            = position_dodge(0.001)
acc_scale     = list("lim"=c(0,1),"breaks"=seq(0,1, by=0.2))
acc_scale2    = list("lim"=c(0,0.85),"breaks"=seq(0,0.85, by=0.1)) # for mean values up to ~0.8
target_scale  = list("breaks"=unique(curdat$targetContrast),"labels"=unique(curdat$targetContrast))
conf_scale    = list("lim"=c(1,6),"breaks"=seq(1,6, by=1))
#conf_scale_la = list("lim"=c(1,6),"breaks"=seq(1,6, by=1), "labels"=c(1,2,3,4,5,6))
conf_scale2   = list("lim"=c(1,4.5),"breaks"=seq(1,4.5, by=1)) # for mean values up to ~4
time_scale    = list("lim"=c(0,2),"breaks"=seq(0,2, by=0.25))
mov_scale     = list("lim"=c(0.5,1.75),"breaks"=seq(0.5,1.75, by=0.25))
switch_colors = c("lightcoral", "lightgreen")
bar_colors    = c("gray88", "gray44", "lightcoral", "lightgreen")



# XXX more sanity checks:
# 1. confidence distribution: all levels (1-6) used equally? (on average and per participant)
# 2. plot accuracy as a function of confidence level -> positive correlation expected
# 3. target1/target2 distribution: left/right bias (on average and per participant)

#1. Confidence distribution
all_conf = curdat[,c("Pair","confidence1","confidence2","Coll_conf","targetContrast")]
names(all_conf)[names(all_conf)=='confidence1']    <- 'Confidence 1st decision'
names(all_conf)[names(all_conf)=='confidence2']    <- 'Confidence 2nd decision'
names(all_conf)[names(all_conf)=='Coll_conf']    <- 'Confidence collective decision'
all_conf$targetContrast = as.factor(all_conf$targetContrast)
#levels(all_conf$targetContrast) <- c(0.115, 0.135, 0.17, 0.25)
count_scale_conftar    = list("lim"=c(0,175),"breaks"=seq(0,175, by=25))
count_scale_conf       = list("lim"=c(0,600),"breaks"=seq(0,600, by=50))
#levels(conf_all_sum_acc$agree)    = c("disagree", "agree")

for(confy in (seq(2,ncol(all_conf)-1))){
  var_conf = all_conf[,confy] # confy=confidence1,confidence2,coll_Conf
  # plot confidence count split by target contrast
  print(ggplot(all_conf, aes(x=var_conf, fill=targetContrast)) +
          stat_count(geom = "bar", position="dodge2") +
          scale_y_continuous(limits = count_scale_conftar$lim, breaks = count_scale_conftar$breaks) +
          scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
          ggtitle(colnames(all_conf)[confy]) +
          ylab("Count") + xlab("Confidence level") + theme_custom())
  # save the plot
  ggsave(file=sprintf(paste0("%sConfidenceHist_",as.character(confy-1),"_target.png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  
  # plot confidence count
  print(ggplot(all_conf, aes(x=var_conf)) +
          stat_count(geom = "bar", position="dodge2") +
          scale_y_continuous(limits = count_scale_conf$lim, breaks = count_scale_conf$breaks) +
          scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
          ggtitle(colnames(all_conf)[confy]) +
          ylab("Count") + xlab("Confidence level") + theme_custom())
  # print the confidence means in the console
  print(sprintf("Average %s%s %.2f", colnames(all_conf)[confy], ":", round(mean(all_conf[,confy]),2)))
  print(sprintf("SD %s%s %.2f", colnames(all_conf)[confy], ":", round(sd(all_conf[,confy]),2)))
  # save the plot
  ggsave(file=sprintf(paste0("%sConfidenceHist_",as.character(confy-1),".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
}

# 3. check for left-right response bias
curdat$targetContrast = as.factor(curdat$targetContrast)
curdat$decision1=as.factor(curdat$decision1)
levels(curdat$decision1)= c("left","right")

curdat$decision2=as.factor(curdat$decision2)
levels(curdat$decision2)= c("left","right")

curdat$Coll_decision=as.factor(curdat$Coll_decision)
levels(curdat$Coll_decision)= c("left","right")

ggplot(curdat, aes(x=decision2,fill=targetContrast)) +
  stat_count(geom = "bar", position="dodge2") +
  # scale_y_continuous(limits = count_scale_conf$lim, breaks = count_scale_conf$breaks) +
  # scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
  # ggtitle(colnames(all_conf)[confy]) +
  ylab("Count") + xlab("1st decision") + theme_custom()




# Check PROPORTIONS: high/low confidence, agreement/disagreement, switch/no switch
# --------------------------------------------------------------------------------
# High/low confidence: Select high/low confidence trials for each agent and average the values
# XXX
# perc_conf_lo = round(100*(dim(curdat[(curdat$B_conf>=1 & curdat$B_conf<=3)|(curdat$Y_conf>=1 & curdat$Y_conf<=3),])[1])/(2*dim(curdat)[1]))
# perc_conf_hi = round(100*(dim(curdat[(curdat$B_conf==c(4) | curdat$B_conf==c(5) | curdat$B_conf==c(6)) ])[1]+dim(curdat[(curdat$Y_conf==c(4) | curdat$Y_conf==c(5) | curdat$Y_conf==c(6))])[1])/(2*dim(curdat)[1]))
# sprintf("Low confidence trials (1-3): %d %s", perc_conf_lo, "%")
# sprintf("High confidence trials (4-6): %d %s", perc_conf_hi, "%")

# Sub-select agreement/disagreement trials
at      = curdat[curdat$agree==1,]
dt      = curdat[curdat$agree==-1,]

# Plot disagreement according to target contrast
# agreement: 1=agreement, -1=disagreement; contrasts = c(0.115, 0.135, 0.170, 0.250)
# hist(at$targetContrast)
# XXX for loop for the indi
contrastData_all  = curdat[,c('Pair','targetContrast','agree','switch')]
contrastData_indi = contrastData_all[contrastData_all$Pair==124,]
indi = 0; # select whether to plot aggregate or individual data ((indi=0 vs. indi=1)
if (indi==1) {
  contrastD      = contrastData_indi
  count_scale    = list("lim"=c(0,40),"breaks"=seq(0,40, by=10))
  count_scale_dt = list("lim"=c(0,20),"breaks"=seq(0,20, by=5))
} else {
  contrastD = contrastData_all
  count_scale = list("lim"=c(0,500),"breaks"=seq(0,500, by=50))
  count_scale_dt = list("lim"=c(0,200),"breaks"=seq(0,200, by=20))
}
contrastD$agree          = as.factor(contrastD$agree)
levels(contrastD$agree)  = c("disagree", "agree")
contrastD$switch         = as.factor(contrastD$switch)
levels(contrastD$switch) = c("no switch", "switch")
contrastD$targetContrast = as.factor(contrastD$targetContrast)

# plot agreement as a function of target contrast
ggplot(contrastD, aes(x=targetContrast, fill=agree)) +
  stat_count(geom = "bar", position="dodge2") +
  scale_y_continuous(limits = count_scale$lim, breaks = count_scale$breaks) +
  scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
    xlab("Target contrasts") + ylab("Count") + theme_custom()
ggsave(file=paste0(PlotDir,"hist_agree_contrast.png"), dpi = 300, units=c("cm"), height =20, width = 20)
# plot switch as a function of target contrast (only disagreement!)
contrastD_dt = contrastD[contrastD$agree=="disagree",]
ggplot(contrastD_dt, aes(x=contrastD_dt$targetContrast, fill=contrastD_dt$switch)) +
  stat_count(geom = "bar", position="dodge2") + scale_fill_manual(values=switch_colors) +
  scale_y_continuous(limits = count_scale_dt$lim, breaks = count_scale_dt$breaks) +
  scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
  xlab("Target contrasts") + ylab("Count") + theme_custom()
ggsave(file=paste0(PlotDir,"hist_contrast_switch_dt.png"), dpi = 300, units=c("cm"), height =20, width = 20)

# Percentage of (dis)agreement trials relative to all trials
perc_dt          = round(100*(dim(dt)[1]/dim(curdat)[1])) #40% in exp #39% in pilot
perc_at          = round(100*(dim(at)[1]/dim(curdat)[1])) #60% in exp #61% in pilot
sprintf("Disagreement trials: %d %s", perc_dt, "%")
sprintf("Agreement trials: %d %s", perc_at, "%")

# Percentage of switch/noswitch in case of disagreement (and for all trials)
dt_switch         = dt[dt$switch==1,]
dt_noswitch       = dt[dt$switch==-1,]
perc_dt_switch    = round(100*(dim(dt_switch)[1]/dim(dt)[1]))     #54% #64% in pilot
perc_dt_noswitch  = round(100*(dim(dt_noswitch)[1]/dim(dt)[1]))   #46% #36% in pilot
perc_all_switch   = round(100*(dim(dt_switch)[1]/dim(curdat)[1])) #21% #25% in pilot
perc_all_noswitch = round(100*(dim(dt_noswitch)[1]/dim(curdat)[1])+100*(dim(at)[1]/dim(curdat)[1])) #79% #75% in pilot
sprintf("Switch as proportion of disagreement trials: %d %s", perc_dt_switch, "%")
sprintf("No switch as proportion of disagreement trials: %d %s", perc_dt_noswitch, "%")
sprintf("Switch/no switch as proportion of all trials: %d %s %d %s", perc_all_switch, "% /", perc_all_noswitch, "%")
# Check if there is switching in case of agreement (1st = 2nd decision)
at_switch = at[at$switch==1,] # should be empty (no switch if agreement)
if (nrow(at_switch) == 0) {
  print("ALL GOOD: No switches if co-actors agree!")
} else {
  print("WHAAAT? Switches even if agreement?")
}


# Comparisons between more vs. less sensitive dyad members
# --------------------------------------------------------
# XXX
# source(paste0(DataDir,'goodVSbadGuys.R')) # call separate script good vs. bad




# List of plots
#--------------
#0. CONFIDENCE distribution
#1. CONFIDENCE as a function of TARGET CONTRAST
#2. ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH
#3. mean ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH (bar plots)
#4. CONFIDENCE DIFFERENCE for A1 and A2
#5. RT and MT as a function of CONFIDENCE (for 2nd decision only)
#6. RT and MT as a function of TARGET CONTRAST
#7. SWITCH BAR PLOTS - confidence delta as a function of switch

# XXX check from line 534 onward (observation part)


# START PLOTTING
# ------------------------------------------------------------------------------
# XXX
#0. CONFIDENCE distribution

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
ggsave(file=paste0(PlotDir,"conf_agree",".png"), dpi = 300, units=c("cm"), height =20, width = 20)


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
ggsave(file=paste0(PlotDir,"conf_agree_acc_coll",".png"), dpi = 300, units=c("cm"), height =20, width = 20)


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
# 3a. Accuracy split by agreement and switch (only A1 and collective decisions)
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


# 3b. Confidence split by agreement and switch (only A1 and collective decisions)
# --------------------------------------------------------------------------------
# x-axis: individual/collective
# color:  agree/disagree
# panels: switch/no switch
# bars:   light gray (agree) vs. dark gray (disagree)
# panels: green (switch) vs. red (no switch)


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


# --------------------------------------------------------------------------------
# 4. CONFIDENCE DIFFERENCE for A1 and A2
# Show confidence for both individual decisions (A1 and A2).
# Plot per pair, separate plots for switch/no switch. Only disagreement trials.

if(pair_plots){
  coll = FALSE # include also the collective decision?
  if (coll) {
    dt_long  = melt(dt[,c("Pair","Trial","confidence1","confidence2","Coll_conf","switch")], id=c("Pair","Trial","switch"))
    coll_lab = "_3conf"} else {
      dt_long  = melt(dt[,c("Pair","Trial","confidence1","confidence2","switch")], id=c("Pair","Trial","switch"))
      coll_lab = ""
    }
  
  # No switch plots, per pair (disagreement trials)
  for(p in unique(dt_long$Pair)){
    no_switch_100=dt_long[dt_long$Pair==p & dt_long$switch==-1,]
    print(ggplot(no_switch_100, aes(x=variable, y=value,shape=variable)) +
            geom_line(aes(Pair=Trial,color=as.factor(Trial)),position=position_jitter(width = .01, height = .01))+
            geom_point(size = 2, position=position_jitter(width = .1, height = .1)) +
            scale_y_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks)+
            xlab("decision")+ylab("Confidence level")+
            ggtitle(paste0("Confidence with no switch - disagreement trials n.",as.character(p))))
    ggsave(file=sprintf(paste0("%sconf_noSwitch_disagree ",as.character(p),coll_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  }
  
  # Switch plots, per pair (disagreement trials)
  for(p in unique(dt_long$Pair)){
    switch_100=dt_long[dt_long$Pair==p & dt_long$switch==1,]
    print(ggplot(switch_100, aes(x=variable, y=value,shape=variable)) +
            geom_line(aes(Pair=Trial,color=as.factor(Trial)),position=position_jitter(width = .01, height = .01))+
            geom_point(size = 2, position=position_jitter(width = .1, height = .1)) +
            scale_y_discrete(limits = factor(conf_scale$breaks), breaks=conf_scale$breaks)+
            xlab("decision")+ylab("Confidence level")+
            ggtitle(paste0("Confidence with switch - disagreement trials n.",as.character(p))))
    ggsave(file=sprintf(paste0("%sconf_Switch_disagree ",as.character(p),coll_lab,".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  }
}


# ------------------------------------------------------------------------------------------------------------------------------
# 5. RT and MT as a function of CONFIDENCE (for 2nd decision only!!!)
# "B_rt" and "Y_rt" (previously "A1_rt" and "A2_rt") refer to RT calculated for each agent during acquisition (the same for mt). 
# In the post-processing we re-calculated rt and mt for each decision ("rt_final1" and "rt_final2").
# The new calculation is based on a velocity threshold: from now, we will use this final rt/mt. 
# NOTE: The variables are related to the rt of the 1st and 2nd decision respectively (not to the agent).

if (rt_mt){
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
               xscale=conf_scale,yscale=time_scale,titlestr=paste0("MT/RT as a function of confidence (2nd decision) "),
               manual_col=c("grey", "black"),linevar=c("dashed","solid"),sizevar=c(3,3),disco=TRUE) +
          xlab("agent confidence") + ylab("time [s]") + theme_custom())
  ggsave(file=sprintf(paste0("%stime_conf_2d",".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)
  
  
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
      all <- curdat[,c("targetContrast","B_rtKin","Y_rtKin","rt_finalColl","Pair")]
      mov_scale = list("lim"=c(0,1.8),"breaks"=seq(0,1.8, by=0.2))} else {
        lab="MT"
        all <- curdat[,c("targetContrast","B_mtKin","Y_mtKin","mt_finalColl","Pair")]
        mov_scale = list("lim"=c(0.5,2.5),"breaks"=seq(0.5,2.5, by=0.25))
      }
    
    # prep data
    all$Pair=as.factor(all$Pair)

    for (g in all_pairs) {
      
      sub_all=all[all$Pair==g,]
      sub_all=subset(sub_all, select = -c(Pair) )
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
}
# ------------------------------------------------------------------------------------------------------------------------------
# 7. START SWITCH BAR PLOTS - confidence delta as a function of switch

# add confidence deltas to long format (only disagreement trials)
# without collective
dt_long_delta = melt(dt[,c("Pair","deltaC2C1","switch")], id=c("Pair","switch"))
switch_sum  = summarySE(dt_long_delta,measurevar="value",groupvars=c("switch","variable"))

# change factor level names
switch_sum$switch = as.factor(switch_sum$switch)
levels(switch_sum$switch) = c("No switch","Switch")
switch_sum$switch <- factor(switch_sum$switch, levels = c("Switch","No switch")) # change order
switch_sum$variable = as.factor(switch_sum$variable)
levels(switch_sum$variable) = c("Conf. 2 - Conf. 1")

# scale for confidence delta
delta_scale = list("lim"=c(-2,1),"breaks"=seq(-2,1, by=0.5))
# colors
delta_color = c("gray")

# variable = subjective vs. inferred, value = confidence delta 
print(ggplot(data=switch_sum, aes(x=switch, y=value, fill=variable, color = variable)) +
        ggtitle("Switching as a function of confidence delta (only disagreement)") +
        geom_bar(stat="identity", position="dodge", alpha = 0.5, color = "black") +
        scale_fill_manual(values=delta_color) +
        geom_errorbar(aes(ymin=value-se, ymax=value+se), size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
        scale_y_continuous(limits = delta_scale$lim, breaks=delta_scale$breaks) +
        xlab("Switching") + ylab("Confidence delta") + 
        theme(legend.position = "none") + theme_custom()
)
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_Switching.png"), dpi = 300, units=c("cm"), height =20, width = 20)



# END SWITCH BAR PLOTS
###############################################################################

################################################################################
# START COLLECTIVE ADJUSTMENT PLOTS
sub_switch = curdat[curdat$switch==1,c("Pair","Trial","agree","switch","accuracy1", "accuracy2","Coll_acc", "confidence2", "Coll_conf","confidence1", "deltaC2C1","deltaCcC1")] # only switch trials
sub_noswitch = curdat[curdat$switch==-1,c("Pair","Trial","agree","switch","accuracy1", "accuracy2","Coll_acc","confidence2", "Coll_conf","confidence1", "deltaC2C1","deltaCcC1")] # only no switch trials
sub_dt = dt[,c("Pair","Trial","agree","switch","accuracy1", "accuracy2","Coll_acc", "confidence2", "Coll_conf","confidence1", "deltaC2C1","deltaCcC1")] # only switch trials

#rename and factorize levels
sub_switch$agree = as.factor(sub_switch$agree)
sub_noswitch$agree = as.factor(sub_noswitch$agree)
sub_dt$agree = as.factor(sub_dt$agree)
sub_dt$switch = as.factor(sub_dt$switch)
names(sub_switch) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy", "Confidence2", "Coll. Confidence","Confidence1", "Conf. 2 - Conf. 1","coll. Conf. - Conf. 1")
names(sub_noswitch) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy","Confidence2", "Coll. Confidence","Confidence1", "Conf. 2 - Conf. 1","coll. Conf. - Conf. 1")
names(sub_dt) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy","Confidence2", "Coll. Confidence","Confidence1", "Conf. 2 - Conf. 1","coll. Conf. - Conf. 1")
levels(sub_switch[,"Agreement"]) = c("disagree")
levels(sub_dt[,"Agreement"]) = c("disagree")
levels(sub_dt[,"Switch"]) = c("no switch", "switch")
levels(sub_noswitch[,"Agreement"]) = c("disagree", "agree")
sub_noswitch[,"Agreement"] <- factor(sub_noswitch[,"Agreement"], levels = c("agree","disagree")) # change order
sub_dt[,"Switch"] <- factor(sub_dt[,"Switch"], levels = c("switch","no switch")) # change order


# DISAGREEMENT TRIALS ONLY, split into switch vs. no switch
print(ggplot(sub_dt, aes(x=sub_dt[,"Conf. 2 - Conf. 1"], y=sub_dt[,"coll. Conf. - Conf. 1"], color = sub_dt[,"Switch"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1)) + 
        stat_smooth(method="lm", aes(x=sub_dt[,"Conf. 2 - Conf. 1"], y=sub_dt[,"coll. Conf. - Conf. 1"]), inherit.aes= F, se=T) +
        scale_color_manual(values=c("lightgreen", "lightcoral")) +
        scale_y_continuous(limits = c(-5.5,3.5), breaks=seq(-5.5,3.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5), breaks=seq(-5.5,5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, disagreement trials") +
        theme(legend.position = "none"))
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_Disagree.png"), dpi = 300, units=c("cm"), height =20, width = 20)


# SWITCH: subjective confidence
print(ggplot(sub_switch, aes(x=sub_switch[,"Conf. 2 - Conf. 1"], y=sub_switch[,"coll. Conf. - Conf. 1"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1))+ 
        stat_smooth(method="lm",se=TRUE) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, switch trials"))
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_Switch.png"), dpi = 300, units=c("cm"), height =20, width = 20)

# NO SWITCH: subjective confidence
print(ggplot(sub_noswitch, aes(x=sub_noswitch[,"Conf. 2 - Conf. 1"], y=sub_noswitch[,"coll. Conf. - Conf. 1"], color = sub_noswitch[,"Agreement"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1)) + 
        stat_smooth(method="lm",se=TRUE) +
        scale_color_manual(values=c("limegreen","red4")) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, no switch trials") +
        theme(legend.position = "none"))
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_NoSwitch.png"), dpi = 300, units=c("cm"), height =20, width = 20)

# END COLLECTIVE ADJUSTMENT PLOTS
##############################################################################

# #### LINEAR MODEL
#########################################################
# Quick test on linear models
coll_conf=lmer(Coll_conf ~ confidence1 * switch + confidence2 + (1|interaction(curdat$Pair)), data=curdat)
summary(coll_conf)
# emmeans(coll_conf,pairwise~confidence1|switch)
#########################################################



# #### PATEL (only works with observation data)
#########################################################
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
  ggsave(file=sprintf(paste0("%sdiff_mt_pCon_iCon",".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)
}


# #### COLLECTIVE AND INDIVIDUAL(COLLECTIVE) BENEFIT ####
# coll_benefit     = c(0.924,1.01,0.798)
# coll_benefit2    = c(0.924,0.924,1.01,1.01,0.798,0.798)
# ind_coll_benefit = c(1.9,0.86,1.12,1.45,0.89,1.46) #100:Blue, Yellow; 101:Blue, Yellow; 103:Blue, Yellow
# r2               = c(0.42,0.37,0.02,0.04,0.34,0.46)
# acc              = c(0.66,0.71,0.64,0.66,0.81,0.68) #100:Blue, Yellow; 101:Blue, Yellow; 103:Blue, Yellow
# df = as.data.frame(cbind(ind_coll_benefit,r2,acc))
# 
# #multiple regression
# fit1=lm(ind_coll_benefit~(r2*acc))
# summary(fit1)
# 
# ggplot(df,aes(y=ind_coll_benefit,x=r2,color=acc))+geom_point()+stat_smooth(method="lm",se=FALSE)
# # ggPredict(fit1,interactive=TRUE)
# 
# # plot(r2,ind_coll_benefit,xlim=c(0,0.5),ylim=c(0,2));abline(fit1)
# # plot(r2,coll_benefit2,xlim=c(0,0.5),ylim=c(0,1.2))
# #######################################################

