# ==============================================================================
# JMD study - CREATING ONE FILE WITH ALL KINEMATIC DATA
# Experiment: conducted in June 2023 @IIT Genova
# Participants: N=32 (16 pairs) - 12 pairs (S119,S110) excluded, so 14 pairs
# Script: written by Laura Schmitz
# ==============================================================================


# Preparatory steps
# -----------------

# Remove variables and plots
rm(list = ls())
graphics.off()

# Save data?
save_data_final_all = 0

# Set path to retrieve Excel files
curDir  = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Analysis/Behavioral analysis/"
fileDir = "E:/DATA/Processed/all_KIN"
saveDir = "C:/Users/Laura/GitHub/JointMotorDecision/Experiment/Data"

# Define necessary packages
pckgs = c("dplyr","readxl","writexl")
# Load all of them and check how many packages failed to load
sum(lapply(pckgs, require, character.only = TRUE)==FALSE)

# Import info about max./min. agent from Excel file (created in Matlab)
minmax <- read_excel("minmaxTable.xlsx")

# Call functions
source(paste0(curDir,'bind_all_excel.R'))


# RETRIEVE DATA and CREATE DATA FRAME
# ------------------------------------------------
# merge Excel files from all pairs into one data frame named "kindat"
kindat = as.data.frame(bind_all_excel(fileDir))

# Add additional vars to the kindat data frame
# --------------------------------------------

# Add a column expressing whether agents B and Y agree in their decisions [1=agreement, -1=disagreement]
kindat$agree                  = as.integer(kindat$B_decision == kindat$Y_decision)
kindat$agree[kindat$agree==0] = -1

# Add columns where decision, confidence, and accuracy are reported per 1st/2nd decision (rather than tied to agent B/Y)

# Initialize variables
decision1 = c(); conf1 = c(); acc1 = c()
decision2 = c(); conf2 = c(); acc2 = c()
# Assign values to variables
for (row in 1:dim(kindat)[1]) {
  
  f_dec = kindat[row,"AgentTakingFirstDecision"] #agent taking first decision
  if (f_dec=="B") {
    decision1[row] = kindat[row,"B_decision"]
    conf1[row]     = kindat[row,"B_conf"]
    acc1[row]      = kindat[row,"B_acc"]} else {
      decision1[row] = kindat[row,"Y_decision"]
      conf1[row]     = kindat[row,"Y_conf"]
      acc1[row]      = kindat[row,"Y_acc"]
    }
  
  s_dec = kindat[row,"AgentTakingSecondDecision"] #agent taking second decision
  if (s_dec=="B") {
    decision2[row] = kindat[row,"B_decision"]
    conf2[row]     = kindat[row,"B_conf"]
    acc2[row]      = kindat[row,"B_acc"]} else {
      decision2[row] = kindat[row,"Y_decision"]
      conf2[row]     = kindat[row,"Y_conf"]
      acc2[row]      = kindat[row,"Y_acc"]
    }
}
# Add computed values (decision, confidence, accuracy) for 1st/2nd decision
kindat$decision1   = decision1
kindat$decision2   = decision2
kindat$confidence1 = conf1
kindat$confidence2 = conf2
kindat$accuracy1   = acc1
kindat$accuracy2   = acc2

# Sanity check: just check trials in which B=Y -> then also decision1 must be equal to decision2
all(as.integer(kindat$B_decision == kindat$Y_decision) == as.integer(kindat$decision1 == kindat$decision2))


# Add columns on worse(min)/better(max) agent (each for confidence and accuracy)
kindat$maxAgent = NA; kindat$minAgent = NA;
kindat$maxConf = NA; kindat$maxAcc = NA; kindat$minConf = NA; kindat$minAcc = NA;
for (p in unique(kindat$Pair)) { # p = pair
  if (minmax[minmax$Pair==p,"maxAgent"] == "B") {
    kindat[kindat$Pair==p,"maxConf"]  = kindat[kindat$Pair==p,"B_conf"]
    kindat[kindat$Pair==p,"minConf"]  = kindat[kindat$Pair==p,"Y_conf"]
    kindat[kindat$Pair==p,"maxAcc"]   = kindat[kindat$Pair==p,"B_acc"]
    kindat[kindat$Pair==p,"minAcc"]   = kindat[kindat$Pair==p,"Y_acc"]
    kindat[kindat$Pair==p,"maxAgent"] = "B" # max agent in this pair
    kindat[kindat$Pair==p,"minAgent"] = "Y" # min agent in this pair
  } else {
    kindat[kindat$Pair==p,"maxConf"]  = kindat[kindat$Pair==p,"Y_conf"]
    kindat[kindat$Pair==p,"minConf"]  = kindat[kindat$Pair==p,"B_conf"]
    kindat[kindat$Pair==p,"maxAcc"]   = kindat[kindat$Pair==p,"Y_acc"]
    kindat[kindat$Pair==p,"minAcc"]   = kindat[kindat$Pair==p,"B_acc"]
    kindat[kindat$Pair==p,"maxAgent"] = "Y"
    kindat[kindat$Pair==p,"minAgent"] = "B"
  }
}

# Add column on whether min or max agent takes first decision
mima_f_dec = c()
for (row in 1:dim(kindat)[1]) {
  f_dec   = kindat[row,"AgentTakingFirstDecision"]
  max_ag  = kindat[row,"maxAgent"]
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
kindat$mima_dec1 = mima_f_dec # who takes 1st dec. in this trial? (min or max agent)


# Add columns for the confidence difference values (deltas):
# confidence2-confidence1: deltaC2C1<0 = conf2<conf1; deltaC2C1>0 = conf2>conf1
kindat$deltaC2C1 = kindat$confidence2-kindat$confidence1
# confidenceColl-confidence1: deltaCcC1<0 = Coll_conf<conf1; deltaCcC1>0 = Coll_conf>conf1
kindat$deltaCcC1 = kindat$Coll_conf-kindat$confidence1

# Add a column that indicates whether 1st and collective decision differ ("switch"),
# i.e., whether A1 switched her decision (changed her mind) [1=switch, -1=no switch]
switchCol     = as.integer(kindat$decision1 != kindat$Coll_decision)
kindat$switch = switchCol
kindat$switch[kindat$switch==0] = -1 # now 1=switch, -1=no switch

# Check probability of switching per agent (only AgentTakingFirstDecision can switch)
# -1= no switch, 1=switch, 0=no data because agent took 2nd decision
swMax = c(); swMin = c()
for (row in 1:dim(kindat)[1]) {
  
  switch_d = kindat[row,"switch"]
  mima_d  = kindat[row,"mima_dec1"]
  
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
kindat$switchMax = swMax
kindat$switchMin = swMin

# add two columns to minmax data frame to record probability of switching
minmax[c("maxSwitchProb", "minSwitchProb")] <- NA

for (p in unique(kindat$Pair)) { # p = pair
  
  # swMax = sum of switches for maxAgent / no. of trials in which maxAgent could switch (i.e., acted first)
  # sanity check: length(kindat[kindat$Pair==p & kindat$mima_dec1=="max","switchMax"])==
  #               length(kindat[kindat$Pair==p & kindat$switchMax!=0,"switchMax"])
  swMax=sum(kindat[kindat$Pair==p & kindat$switchMax==1,"switchMax"]) /
    length(kindat[kindat$Pair==p & kindat$switchMax!=0,"switchMax"])
  swMin=sum(kindat[kindat$Pair==p & kindat$switchMin==1,"switchMin"]) /
    length(kindat[kindat$Pair==p & kindat$switchMin!=0,"switchMin"])
  
  minmax[minmax$Pair==p,"maxSwitchProb"]=swMax
  minmax[minmax$Pair==p,"minSwitchProb"]=swMin
}


################################################################################
# SAVE kindat INTO EXCEL FILE HERE - make sure that all vars are added before
if (save_data_final_all) {
  write_xlsx(kindat, path = paste0(saveDir,"/jmdData_allPairs_allKIN.xlsx"),
             col_names = TRUE, format_headers = TRUE)
}
################################################################################