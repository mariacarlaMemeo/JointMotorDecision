# Comparisons between less and more sensitive dyad member
# Import sensitivities from Matlab:
# P100: B=2.57, Y=4.85; P101: B=1.89, Y=2.97; P103: B=7.58, Y=3.8

# Note: The following should be improved by creating a loop!!!
# Also: Add nice plots!!!

# Confidence
p100_max     = mean(curdat$Y_conf[curdat$group==100], na.rm = TRUE)
p100_min     = mean(curdat$B_conf[curdat$group==100], na.rm = TRUE)
p101_max     = mean(curdat$Y_conf[curdat$group==101], na.rm = TRUE)
p101_min     = mean(curdat$B_conf[curdat$group==101], na.rm = TRUE)
p103_max     = mean(curdat$B_conf[curdat$group==103], na.rm = TRUE)
p103_min     = mean(curdat$Y_conf[curdat$group==103], na.rm = TRUE)
meanMax_Conf = round(mean(c(p100_max, p101_max, p103_max)),2)
meanMin_Conf = round(mean(c(p100_min, p101_min, p103_min)),2)
if (meanMax_Conf > meanMin_Conf) {
  sprintf("The good guys are more confident than the bad guys: %.2f %s %.2f", meanMax_Conf, " vs. ", meanMin_Conf)
} else {
  sprintf("The bad guys are overconfident: %.2f %s %.2f", meanMax_Conf, " vs. ", meanMin_Conf)
}

# check which trials are high vs. low confidence (high means < than the mean)
# CONTINUE WORKING ON THIS; it's wrong in the current form...
p100_max_HiConf_ind       = which(curdat$Y_conf[curdat$group==100]>=p100_max)
p100_max_LoConf_ind       = which(curdat$Y_conf[curdat$group==100]<p100_max)
p100_max_Conf_correct     = curdat$Y_conf[curdat$group==100 & curdat$Y_acc==1]
p100_max_Conf_incorrect   = curdat$Y_conf[curdat$group==100 & curdat$Y_acc==0]
# the following is wrong -----
p100_max_HiConf_correct   = p100_max_Conf_correct[c(p100_max_HiConf_ind),]
p100_max_LoConf_correct   = p100_max_Conf_correct[p100_max_LoConf_ind]
p100_max_HiConf_incorrect = p100_max_Conf_incorrect[p100_max_HiConf_ind]
p100_max_LoConf_incorrect = p100_max_Conf_incorrect[p100_max_LoConf_ind]
# ------------------------------

# Switch (only check disagreement trials)
p100_max_switch_col = curdat$switch[curdat$group==100 & curdat$AgentTakingFirstDecision=="Y" & curdat$agree==-1]
p100_max_switch_per = round(length(which(1 == p100_max_switch_col))/length(p100_max_switch_col),2)
p100_min_switch_col = curdat$switch[curdat$group==100 & curdat$AgentTakingFirstDecision=="B" & curdat$agree==-1]
p100_min_switch_per = round(length(which(1 == p100_min_switch_col))/length(p100_min_switch_col),2)
p101_max_switch_col = curdat$switch[curdat$group==101 & curdat$AgentTakingFirstDecision=="Y" & curdat$agree==-1]
p101_max_switch_per = round(length(which(1 == p101_max_switch_col))/length(p101_max_switch_col),2)
p101_min_switch_col = curdat$switch[curdat$group==101 & curdat$AgentTakingFirstDecision=="B" & curdat$agree==-1]
p101_min_switch_per = round(length(which(1 == p101_min_switch_col))/length(p101_min_switch_col),2)
p103_max_switch_col = curdat$switch[curdat$group==103 & curdat$AgentTakingFirstDecision=="B" & curdat$agree==-1]
p103_max_switch_per = round(length(which(1 == p103_max_switch_col))/length(p103_max_switch_col),2)
p103_min_switch_col = curdat$switch[curdat$group==103 & curdat$AgentTakingFirstDecision=="Y" & curdat$agree==-1]
p103_min_switch_per = round(length(which(1 == p103_min_switch_col))/length(p103_min_switch_col),2)
meanMax_Switch      = round(mean(c(p100_max_switch_per, p101_max_switch_per, p103_max_switch_per)),2)
meanMin_Switch      = round(mean(c(p100_min_switch_per, p101_min_switch_per, p103_min_switch_per)),2)
if (meanMax_Switch < meanMin_Switch) {
  sprintf("The good guys switch less than the bad guys: %.2f %s %.2f", meanMax_Switch, " vs. ", meanMin_Switch)
} else {
  sprintf("The bad guys don't show switchin' respect: %.2f %s %.2f", meanMax_Switch, " vs. ", meanMin_Switch)
}
