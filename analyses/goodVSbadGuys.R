# Comparisons between less vs. more sensitive dyad member
# -------------------------------------------------------
# The following analyses are based on Figure 2 A-C in:
# Mahmoodi et al. (2015). Equality bias impairs collective decision-making across cultures.
# (less sensitive = "min"; more sensitive = "max")

# Step 1:
# Manually import sensitivities from Matlab:
# P100: B=2.57, Y=4.85; P101: B=1.89, Y=2.97; P103: B=7.58, Y=3.8

# To do: creating a loop, add nice plots!


# A. Confidence
# Compare average confidence of less vs. more confident members
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

# B. Switch (only check disagreement trials)
# Check whether less or more sensitive members are more likely to "confirm the other" (= switch)
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


# C. Probability of high confidence
# Compare percentage of high confidence for accurate/inaccurate decisions
# Note: high confidence means > than the individual's average confidence
p100_max_HiConf_correct   = curdat$Y_conf[curdat$group==100 & curdat$Y_acc==1 & curdat$Y_conf>p100_max]
p100_max_LoConf_correct   = curdat$Y_conf[curdat$group==100 & curdat$Y_acc==1 & curdat$Y_conf<p100_max]
p100_max_HiConf_incorrect = curdat$Y_conf[curdat$group==100 & curdat$Y_acc==0 & curdat$Y_conf>p100_max]
p100_max_LoConf_incorrect = curdat$Y_conf[curdat$group==100 & curdat$Y_acc==0 & curdat$Y_conf<p100_max]
p100_min_HiConf_correct   = curdat$B_conf[curdat$group==100 & curdat$B_acc==1 & curdat$B_conf>p100_min]
p100_min_LoConf_correct   = curdat$B_conf[curdat$group==100 & curdat$B_acc==1 & curdat$B_conf<p100_min]
p100_min_HiConf_incorrect = curdat$B_conf[curdat$group==100 & curdat$B_acc==0 & curdat$B_conf>p100_min]
p100_min_LoConf_incorrect = curdat$B_conf[curdat$group==100 & curdat$B_acc==0 & curdat$B_conf<p100_min]

p101_max_HiConf_correct   = curdat$Y_conf[curdat$group==101 & curdat$Y_acc==1 & curdat$Y_conf>p101_max]
p101_max_LoConf_correct   = curdat$Y_conf[curdat$group==101 & curdat$Y_acc==1 & curdat$Y_conf<p101_max]
p101_max_HiConf_incorrect = curdat$Y_conf[curdat$group==101 & curdat$Y_acc==0 & curdat$Y_conf>p101_max]
p101_max_LoConf_incorrect = curdat$Y_conf[curdat$group==101 & curdat$Y_acc==0 & curdat$Y_conf<p101_max]
p101_min_HiConf_correct   = curdat$B_conf[curdat$group==101 & curdat$B_acc==1 & curdat$B_conf>p101_min]
p101_min_LoConf_correct   = curdat$B_conf[curdat$group==101 & curdat$B_acc==1 & curdat$B_conf<p101_min]
p101_min_HiConf_incorrect = curdat$B_conf[curdat$group==101 & curdat$B_acc==0 & curdat$B_conf>p101_min]
p101_min_LoConf_incorrect = curdat$B_conf[curdat$group==101 & curdat$B_acc==0 & curdat$B_conf<p101_min]

p103_min_HiConf_correct   = curdat$Y_conf[curdat$group==103 & curdat$Y_acc==1 & curdat$Y_conf>p103_min]
p103_min_LoConf_correct   = curdat$Y_conf[curdat$group==103 & curdat$Y_acc==1 & curdat$Y_conf<p103_min]
p103_min_HiConf_incorrect = curdat$Y_conf[curdat$group==103 & curdat$Y_acc==0 & curdat$Y_conf>p103_min]
p103_min_LoConf_incorrect = curdat$Y_conf[curdat$group==103 & curdat$Y_acc==0 & curdat$Y_conf<p103_min]
p103_max_HiConf_correct   = curdat$B_conf[curdat$group==103 & curdat$B_acc==1 & curdat$B_conf>p103_max]
p103_max_LoConf_correct   = curdat$B_conf[curdat$group==103 & curdat$B_acc==1 & curdat$B_conf<p103_max]
p103_max_HiConf_incorrect = curdat$B_conf[curdat$group==103 & curdat$B_acc==0 & curdat$B_conf>p103_max]
p103_max_LoConf_incorrect = curdat$B_conf[curdat$group==103 & curdat$B_acc==0 & curdat$B_conf<p103_max]

# averages for max
meanMax_HiConf_correct    = round(mean(c(p100_max_HiConf_correct, p101_max_HiConf_correct, p103_max_HiConf_correct)),2)
meanMax_LoConf_correct    = round(mean(c(p100_max_LoConf_correct, p101_max_LoConf_correct, p103_max_LoConf_correct)),2)
meanMax_HiConf_incorrect  = round(mean(c(p100_max_HiConf_incorrect, p101_max_HiConf_incorrect, p103_max_HiConf_incorrect)),2)
meanMax_LoConf_incorrect  = round(mean(c(p100_max_LoConf_incorrect, p101_max_LoConf_incorrect, p103_max_LoConf_incorrect)),2)
# averages for min
meanMin_HiConf_correct    = round(mean(c(p100_min_HiConf_correct, p101_min_HiConf_correct, p103_min_HiConf_correct)),2)
meanMin_LoConf_correct    = round(mean(c(p100_min_LoConf_correct, p101_min_LoConf_correct, p103_min_LoConf_correct)),2)
meanMin_HiConf_incorrect  = round(mean(c(p100_min_HiConf_incorrect, p101_min_HiConf_incorrect, p103_min_HiConf_incorrect)),2)
meanMin_LoConf_incorrect  = round(mean(c(p100_min_LoConf_incorrect, p101_min_LoConf_incorrect, p103_min_LoConf_incorrect)),2)

