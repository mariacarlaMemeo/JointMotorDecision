# ==============================================================================
# Analysis of JMD study (JMD=joint motor decisions) - behavioral data
# Experiment: conducted in June 2023 @IIT Genova
# Participants: N=32 (16 pairs) - 1 pair (S119) excluded, so 15 pairs
# Script: written by Mariacarla Memeo & Laura Schmitz
# ==============================================================================


# Preparatory steps
# -----------------

# Remove variables and plots
rm(list = ls())
graphics.off()

# Save all plots?
save_plots      = 0
# Write Excel file with all data and info file?
save_data_final = 0

# if(!require(devtools)) install.packages("devtools")
# devtools::install_github("kassambara/ggpubr")
# library("ggpubr")

# Define necessary packages
pckgs = c("data.table","lattice","lme4", "nlme","emmeans","doBy","effsize","ez",
          "MuMIn","BayesFactor","permuco","RVAideMemoire",
          "RColorBrewer","stringr","knitr","multcomp","ggplot2","ggiraph","car","dplyr",
          "plyr","lmerTest","ggrepel","sjstats","reshape2","readxl","writexl",
          "cellranger")
# Load all of them and check how many packages failed to load
sum(lapply(pckgs, require, character.only = TRUE)==FALSE)

# Set flags
local_user = 2;    # set current user (1=MC, 2=LA)
patel_mt   = FALSE # if TRUE: Does difference in MT predict inferred confidence? (Patel 2012)
pair_plots = FALSE # if TRUE: shows the confidence for each pair per decision

# Import info about max./min. agent from Excel file (created in Matlab)
minmax <- read_excel("minmaxTable.xlsx")

# Set paths (*** ADJUST TO LOCAL COMPUTER with flag local_user ***)
# ! We access (and save) everything on GitHub - DataDir=pre-processed Excel files !
if (local_user == 1) {
  DataDir = "D:/GitHub_D/joint-motor-decision/JointMotorDecision/Experiment/Data/Behavioral/preprocessed/" 
  AnaDir  = "D:/GitHub_D/joint-motor-decision/JointMotorDecision/Experiment/Analysis/Behavioral analysis/"
  PlotDir = "D:/GitHub_D/joint-motor-decision/JointMotorDecision/Experiment/Analysis/Behavioral analysis/Behavioral plots/"
} else {
  DataDir = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Data/Behavioral/preprocessed/" #"D:/DATA/Processed/"
  AnaDir  = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Analysis/Behavioral analysis/"
  PlotDir = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Analysis/Behavioral analysis/Behavioral plots/"
}

# Call functions
source(paste0(AnaDir,'bind_all_excel.R'))
source(paste0(AnaDir,'summarySE.R'))
source(paste0(AnaDir,'theme_custom.R'))
source(paste0(AnaDir,'plotSE.R'))
source(paste0(AnaDir,'final_rtmt_byAgent.R'))
source(paste0(AnaDir,'compareMinMax.R'))
source(paste0(AnaDir,'jmdData_info.R'))
source(paste0(AnaDir,'check_confDistribution.R'))


# RETRIEVE DATA and CREATE DATA FRAME
# ------------------------------------------------
# Goal: Create data frame with data from all pairs.
# Steps to achieve goal:
# 1. Retrieve Excel files (1 per pair) that we created after cutting the trials (jmdData_S1xx.xlsx).
#    These Excel files are based on the preprocessed .mat files (S1xx.mat) created with the toolbox.
#    (Files located in DATA/Processed (on individual hard drives):
#    S1xx.mat (preprocessed), S1xx.mat_post and jmdData_S1xx.xlsx (final files after cutting))
# 2. Merge all Excel files into one big data frame (curdat) using the function bind_all_excel.

# merge Excel files from all pairs into one data frame named "curdat"
curdat=as.data.frame(bind_all_excel(DataDir))
curdat=curdat[,1:1061] # delete last columns (velocity peaks - different no. of columns across pairs)


# Add additional vars to the curdat data frame
# --------------------------------------------

# Add a column expressing whether agents B and Y agree in their decisions [1=agreement, -1=disagreement]
curdat$agree                  = as.integer(curdat$B_decision == curdat$Y_decision)
curdat$agree[curdat$agree==0] = -1

# Add columns where decision, confidence, and accuracy are reported per 1st/2nd decision (rather than tied to agent B/Y)

# Initialize variables
decision1 = c(); conf1 = c(); acc1 = c()
decision2 = c(); conf2 = c(); acc2 = c()
# Assign values to variables
for (row in 1:dim(curdat)[1]) {
  
  f_dec = curdat[row,"AgentTakingFirstDecision"] #agent taking first decision
  if (f_dec=="B") {
    decision1[row] = curdat[row,"B_decision"]
    conf1[row]     = curdat[row,"B_conf"]
    acc1[row]      = curdat[row,"B_acc"]} else {
    decision1[row] = curdat[row,"Y_decision"]
    conf1[row]     = curdat[row,"Y_conf"]
    acc1[row]      = curdat[row,"Y_acc"]
  }
  
  s_dec = curdat[row,"AgentTakingSecondDecision"] #agent taking second decision
  if (s_dec=="B") {
    decision2[row] = curdat[row,"B_decision"]
    conf2[row]     = curdat[row,"B_conf"]
    acc2[row]      = curdat[row,"B_acc"]} else {
    decision2[row] = curdat[row,"Y_decision"]
    conf2[row]     = curdat[row,"Y_conf"]
    acc2[row]      = curdat[row,"Y_acc"]
  }
}
# Add computed values (decision, confidence, accuracy) for 1st/2nd decision
curdat$decision1   = decision1
curdat$decision2   = decision2
curdat$confidence1 = conf1
curdat$confidence2 = conf2
curdat$accuracy1   = acc1
curdat$accuracy2   = acc2

# Sanity check: just check trials in which B=Y -> then also decision1 must be equal to decision2
all(as.integer(curdat$B_decision == curdat$Y_decision) == as.integer(curdat$decision1 == curdat$decision2))


# Add columns on worse(min)/better(max) agent (each for confidence and accuracy)
curdat$maxAgent = NA; curdat$minAgent = NA;
curdat$maxConf = NA; curdat$maxAcc = NA; curdat$minConf = NA; curdat$minAcc = NA;
for (p in unique(curdat$Pair)) { # p = pair
  if (minmax[minmax$Pair==p,"maxAgent"] == "B") {
    curdat[curdat$Pair==p,"maxConf"]  = curdat[curdat$Pair==p,"B_conf"]
    curdat[curdat$Pair==p,"minConf"]  = curdat[curdat$Pair==p,"Y_conf"]
    curdat[curdat$Pair==p,"maxAcc"]   = curdat[curdat$Pair==p,"B_acc"]
    curdat[curdat$Pair==p,"minAcc"]   = curdat[curdat$Pair==p,"Y_acc"]
    curdat[curdat$Pair==p,"maxAgent"] = "B" # max agent in this pair
    curdat[curdat$Pair==p,"minAgent"] = "Y" # min agent in this pair
  } else {
    curdat[curdat$Pair==p,"maxConf"]  = curdat[curdat$Pair==p,"Y_conf"]
    curdat[curdat$Pair==p,"minConf"]  = curdat[curdat$Pair==p,"B_conf"]
    curdat[curdat$Pair==p,"maxAcc"]   = curdat[curdat$Pair==p,"Y_acc"]
    curdat[curdat$Pair==p,"minAcc"]   = curdat[curdat$Pair==p,"B_acc"]
    curdat[curdat$Pair==p,"maxAgent"] = "Y"
    curdat[curdat$Pair==p,"minAgent"] = "B"
  }
}

# Add column on whether min or max agent takes first decision
mima_f_dec = c()
for (row in 1:dim(curdat)[1]) {
  f_dec   = curdat[row,"AgentTakingFirstDecision"]
  max_ag  = curdat[row,"maxAgent"]
  if (f_dec=="B" & max_ag=="B") {
    mima_f_dec[row] = "max"
  } else if (f_dec=="Y" & max_ag=="Y") {
    mima_f_dec[row] = "max"
  } else if (f_dec=="B" & max_ag=="Y") {
    mima_f_dec[row] = "min"
  } else if (f_dec=="Y" & max_ag=="B") {
    mima_f_dec[row] = "min"
  }
}
curdat$mima_dec1 = mima_f_dec # who takes 1st dec. in this trial? (min or max agent)


# Add columns for the confidence difference values (deltas):
# confidence2-confidence1: deltaC2C1<0 = conf2<conf1; deltaC2C1>0 = conf2>conf1
curdat$deltaC2C1 = curdat$confidence2-curdat$confidence1
# confidenceColl-confidence1: deltaCcC1<0 = Coll_conf<conf1; deltaCcC1>0 = Coll_conf>conf1
curdat$deltaCcC1 = curdat$Coll_conf-curdat$confidence1

# Add a column that indicates whether 1st and collective decision differ ("switch"),
# i.e., whether A1 switched her decision (changed her mind) [1=switch, -1=no switch]
switchR = as.integer(curdat$decision1 != curdat$Coll_decision)
# Sanity check: we already added a "switch" column in Matlab - now we check if columns are identical
all(curdat$switch == switchR) # must be true
# GO ON ONLY IF THE PREVIOUS IS TRUE
curdat$switch[curdat$switch==0] = -1 # now 1=switch, -1=no switch

# Check probability of switching per agent (only AgentTakingFirstDecision can switch)
# -1= no switch, 1=switch, 0=no data because agent took 2nd decision
swMax = c(); swMin = c()
for (row in 1:dim(curdat)[1]) {
  
  switch_d = curdat[row,"switch"]
  mima_d  = curdat[row,"mima_dec1"]
  
  if (switch_d==1 & mima_d=="max") {
    swMax[row] = 1
    swMin[row] = 0
  } else if (switch_d==-1 & mima_d=="max") {
    swMax[row] = -1
    swMin[row] = 0
  } else if (switch_d==1 & mima_d=="min") {
    swMax[row] = 0
    swMin[row] = 1
  } else if (switch_d==-1 & mima_d=="min") {
    swMax[row] = 0
    swMin[row] = -1
  }
}
curdat$switchMax = swMax
curdat$switchMin = swMin

# add two columns to minmax data frame to record probability of switching
minmax[c("maxSwitchProb", "minSwitchProb")] <- NA

for (p in unique(curdat$Pair)) { # p = pair
  
  # swMax = sum of switches for maxAgent / no. of trials in which maxAgent could switch (i.e., acted first)
  # sanity check: length(curdat[curdat$Pair==p & curdat$mima_dec1=="max","switchMax"])==
  #               length(curdat[curdat$Pair==p & curdat$switchMax!=0,"switchMax"])
  swMax=sum(curdat[curdat$Pair==p & curdat$switchMax==1,"switchMax"]) /
        length(curdat[curdat$Pair==p & curdat$switchMax!=0,"switchMax"])
  swMin=sum(curdat[curdat$Pair==p & curdat$switchMin==1,"switchMin"]) /
    length(curdat[curdat$Pair==p & curdat$switchMin!=0,"switchMin"])
  
  minmax[minmax$Pair==p,"maxSwitchProb"]=swMax
  minmax[minmax$Pair==p,"minSwitchProb"]=swMin
}


################################################################################
# SAVE CURDAT INTO EXCEL FILE HERE - make sure that all vars are added before
if (save_data_final) {
  curpath = dirname(dirname(DataDir)) # save in Experiment/Data
  write_xlsx(curdat, path = paste0(curpath,"/jmdData_allPairs.xlsx"),
             col_names = TRUE, format_headers = TRUE)
  # also save info on lost trials etc.
  dataInfo = jmdData_info(curdat)
  write_xlsx(dataInfo, path = paste0(curpath,"/jmdData_Info.xlsx"),
             col_names = TRUE, format_headers = TRUE)
}
################################################################################


# Configure plot parameters
# -------------------------
pd            = position_dodge(0.001)
acc_scale     = list("lim"=c(0,1),"breaks"=seq(0,1, by=0.2))
acc_scale2    = list("lim"=c(0,0.85),"breaks"=seq(0,0.85, by=0.1)) # for mean values up to ~0.8
target_scale  = list("breaks"=sort(unique(curdat$targetContrast)),"labels"=sort(unique(curdat$targetContrast)))
conf_scale    = list("lim"=c(1,6),"breaks"=seq(1,6, by=1)) #"labels"=c(1,2,3,4,5,6))
conf_scale2   = list("lim"=c(1,4.5),"breaks"=seq(1,4.5, by=1)) # for mean values up to ~4
conf_scale4   = list("lim"=c(1,4),"breaks"=seq(1,4, by=1)) # for mean values up to ~4
time_scale    = list("lim"=c(0,2),"breaks"=seq(0,2, by=0.25))
mov_scale     = list("lim"=c(0.5,1.75),"breaks"=seq(0.5,1.75, by=0.25))
switch_colors = c("lightcoral", "lightgreen")
bar_colors    = c("gray88", "gray44", "lightcoral", "lightgreen")
con_colors    = c("#D1E5F0", "#92C5DE", "#4393C3", "#2166AC")
con_scale     = list("lim"=c(0,125),"breaks"=seq(0,125, by=25))
col_12C       = RColorBrewer::brewer.pal(5, "Paired")[3:5] # light green,dark green,light red
col_mimaC     = RColorBrewer::brewer.pal(5, "Paired")[c(2,1,5)] # light green,dark green,light red


# Initial checks on confidence distribution, target choice and accuracy
# ---------------------------------------------------------------------
# 1. confidence distribution: all levels (1-6) used equally? (on average)
# 2. accuracy as a function of confidence / target contrast (correlations expected)
# 3. target1/target2 distribution: left/right bias (on average and per participant)


# 0. check distribution per pair and agent (use separate function)
check_confDistribution(curdat)

# 1. Confidence distribution - HISTOGRAMS
all_conf = curdat[,c("Pair","confidence1","confidence2","Coll_conf","targetContrast")]
names(all_conf)[names(all_conf)=='confidence1'] <- 'Confidence 1st decision'
names(all_conf)[names(all_conf)=='confidence2'] <- 'Confidence 2nd decision'
names(all_conf)[names(all_conf)=='Coll_conf']   <- 'Confidence collective decision'
all_conf$targetContrast = as.factor(all_conf$targetContrast)
count_scale_conftar     = list("lim"=c(0,200),"breaks"=seq(0,200, by=25))
count_scale_conf        = list("lim"=c(0,700),"breaks"=seq(0,700, by=50))

for(confy in (seq(2,ncol(all_conf)-1))) { # take columns 2-4 in all_conf
  var_conf = all_conf[,confy] # confy=confidence1,confidence2,Coll_Conf
  # plot confidence count split by target contrast
  print(ggplot(all_conf, aes(x=var_conf, fill=targetContrast)) +
          scale_fill_manual(values=con_colors)+ 
          stat_count(geom = "bar", position="dodge2") +
          scale_y_continuous(limits = count_scale_conftar$lim, breaks = count_scale_conftar$breaks) +
          scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
          ggtitle(colnames(all_conf)[confy]) +
          ylab("Count") + xlab("Confidence level") + theme_custom())
  # save the plot
  if (save_plots) {ggsave(file=sprintf(paste0("%sConfidenceHist_",as.character(confy-1),"_target.png"),PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
  
  # plot confidence count
  print(ggplot(all_conf, aes(x=var_conf)) +
          stat_count(geom = "bar", position="dodge2") +
          scale_y_continuous(limits = c(0,600), breaks = seq(0,600, by=50)) +
          #scale_y_continuous(limits = count_scale_conf$lim, breaks = count_scale_conf$breaks) +
          scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
          ggtitle(colnames(all_conf)[confy]) +
          ylab("Count") + xlab("Confidence level") + theme_custom())
  # print the confidence means in the console (! CHANGE ! values not computed correctly!)
  # print(sprintf("Average %s%s %.2f", colnames(all_conf)[confy], ":", round(mean(all_conf[,confy]),2)))
  # print(sprintf("SD %s%s %.2f", colnames(all_conf)[confy], ":", round(sd(all_conf[,confy]),2)))
  # save the plot
  if (save_plots) {ggsave(file=sprintf(paste0("%sConfidenceHist_",as.character(confy-1),".png"),PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
}


# 2. Accuracy by confidence/target contrast

# preparatory steps
# plot titles
dec_names = c("1st decision","2nd decision","Collective decision") 
# column names
p = "Pair"; ag = "agree"; sw = "switch"; Bconf = "B_conf"; Yconf = "Y_conf"
agent1 = "AgentTakingFirstDecision"; agent2 = "AgentTakingSecondDecision"

# 2.0 Average accuracy per decision (1st, 2nd, coll)
# --------------------------------------------------
threeCol     = col_12C
data_all_acc = curdat[,c("Pair","accuracy1","accuracy2","Coll_acc")]
# transform into long format
data_all_acc_long = melt(data_all_acc, id="Pair")
# SUMMARY STATS per PAIR
data_all_acc_sub  = summarySE(data_all_acc_long,measurevar="value",groupvars=c("Pair","variable"))
# SUMMARY STATS across PAIRS
data_all_acc_sum  = summarySE(data_all_acc_sub,measurevar="value",groupvars="variable")
ggplot(data_all_acc_sum,aes(x=variable,y = value)) +
  geom_point(data=data_all_acc_sum, aes(y = value, color = threeCol),alpha=0.9, size=3) + 
  scale_color_manual(values = threeCol) +
  geom_errorbar(aes(x=variable, ymin=value-se, ymax=value+se, color = threeCol,), width=0.2, alpha=0.9, size=1) +
  geom_hline(yintercept=0.5, linetype='dashed', col = 'limegreen', size=1.4, alpha=0.6) +
  scale_x_discrete(labels = c("1st","2nd","Collective")) +
  scale_y_continuous(limits = c(0.5,1), breaks = seq(0.5,1, by=0.1)) +
  ggtitle("Accuracy by decision") +
  ylab("Accuracy") + xlab("Decision") + theme_custom()
if (save_plots) {ggsave(file=sprintf("%sAccPerDec.png",PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}

# 2a. Accuracy as function of confidence
# --------------------------------------
# Note: this is a big for-loop going through all 3 decisions and ag/disag(switch/noswitch)
for(confVar in 1:3) {
  
  if (confVar==1){
    conf="confidence1"; acc="accuracy1"
  }else if (confVar==2) {
    conf="confidence2"; acc="accuracy2"
  }else if (confVar==3) {
    conf="Coll_conf";   acc="Coll_acc"
  }
  
  all_conf_acc        = curdat[,c(p,acc,conf)]
  all_conf_acc_sub    = summarySE(all_conf_acc,measurevar=acc,groupvars=c(p,conf))
  all_conf_acc_sum    = summarySE(all_conf_acc_sub,measurevar=acc,groupvars=c(conf))
 
  print(ggplot(all_conf_acc_sum) +
          geom_bar( aes(x=get(conf), y=get(acc)), stat="identity", fill="grey", alpha=0.7) +
          geom_errorbar( aes(x=get(conf), ymin=get(acc)-se, ymax=get(acc)+se), width=0.2, colour="black", alpha=0.9, size=1)+
          geom_hline(yintercept=0.5, linetype='dashed', col = 'limegreen', size=1.4, alpha=0.6) +
          scale_y_continuous(limits = acc_scale$lim, breaks = acc_scale$breaks) +
          scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
          ggtitle(dec_names[confVar]) +
          ylab("Accuracy") + xlab("Confidence") + theme_custom())
  if (save_plots) {ggsave(file=sprintf(paste0("%sConfidenceAcc_",as.character(confVar),".png"),PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
  
  # add agreement factor to the original bar plots
  data_ag     = curdat[,c(p,acc,conf,ag)]
  data_sub_ag = summarySE(data_ag,measurevar=acc,groupvars=c(p,conf,ag))
  data_sum_ag = summarySE(data_sub_ag,measurevar=acc,groupvars=c(conf,ag))
  # factorize and rename
  data_sum_ag$agree = as.factor(data_sum_ag$agree)
  levels(data_sum_ag$agree)= c("disagree","agree")
  names(data_sum_ag)[names(data_sum_ag)=="agree"]="Agreement"
  
  print(ggplot(data_sum_ag, aes(x = get(conf), y = get(acc), colour = Agreement)) +
          geom_point(position = position_dodge(width = 0.2), alpha=0.9, size=4)+
          geom_errorbar(aes(x=get(conf), ymin=get(acc)-se, ymax=get(acc)+se, colour = Agreement),
                        position = position_dodge(width = 0.2), width=0.2, alpha=0.9, size=1)+
          geom_hline(yintercept=0.5, linetype='dashed', col = 'limegreen', size=1.4, alpha=0.6) +
          scale_y_continuous(limits = acc_scale$lim, breaks = acc_scale$breaks) +
          scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
          ggtitle(dec_names[confVar]) +
          ylab("Accuracy") + xlab("Confidence") + theme_custom())
  if (save_plots) {ggsave(file=sprintf(paste0("%sConfidenceAcc_",as.character(confVar),"_agdag.png"),PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
 
  # now create scatter plots, one dot per agent per confidence level
  if(confVar==1 | confVar==3){
    data_agent = curdat[,c(p,agent1,acc,conf,ag,sw)]
    names(data_agent)[names(data_agent)==agent1] = "agent"
    data_sum_agent = summarySE(data_agent,measurevar=acc,groupvars=c(p,"agent",conf))
  }else if (confVar==2){
    data_agent = curdat[,c(p,agent2,acc,conf,ag,sw)]
    names(data_agent)[names(data_agent)==agent2] = "agent"
    data_sum_agent = summarySE(data_agent,measurevar=acc,groupvars=c(p,"agent",conf))
  }
  
  print(ggplot(data_sum_agent, aes(x=get(acc), y=get(conf), color=interaction(as.factor(agent),as.factor(get(p))))) + 
          geom_point(shape=1) + scale_colour_discrete() + 
          scale_x_continuous(limits = c(0.2,1), breaks = acc_scale$breaks) +
          scale_y_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
          ggtitle(dec_names[confVar]) +
          xlab("Accuracy") + ylab("Confidence") + theme_custom() +
          geom_smooth(method=lm,se=FALSE, size=0.5))
  if (save_plots) {ggsave(file=sprintf(paste0("%sConfAcc_",as.character(confVar),"_agents.png"),PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
  
  
  # create separate plots for agreement and disagreement (+switch) trials
  for(agVar in 1:2) {
    
    # agreement
    if (agVar==1)    {  
      data_sum_p_ag = summarySE(data_agent,measurevar=acc,groupvars=c(p,"agent",conf,ag));
      data_sum_p_ag = data_sum_p_ag[data_sum_p_ag$agree==1,]; alab="agree"
      print(ggplot(data_sum_p_ag, aes(x=get(acc), y=get(conf), color=interaction(as.factor(agent),as.factor(get(p))))) + 
              geom_point(shape=1) + scale_colour_discrete() + 
              scale_x_continuous(limits = c(0.2,1), breaks = acc_scale$breaks) +
              scale_y_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
              ggtitle(paste(dec_names[confVar],alab,sep=" ")) +
              xlab("Accuracy") + ylab("Confidence") + theme_custom() +
              geom_smooth(method=lm,se=FALSE, size=0.5))
      if (save_plots) {ggsave(file=sprintf(paste0("%sConfAcc_",as.character(confVar),"_agents_agree.png"),PlotDir), 
                              dpi = 300, units=c("cm"), height =20, width = 20)}
    }
    # disagreement
    else if (agVar==2) {
      # decisions 1 and 2
      if (confVar==1 || confVar==2) {
        data_sum_p_ag = summarySE(data_agent,measurevar=acc,groupvars=c(p,"agent",conf,ag));
        data_sum_p_ag = data_sum_p_ag[data_sum_p_ag$agree==-1,]; alab="disagree"
        print(ggplot(data_sum_p_ag, aes(x=get(acc), y=get(conf), color=interaction(as.factor(agent),as.factor(get(p))))) +
                geom_point(shape=1) + scale_colour_discrete() +
                scale_x_continuous(limits = c(0.2,1), breaks = acc_scale$breaks) +
                scale_y_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
                ggtitle(paste(dec_names[confVar],alab,sep=" ")) +
                xlab("Accuracy") + ylab("Confidence") + theme_custom() +
                geom_smooth(method=lm,se=FALSE, size=0.5))
        if (save_plots) {ggsave(file=sprintf(paste0("%sConfAcc_",as.character(confVar),"_agents_disagree.png"),PlotDir), 
                                dpi = 300, units=c("cm"), height =20, width = 20)}
      }
      # collective decision: split into switch and no switch
      else if (confVar==3) {
        for(swVar in 1:2) {
          data_sum_p_ag = summarySE(data_agent,measurevar=acc,groupvars=c(p,"agent",conf,ag,sw));
          if (swVar==1){
            data_sum_p_ag=data_sum_p_ag[data_sum_p_ag$agree==-1 & data_sum_p_ag$switch==1,]; alab="disagree&change"
          }else if (swVar==2){
            data_sum_p_ag=data_sum_p_ag[data_sum_p_ag$agree==-1 & data_sum_p_ag$switch==-1,]; alab="disagree&nochange"
          }
          
          print(ggplot(data_sum_p_ag, aes(x=get(acc), y=get(conf), color=interaction(as.factor(agent),as.factor(get(p))))) + 
                  geom_point(shape=1) + scale_colour_discrete() + 
                  scale_x_continuous(limits = c(0.2,1), breaks = acc_scale$breaks) +
                  scale_y_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
                  ggtitle(paste(dec_names[confVar],alab,sep=" ")) +
                  xlab("Accuracy") + ylab("Confidence") + theme_custom() +
                  geom_smooth(method=lm,se=FALSE, size=0.5))
          if (save_plots) {ggsave(file=sprintf(paste0("%sConfAcc_",as.character(confVar),"_agents_disagree_",as.character(swVar),".png"),PlotDir), 
                                  dpi = 300, units=c("cm"), height =20, width = 20)}
        }
      }
    }
  }
}


#####################################################
#### FOCUS ON CONFIDENCE - ACCURACY RELATIONSHIP ####
# 2b. Conf/Acc as function of difficulty (target contrast)
# --------------------------------------------------------
# First plot all three decisions into the same plot

# Sub-select? if so: agreement or disagreement trials?
subselect     = 0; # 1=yes,   0=no
sub_agreement = 1; # 1=agree, 0=disagree 
# Which decision types to plot?
dec2plot      = 2; # 1=1st/2nd/coll, 2=max,min,coll
# Prepare data set accordingly
if (subselect) {
  if (sub_agreement) {
    at        = curdat[curdat$agree==1,]
    data_coac = at[,c("Pair","targetContrast",
                      "B_conf","B_acc","Y_conf","Y_acc","maxConf","maxAcc","minConf","minAcc",
                      "confidence1","confidence2","Coll_conf","accuracy1", "accuracy2", "Coll_acc")]
    agree_lab = '_agree'; agree_title = '- agreement'; 
  } else {
    dt        = curdat[curdat$agree==-1,]
    data_coac = dt[,c("Pair","targetContrast",
                      "B_conf","B_acc","Y_conf","Y_acc","maxConf","maxAcc","minConf","minAcc",
                      "confidence1","confidence2","Coll_conf","accuracy1", "accuracy2", "Coll_acc")]
    agree_lab = '_disagree'; agree_title = '- disagreement';
  }
} else {
  data_coac = curdat[,c("Pair","targetContrast",
                        "B_conf","B_acc","Y_conf","Y_acc","maxConf","maxAcc","minConf","minAcc",
                        "confidence1","confidence2","Coll_conf","accuracy1", "accuracy2", "Coll_acc")]
  agree_lab = ''; agree_title = '';
}

# transform data_coac into long format
data_coac_long = melt(data_coac, id=c("Pair", "targetContrast"))
# compute SUMMARY statistics, PER PAIR
data_coac_sum  = summarySE(data_coac_long,measurevar="value",groupvars=c("Pair","targetContrast","variable"))

# create separate data subsets for confidence and accuracy
if (dec2plot==1) {
  data_co = data_coac_sum[data_coac_sum$variable=="confidence1" | data_coac_sum$variable=="confidence2" | data_coac_sum$variable=="Coll_conf",]
  data_ac = data_coac_sum[data_coac_sum$variable=="accuracy1" | data_coac_sum$variable=="accuracy2" | data_coac_sum$variable=="Coll_acc",]
  threeCol= col_12C; dec_lab = '_12'; 
} else {
  data_co = data_coac_sum[data_coac_sum$variable=="maxConf" | data_coac_sum$variable=="minConf" | data_coac_sum$variable=="Coll_conf",]
  data_ac = data_coac_sum[data_coac_sum$variable=="maxAcc" | data_coac_sum$variable=="minAcc" | data_coac_sum$variable=="Coll_acc",]
  threeCol= col_mimaC; dec_lab = '_mima';
}

# filter subsets to avoid having value = 0 in denominator of caR (happens if only 1 value for accuracy)
data_ac_filt = data_ac[data_ac$value>0,]
data_co_filt = data_co[data_ac$value>0,]
# create C-A ratio data set, based on data_co and data_ac
data_caR     = data_co_filt
data_caR$caR = data_co_filt$value/data_ac_filt$value # compute ratio per row

# change variable names in caR
data_caR$variable=factor(data_caR$variable)
if (dec2plot==1) {
  levels(data_caR$variable)=c("decision1","decision2","decisionColl")
} else {
  levels(data_caR$variable)=c("decisionMax","decisionMin","decisionColl")
}

# compute SUMMARY statistics, ACROSS PAIRS
data_caR_sum = summarySE(data_caR,measurevar="caR",groupvars=c("targetContrast","variable")) 
data_co_sum  = summarySE(data_co_filt,measurevar="value",groupvars=c("targetContrast","variable")) 
data_ac_sum  = summarySE(data_ac_filt,measurevar="value",groupvars=c("targetContrast","variable")) 

# 1. plot CONFIDENCE by target contrast for all 3 decision types (within one plot)
ggplot(data_co_sum, aes(x = targetContrast, y = value)) + 
  geom_line(data=data_co_sum, aes(y = value, color = variable), lwd = .7) + 
  geom_point(data=data_co_sum, aes(y = value, color = variable)) +
  scale_color_manual(values = threeCol) + 
  geom_ribbon(data=data_co_sum, aes(ymin = value-se, ymax = value+se, fill = variable),
              alpha = .3, color = "transparent") +
  scale_fill_manual(values = threeCol) + 
  xlim(0.115, 0.250) + ylim(2.0,4.75) +
  ggtitle(paste("Individual and collective confidence",agree_title)) +
  labs(x = "Target contrast", y = "Confidence") + theme_custom()
if (save_plots) {ggsave(file=sprintf(paste0("%sallDec_ConfByContrast",dec_lab,agree_lab,".png"),PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}

# 2. plot ACCURACY by target contrast for all 3 decision types (within one plot)
ggplot(data_ac_sum, aes(x = targetContrast, y = value)) +
  geom_line(data=data_ac_sum, aes(y = value, color = variable), lwd = .7) + 
  geom_point(data=data_ac_sum, aes(y = value, color = variable)) + 
  scale_color_manual(values = threeCol) +
  geom_ribbon(data=data_ac_sum, aes(ymin = value-se, ymax = value+se, fill = variable),
              alpha = .3, color = "transparent") +
  scale_fill_manual(values = threeCol) +
  xlim(0.115, 0.250) + ylim(0.3,1) +
  ggtitle(paste("Individual and collective accuracy",agree_title)) +
  labs(x = "Target contrast", y = "Accuracy") + theme_custom()
if (save_plots) {ggsave(file=sprintf(paste0("%sallDec_AccByContrast",dec_lab,agree_lab,".png"),PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}

# 3. plot C-A RATIO by target contrast for all 3 decision types (within one plot)
ggplot(data_caR_sum, aes(x = targetContrast, y = caR)) +
  geom_line(data=data_caR_sum, aes(y = caR, color = variable), lwd = .7) + 
  geom_point(data=data_caR_sum, aes(y = caR, color = variable)) +
  scale_color_manual(values = threeCol) +
  geom_ribbon(data=data_caR_sum, aes(ymin = caR-se, ymax = caR+se, fill = variable),
              alpha = .3, color = "transparent")+
  scale_fill_manual(values = threeCol) +
  xlim(0.115, 0.250) + ylim(3,9.5) +
  ggtitle(paste("Individual and collective CA-ratio",agree_title)) +
  labs(x = "Target contrast", y = "Confidence/Accuracy") + theme_custom()
if (save_plots) {ggsave(file=sprintf(paste0("%sallDec_ConfRContrast",dec_lab,agree_lab,".png"),PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


###############
# RUN MIN-MAX COMPARISON with function compareMinMax
# IMPORTANT: the function uses data_co_sum from above - before running the following,
# make sure that subselect=0 and dec2plot=2

# Decide if you want to include collective decision (as var) and targetContrast (as factor)
wCollconf = 0 # 0=without collective, 1=with collective
wtarget   = 1 # 0=average across targets, 1=target as factor
# now run function
compareMinMax(wCollconf,wtarget,data_co_sum)
###############


# 3. LEFT-RIGHT RESPONSE BIAS? (plot this as function of confidence?)
PlotDirLR = paste0(PlotDir,"TargetChoice/") # save plots in separate folder
# factorize and name levels
curdat$decision1=as.factor(curdat$decision1)
levels(curdat$decision1)= c("left","right")
curdat$decision2=as.factor(curdat$decision2)
levels(curdat$decision2)= c("left","right")
curdat$Coll_decision=as.factor(curdat$Coll_decision)
levels(curdat$Coll_decision)= c("left","right")
curdat$B_decision=as.factor(curdat$B_decision)
levels(curdat$B_decision)= c("left","right")
curdat$Y_decision=as.factor(curdat$Y_decision)
levels(curdat$Y_decision)= c("left","right")
# create all_dec selection
all_dec = curdat[,c("Pair","AgentTakingFirstDecision","B_decision","Y_decision",
                    "decision1","decision2","Coll_decision","targetContrast")]
names(all_dec)[names(all_dec)=='decision1']     <- 'Target choice 1st decision'
names(all_dec)[names(all_dec)=='decision2']     <- 'Target choice 2nd decision'
names(all_dec)[names(all_dec)=='Coll_decision'] <- 'Target choice collective decision'
all_dec$targetContrast = as.factor(all_dec$targetContrast)

# plot target choice count (left/right) split by target contrast
for(dec in (seq(5,ncol(all_dec)-1))) {
  var_dec = all_dec[,dec] # dec=decision1,decision2,Coll_decision
  
  print(ggplot(all_dec, aes(x=var_dec, fill=targetContrast)) +
          scale_fill_manual(values=con_colors)+ 
          stat_count(geom = "bar", position="dodge2") +
          #scale_y_continuous(limits = count_scale_conftar$lim, breaks = count_scale_conftar$breaks) +
          ggtitle(colnames(all_dec)[dec]) +
          ylab("Count") + xlab("Decision") + theme_custom())
  if (save_plots) {ggsave(file=sprintf(paste0("%sLRChoice_",as.character(dec-4),".png"),PlotDirLR), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
}

# plot target choice (left/right) split by target contrast BY PAIR
for (p in unique(all_dec$Pair)) { # p = pair
    for (dec in (seq(5,ncol(all_dec)-1))) { # dec=decision1,decision2,Coll_decision
    var_dec = all_dec[all_dec$Pair==p,dec] 
   
    print(ggplot(all_dec[all_dec$Pair==p,], aes(x=var_dec, fill=targetContrast)) +
            scale_fill_manual(values=con_colors)+ 
            stat_count(geom = "bar", position="dodge2") +
            #scale_y_continuous(limits = count_scale_conftar$lim, breaks = count_scale_conftar$breaks) +
            ggtitle(paste(colnames(all_dec)[dec], "Pair", as.character(p))) +
            ylab("Count") + xlab("Decision") + theme_custom())
    if (save_plots) {ggsave(file=sprintf(paste0("%sLRChoice_",as.character(p),"_",as.character(dec-4),".png"), PlotDirLR), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
  }
}

# plot target choice (left/right) split by target contrast BY AGENT
for (p in unique(all_dec$Pair)) { # p = pair
  for (agent in unique(all_dec$AgentTakingFirstDecision)) { # agent=B,Y
    
    if (agent=="B") {dec="B_decision"
    } else {dec="Y_decision"}
    
    var_dec = all_dec[all_dec$Pair==p,dec] 
    
    print(ggplot(all_dec[all_dec$Pair==p,], aes(x=var_dec, fill=targetContrast)) +
            scale_fill_manual(values=con_colors)+ 
            stat_count(geom = "bar", position="dodge2") +
            #scale_y_continuous(limits = count_scale_conftar$lim, breaks = count_scale_conftar$breaks) +
            ggtitle(paste("Pair", as.character(p), "Agent", agent)) +
            ylab("Count") + xlab("Decision") + theme_custom())
    # save the plot
    if (save_plots) {ggsave(file=sprintf(paste0("%sLRChoice_",as.character(p),"_",agent,".png"), PlotDirLR), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
  }
}


# Check PROPORTIONS: high/low confidence, agreement/disagreement, switch/no switch
# --------------------------------------------------------------------------------
# count trials separately for each agent B /Y for low and high confidence
lo_conf_trialcount_B = dim(curdat[(curdat$B_conf>=1 & curdat$B_conf<=3),])[1]
lo_conf_trialcount_Y = dim(curdat[(curdat$Y_conf>=1 & curdat$Y_conf<=3),])[1]
lo_conf_trialcount   = lo_conf_trialcount_B+lo_conf_trialcount_Y
hi_conf_trialcount_B = dim(curdat[(curdat$B_conf>3),])[1]
hi_conf_trialcount_Y = dim(curdat[(curdat$Y_conf>3),])[1]
hi_conf_trialcount   = hi_conf_trialcount_B+hi_conf_trialcount_Y
# divide by total trial number*2 (because each agent took 1 ind. dec. per trial)
lo_conf_perc         = round(100*(lo_conf_trialcount/(2*(dim(curdat)[1]))))
hi_conf_perc         = round(100*(hi_conf_trialcount/(2*(dim(curdat)[1]))))
sprintf("Low confidence decisions (1-3): %d %s", lo_conf_perc, "%")
sprintf("High confidence decisions (4-6): %d %s", hi_conf_perc, "%")

# Sub-select agreement/disagreement trials
at = curdat[curdat$agree==1,]
dt = curdat[curdat$agree==-1,]

# check correlation between confidence of A1 and A2, for all/agree,disagree
# XXX this should be done on pair level!!?
plot(jitter(curdat$confidence2,2) ~ jitter(curdat$confidence1,2),
     main = "Relation of Conf1 and Conf2",xlab="Confidence1",ylab="Confidence2")
abline(lm(confidence2 ~ confidence1, data = curdat), col = "blue")
plot(jitter(dt$confidence2,2) ~ jitter(dt$confidence1,2),
     main = "Disagree: Relation of Conf1 and Conf2",xlab="Confidence1",ylab="Confidence2")
abline(lm(confidence2 ~ confidence1, data = dt), col = "blue")
plot(jitter(at$confidence2,2) ~ jitter(at$confidence1,2),
     main = "Agree: Relation of Conf1 and Conf2",xlab="Confidence1",ylab="Confidence2")
abline(lm(confidence2 ~ confidence1, data = at), col = "blue")
plot(jitter(curdat$Coll_conf,2) ~ jitter(curdat$confidence1,2),
     main = "Relation of Conf1 and collConf",xlab="Confidence1",ylab="collConfidence")
abline(lm(Coll_conf ~ confidence1, data = curdat), col = "blue")
plot(jitter(curdat$Coll_conf,2) ~ jitter(curdat$confidence1-curdat$confidence2,2),
     main = "Relation of Conf2-Conf1 and collConf",xlab="Confidence2-Confidence1",ylab="collConfidence")
abline(lm(Coll_conf ~ (confidence2-confidence1), data = curdat), col = "blue")


# Plot disagreement according to target contrast
# agreement: 1=agreement, -1=disagreement; contrasts = c(0.115, 0.135, 0.170, 0.250)
# (for a quick check, just do hist(at$targetContrast))
contrastData_all  = curdat[,c('Pair','targetContrast','agree','switch')]

# XXX for indi=1, create loop to run through all pairs
contrastData_indi = contrastData_all[contrastData_all$Pair==124,] # select pair
indi = 0; # select whether to plot aggregate or individual data ((indi=0 vs. indi=1)

if (indi==1) {
  contrastD      = contrastData_indi
  count_scale    = list("lim"=c(0,40),"breaks"=seq(0,40, by=10))
  count_scale_dt = list("lim"=c(0,20),"breaks"=seq(0,20, by=5))
} else {
  contrastD = contrastData_all
  count_scale = list("lim"=c(0,425),"breaks"=seq(0,425, by=25))
  count_scale_dt = list("lim"=c(0,150),"breaks"=seq(0,150, by=20))
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
if (save_plots) {ggsave(file=paste0(PlotDir,"hist_agree_contrast.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}
# plot switch as a function of target contrast (only disagreement!)
contrastD_dt = contrastD[contrastD$agree=="disagree",]
ggplot(contrastD_dt, aes(x=contrastD_dt$targetContrast, fill=contrastD_dt$switch)) +
  stat_count(geom = "bar", position="dodge2") + scale_fill_manual(values=switch_colors) +
  scale_y_continuous(limits = count_scale_dt$lim, breaks = count_scale_dt$breaks) +
  scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
  xlab("Target contrasts") + ylab("Count") + theme_custom()
if (save_plots) {ggsave(file=paste0(PlotDir,"hist_contrast_switch_dt.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}

# Percentage of (dis)agreement trials relative to all trials
perc_dt = round(100*(dim(dt)[1]/dim(curdat)[1])) #40% in exp #39% in pilot
perc_at = round(100*(dim(at)[1]/dim(curdat)[1])) #60% in exp #61% in pilot
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



# PLOT OVERVIEW
#--------------
#1. CONFIDENCE as a function of TARGET CONTRAST
#2. ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH
#3. mean ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH (bar plots)
#4. CONFIDENCE DIFFERENCE for A1 and A2
#5. RT and MT as a function of CONFIDENCE (for 2nd decision only)
#6. RT and MT as a function of TARGET CONTRAST
#7. SWITCH BAR PLOTS - confidence delta as a function of switch


# START PLOTTING
# ------------------------------------------------------------------------------

# 1. CONFIDENCE as a function of TARGET CONTRAST
# 1a. Split by agreement (only A1 and collective decisions)
# ---------------------------------------------------------
# XXX CHANGE SUMMARY STATS HERE: first average across pairs XXX
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
if (save_plots) {ggsave(file=paste0(PlotDir,"conf_agree",".png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# 1b. Split by agreement and accuracy (only collective decision)
# ------------------------------------------------------------------------------
# XXX CHANGE SUMMARY STATS HERE: first average across pairs XXX
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
if (save_plots) {ggsave(file=paste0(PlotDir,"conf_agree_acc_coll",".png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# 2. ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH
# 2a. Accuracy split by agreement and switch (only A1 and collective decisions)
# ------------------------------------------------------------------------------
# XXX CHANGE SUMMARY STATS HERE: first average across pairs XXX
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
if (save_plots) {ggsave(file=paste0(PlotDir,"acc_agree_switch.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# 2b. Confidence split by agreement and switch (only A1 and collective decisions)
# -------------------------------------------------------------------------------
# XXX CHANGE SUMMARY STATS HERE: first average across pairs XXX
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
if (save_plots) {ggsave(file=paste0(PlotDir,"conf_agree_switch.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# 3. mean ACCURACY AND CONFIDENCE as a function of AGREEMENT / SWITCH (bar plots)
# 3a. Accuracy split by agreement and switch (only A1 and collective decisions)
# -------------------------------------------------------------------------------
# prep accuracy bars
# XXX CHANGE SUMMARY STATS HERE: first average across pairs XXX
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
  geom_errorbar(data=csaAcc_data, mapping=aes(x=variable, ymin=value-se, ymax=value+se), 
                size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
  facet_grid(. ~ as.factor(switch)) +
  scale_y_continuous(limits = acc_scale2$lim, breaks=acc_scale2$breaks)+
  xlab("Decision") + ylab("Accuracy") + 
  theme(panel.grid.major = element_line(color = "black", size = .5),
        panel.grid.minor = element_line(color = "black", size = .25),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
if (save_plots) {ggsave(file=paste0(PlotDir,"Accuracy_Agree+Switch.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 30)}


# 3b. Confidence split by agreement and switch (only A1 and collective decisions)
# -------------------------------------------------------------------------------
# x-axis: individual/collective
# color:  agree/disagree
# panels: switch/no switch
# bars:   light gray (agree) vs. dark gray (disagree)
# panels: green (switch) vs. red (no switch)

# prep confidence bars
# XXX CHANGE SUMMARY STATS HERE: first average across pairs XXX
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
  geom_errorbar(data=csa_data, mapping=aes(x=variable, ymin=value-se, ymax=value+se), 
                size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
  facet_grid(. ~ as.factor(switch)) + # separate facets for switch / no switch
  scale_y_discrete(limits = factor(conf_scale2$breaks), breaks=conf_scale2$breaks) +
  xlab("Decision") + ylab("Confidence") + 
  theme(panel.grid.major = element_line(color = "black", size = .5),
        panel.grid.minor = element_line(color = "black", size = .25),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
if (save_plots) {ggsave(file=paste0(PlotDir,"Confidence_Agree+Switch.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 30)}


# 4. CONFIDENCE DIFFERENCE for A1 and A2
# ------------------------------------------------------------------------------
# Show confidence for both individual decisions (A1 and A2).
# Plot per pair, separate plots for switch/no switch. Only disagreement trials.

if(pair_plots){
  coll = FALSE # include also the collective decision? xxx check if these work
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
    if (save_plots) {ggsave(file=sprintf(paste0("%sconf_noSwitch_disagree ",as.character(p),coll_lab,".png"),PlotDir), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
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
    if (save_plots) {ggsave(file=sprintf(paste0("%sconf_Switch_disagree ",as.character(p),coll_lab,".png"),PlotDir), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
  }
}


# 5. RT and MT as a function of CONFIDENCE (for 2nd decision only!!!)
# ---------------------------------------------------------------------------------------------------------------------
# "B_rt" / "Y_rt" (previously "A1_rt" / "A2_rt") refer to RT calculated for each agent during acquisition (same for mt). 
# When we cut the trials, we re-calculated rt and mt for each decision ("rt_final1" and "rt_final2").
# The new calculation is based on a velocity threshold: from now, we will use this final rt/mt. 
# NOTE: The variables are related to the rt of the 1st and 2nd decision respectively (not to the agent).

# XXX work on this for collective RT XXX check if summary stats are okay (need to include pair!?)

# rt 2nd decision - calc the average, se, ci
rt_conf_2d                = curdat[,c("confidence2","rt_final2")]
rt_conf_2d_sum            = summarySE(rt_conf_2d,measurevar="rt_final2",groupvars=c("confidence2"))
# rt_conf_2d                = curdat[,c("Pair","AgentTakingSecondDecision","confidence2","rt_final2")]
# rt_conf_2d_sum            = summarySE(rt_conf_2d,measurevar="rt_final2",groupvars=c("Pair","AgentTakingSecondDecision","confidence2"))
rt_conf_coll              = curdat[,c("Coll_conf","rt_finalColl")]
rt_conf_coll_sum          = summarySE(rt_conf_coll,measurevar="rt_finalColl",groupvars=c("Coll_conf"))
# mt 2nd decision - calc the average, se, ci
mt_conf_2d                = curdat[,c("confidence2","mt_final2")]
mt_conf_2d_sum            = summarySE(mt_conf_2d,measurevar="mt_final2",groupvars=c("confidence2"))
mt_conf_coll              = curdat[,c("Coll_conf","mt_finalColl")]
mt_conf_coll_sum          = summarySE(mt_conf_coll,measurevar="mt_finalColl",groupvars=c("Coll_conf"))
# rename variables
names(rt_conf_2d_sum)     = c("conf2","N","var","sd","se","ci")
names(mt_conf_2d_sum)     = c("conf2","N","var","sd","se","ci")
mt_rt_conf_2d_sum         = rbind(rt_conf_2d_sum,mt_conf_2d_sum); 
mt_rt_conf_2d_sum$var_lab = c(replicate(length(rt_conf_2d_sum), "rt"),replicate(length(mt_conf_2d_sum), "mt"))
d                         = mt_rt_conf_2d_sum # shorter name for convenience
# for collective
names(rt_conf_coll_sum)   = c("confColl","N","var","sd","se","ci")
names(mt_conf_coll_sum)   = c("confColl","N","var","sd","se","ci")
mt_rt_conf_coll_sum       = rbind(rt_conf_coll_sum,mt_conf_coll_sum); 
mt_rt_conf_coll_sum$var_lab = c(replicate(length(rt_conf_coll_sum), "rt"),replicate(length(mt_conf_coll_sum), "mt"))
dColl                      = mt_rt_conf_coll_sum # shorter name for convenience


# plot - RT and MT as a function of confidence level (across participants)
print(plotSE(df=d,xvar=d$conf2,yvar=d$var,
             colorvar=d$var_lab,shapevar=d$var_lab,
             xscale=conf_scale,yscale=time_scale,titlestr=paste0("MT/RT as a function of confidence (2nd decision) "),
             manual_col=c("grey", "black"),linevar=c("dashed","solid"),sizevar=c(3,3),disco=TRUE) +
        xlab("agent confidence") + ylab("time [s]") + theme_custom())
if (save_plots) {ggsave(file=sprintf(paste0("%stime_conf_2d",".png"),PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}

print(plotSE(df=dColl,xvar=dColl$confColl,yvar=dColl$var,
             colorvar=dColl$var_lab,shapevar=dColl$var_lab,
             xscale=conf_scale,yscale=time_scale,titlestr=paste0("MT/RT as a function of confidence (coll decision) "),
             manual_col=c("grey", "black"),linevar=c("dashed","solid"),sizevar=c(3,3),disco=TRUE) +
        xlab("agent confidence") + ylab("time [s]") + theme_custom())
if (save_plots) {ggsave(file=sprintf(paste0("%stime_conf_coll",".png"),PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# 6. RT and MT as a function of TARGET CONTRAST
# 6a. RT and MT means (across participants)
# ------------------------------------------------------------------------------

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
  if (save_plots) {ggsave(file=sprintf(paste0("%s",lab,"_ave.png"),PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
}

# 6b. RT and MT per pair
# Plots show B, Y, and Collective RT/MT
# ---------------------------------------

# Add 4 columns with rt/mt split by agent
curdat = final_rtmt_byAgent(curdat) # XXX double-check if function is correct!!!

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
  all_pairs=levels(all$Pair)
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
    if (save_plots) {ggsave(file=sprintf(paste0("%s",as.character(g),"_",lab,"_ave.png"),PlotDir), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
  }
}


# 7. Confidence delta as a function of switch
# ------------------------------------------------------------------------------

# add confidence deltas to long format (only disagreement trials) without coll.
# XXX CHANGE SUMMARY STATS HERE: first average across pairs XXX
dt_long_delta = melt(dt[,c("Pair","deltaC2C1","switch")], id=c("Pair","switch"))
switch_sum  = summarySE(dt_long_delta,measurevar="value",groupvars=c("switch","variable"))
# check only for A1 confidence
dt_long_C1 = melt(dt[,c("Pair","confidence1","switch")], id=c("Pair","switch"))
switchC1_sum  = summarySE(dt_long_C1,measurevar="value",groupvars=c("switch","variable"))

# change factor level names
switch_sum$switch = as.factor(switch_sum$switch)
levels(switch_sum$switch) = c("No switch","Switch")
switch_sum$switch <- factor(switch_sum$switch, levels = c("Switch","No switch")) # change order
switch_sum$variable = as.factor(switch_sum$variable)
levels(switch_sum$variable) = c("Conf. 2 - Conf. 1")
# same for A1 confidence
switchC1_sum$switch = as.factor(switchC1_sum$switch)
levels(switchC1_sum$switch) = c("No switch","Switch")
switchC1_sum$switch <- factor(switchC1_sum$switch, levels = c("Switch","No switch")) # change order
switchC1_sum$variable = as.factor(switchC1_sum$variable)
levels(switchC1_sum$variable) = c("Confidence 1")

# scale for confidence delta
delta_scale = list("lim"=c(-2,1),"breaks"=seq(-2,1, by=0.5))
C1_scale = list("lim"=c(0,6),"breaks"=seq(0,6, by=0.5))
# colors
delta_color = c("gray")

# variable = confidence delta 
print(ggplot(data=switch_sum, aes(x=switch, y=value, fill=variable, color = variable)) +
        ggtitle("Switching as a function of confidence delta (only disagreement)") +
        geom_bar(stat="identity", position="dodge", alpha = 0.5, color = "black") +
        scale_fill_manual(values=delta_color) +
        geom_errorbar(aes(ymin=value-se, ymax=value+se), size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
        scale_y_continuous(limits = delta_scale$lim, breaks=delta_scale$breaks) +
        xlab("Switching") + ylab("Confidence delta") + 
        theme(legend.position = "none") + theme_custom())
if (save_plots) {ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_Switching.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}
# variable = confidence 1
print(ggplot(data=switchC1_sum, aes(x=switch, y=value, fill=variable, color = variable)) +
        ggtitle("Switching as a function of confidence delta (only disagreement)") +
        geom_bar(stat="identity", position="dodge", alpha = 0.5, color = "black") +
        scale_fill_manual(values=delta_color) +
        geom_errorbar(aes(ymin=value-se, ymax=value+se), size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
        scale_y_continuous(limits = C1_scale$lim, breaks=C1_scale$breaks) +
        xlab("Switching") + ylab("Confidence 1") + 
        theme(legend.position = "none") + theme_custom())
if (save_plots) {ggsave(file=paste0(PlotDir,"Conf1_Switching.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# COLLECTIVE ADJUSTMENT PLOTS (confidence A1 compared to collective confidence)
# ------------------------------------------------------------------------------
sub_switch   = curdat[curdat$switch==1,c("Pair","Trial","agree","switch","accuracy1", 
               "accuracy2","Coll_acc", "confidence2", "Coll_conf","confidence1", "deltaC2C1","deltaCcC1")] # switch
sub_noswitch = curdat[curdat$switch==-1,c("Pair","Trial","agree","switch","accuracy1", 
               "accuracy2","Coll_acc","confidence2", "Coll_conf","confidence1", "deltaC2C1","deltaCcC1")] # no switch
sub_dt       = dt[,c("Pair","Trial","agree","switch","accuracy1", 
               "accuracy2","Coll_acc", "confidence2", "Coll_conf","confidence1", "deltaC2C1","deltaCcC1")] # disagree

#rename and factorize levels
sub_switch$agree = as.factor(sub_switch$agree)
sub_noswitch$agree = as.factor(sub_noswitch$agree)
sub_dt$agree = as.factor(sub_dt$agree)
sub_dt$switch = as.factor(sub_dt$switch)
names(sub_switch) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy", 
                      "Confidence2", "Coll. Confidence","Confidence1", "Conf. 2 - Conf. 1","coll. Conf. - Conf. 1")
names(sub_noswitch) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy",
                        "Confidence2", "Coll. Confidence","Confidence1", "Conf. 2 - Conf. 1","coll. Conf. - Conf. 1")
names(sub_dt) = c("Pair","Trial","Agreement","Switch","Accuracy1", "Accuracy2","coll. Accuracy",
                  "Confidence2", "Coll. Confidence","Confidence1", "Conf. 2 - Conf. 1","coll. Conf. - Conf. 1")
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
if (save_plots) {ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_Disagree.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}

# SWITCH: subjective confidence (switch exists only for disagreement)
print(ggplot(sub_switch, aes(x=sub_switch[,"Conf. 2 - Conf. 1"], y=sub_switch[,"coll. Conf. - Conf. 1"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1))+ 
        stat_smooth(method="lm",se=TRUE) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, switch trials"))
if (save_plots) {ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_Switch.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}

# NO SWITCH: subjective confidence (split by agree/disagree)
print(ggplot(sub_noswitch, aes(x=sub_noswitch[,"Conf. 2 - Conf. 1"], y=sub_noswitch[,"coll. Conf. - Conf. 1"], 
                               color = sub_noswitch[,"Agreement"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1)) + 
        stat_smooth(method="lm",se=TRUE) +
        scale_color_manual(values=c("limegreen","red4")) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("Confidence 2 - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("Conf. 2 - Conf. 1, no switch trials") +
        theme(legend.position = "none"))
if (save_plots) {ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_CollConf_NoSwitch.png"), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# SCRIPT WORKS UP TO HERE (BUT CHECK XXX PARTS AND CORRECT!!!)
################################################################################
# BELOW IS WORK IN PROGRESS

# LINEAR MODEL
# ------------------------------------------------------------------------------
# Quick test on linear models
coll_conf=lmer(Coll_conf ~ confidence1 * switch + confidence2 + (1|interaction(curdat$Pair)), data=curdat)
summary(coll_conf)
# emmeans(coll_conf,pairwise~confidence1|switch)
switch_model1 = lmer(switch ~ confidence1 + (1|interaction(curdat$Pair)), data=curdat)
summary(switch_model1)
switch_model12 = lmer(switch ~ (confidence2-confidence1) + (1|interaction(curdat$Pair)), data=curdat)
summary(switch_model12)
switch_model3 = lmer(switch ~ confidence1 + confidence2 + (1|interaction(curdat$Pair)), data=curdat)
summary(switch_model3)
anova(switch_model1,switch_model3)

# COLLECTIVE AND INDIVIDUAL(COLLECTIVE) BENEFIT
# ------------------------------------------------------------------------------
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
# ggplot(df,aes(y=ind_coll_benefit,x=r2,color=acc))+geom_point()+stat_smooth(method="lm",se=FALSE)
# # ggPredict(fit1,interactive=TRUE)
# 
# # plot(r2,ind_coll_benefit,xlim=c(0,0.5),ylim=c(0,2));abline(fit1)
# # plot(r2,coll_benefit2,xlim=c(0,0.5),ylim=c(0,1.2))


# PATEL (only works with observation data!!!)
# ------------------------------------------------------------------------------
# Do participants who rate observed decisions, on average, as more confident than
# their own also move more slowly than the observed actions?
# The faster agent should rate the observed action as less confident than their own (pCon > iCon). 
# However, all our pilot participants rate the observed action as more confident than their own (pCon < iCon).
# Reference: Patel, D., Fleming, S. M., & Kilner, J. M. (2012). Inferring subjective
# states through the observation of actions.

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
  icon                = rbind(icon_A1,icon_A2); names(icon) = c("pair","var_iCon","N_iCon","iCon","sd_iCon","se_iCon","ci_iCon","agent");
  icon                = icon[,c("var_iCon","N_iCon","iCon","sd_iCon","se_iCon","ci_iCon")];
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
  if (save_plots) {ggsave(file=sprintf(paste0("%sdiff_mt_pCon_iCon",".png"),PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 30)}
}
