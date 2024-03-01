jmdData_info <- function(curdat) {
  
  # create empty data frame to record missing data and further info
  dataInfo = setNames(data.frame(matrix(ncol = 11, nrow = length(unique(curdat$Pair)))), 
                      c("Pair","trialsAll","trialsFinal","PercentageLost","trialsNAN","ErrorEarlyStart","ErrorTechnical",
                        "ErrorSanityCheck","decision2_B","decision2_Y","deciscion2_targetChanges"))
  dataInfo$Pair=unique(curdat$Pair) # assign pair number to first column
  
  for (p in unique(curdat$Pair)) {
    
    # total number of trials (rows) for current pair
    trials_all   = length(curdat[curdat$Pair==p,"confidence2"])
    # total number of nan rows
    trials_nan   = sum(is.na(curdat[curdat$Pair==p,"rt_final2"]))
    # final clean trial num
    trials_filt <- na.omit(curdat[curdat$Pair==p,])
    trials_clean = dim(trials_filt)[1]
    # missing trials as percentage of total trial number (160)
    trials_lost  = round((1-(trials_clean/trials_all))*100,1)
    # additional data loss: 1 trial for 110, 2 trials for 112 -> adjust percentage
    if (p == 110) {
      trials_lost  = round(((trials_nan+1)/(trials_all+1))*100,1)
    } else if (p == 112) {
      trials_lost  = round(((trials_nan+2)/(trials_all+2))*100,1)
    }
    # how often is the nan caused by an early release?
    early_start_R = curdat[curdat$Pair==p & (curdat$early_release_A1==1 | curdat$early_release_A2==1 | curdat$early_release_Coll==1),]
    early_start   = sum(!is.na(early_start_R$Pair))
    # how often was the trial erased for other reasons, during visual inspection?
    trial_erase_R = curdat[curdat$Pair==p & (curdat$mod1==6 | curdat$mod2==6 | curdat$modColl==6),]
    trial_erase   = sum(!is.na(trial_erase_R$Pair))
    # sanity check: number of deleted row must always be the sum of early starts and manually deleted trials
    sanity = isTRUE(trials_nan==sum(c(early_start,trial_erase))) #  sum(x,na.rm=FALSE)
    
    # count 2nd decisions per agent
    dec2_B = dim(trials_filt[trials_filt$AgentTakingSecondDecision=="B",])[1]
    dec2_Y = dim(trials_filt[trials_filt$AgentTakingSecondDecision=="Y",])[1]
    
    # count number of target changes (trajectory first towards left, then right, etc.)
    dec2_trg_changes = dim(trials_filt[trials_filt$trgChange2==1,])[1]
    
    # now insert info into data frame
    dataInfo[dataInfo$Pair==p,"trialsAll"]                = trials_all
    dataInfo[dataInfo$Pair==p,"trialsFinal"]              = trials_clean
    dataInfo[dataInfo$Pair==p,"PercentageLost"]           = trials_lost
    
    if (is.null(trials_nan)) {
      dataInfo[dataInfo$Pair==p,"trialsNAN"]              = 0
    } else {
      dataInfo[dataInfo$Pair==p,"trialsNAN"]              = trials_nan
    }
    if (is.null(early_start)) {
      dataInfo[dataInfo$Pair==p,"ErrorEarlyStart"]        = 0
    } else {
      dataInfo[dataInfo$Pair==p,"ErrorEarlyStart"]        = early_start
    }
    if (is.null(trial_erase)) {
      dataInfo[dataInfo$Pair==p,"ErrorTechnical"]         = 0
    } else {
      dataInfo[dataInfo$Pair==p,"ErrorTechnical"]         = trial_erase
    }
    dataInfo[dataInfo$Pair==p,"ErrorSanityCheck"]         = sanity
    
    dataInfo[dataInfo$Pair==p,"decision2_B"]              = dec2_B
    dataInfo[dataInfo$Pair==p,"decision2_Y"]              = dec2_Y
    dataInfo[dataInfo$Pair==p,"deciscion2_targetChanges"] = dec2_trg_changes
    
  }
  
  #sprintf("eccolo qui: jmdData_info!")
  return(dataInfo)
}