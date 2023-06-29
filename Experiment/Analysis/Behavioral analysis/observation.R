#################################################################################################################################
### OBSERVATION DATA (individual confidence estimation)

curobs = "Results_updated_24012023_magic.xlsx" #observation data
file <- sprintf('%s%s', DataDirObs, curobs) 
# read all the sheets, i.e. all the pairs data, the from the excel file of observation
datObs = read_all_sheets(file,"P","A:U")
curdatObs = rbindlist(datObs)
names(curdatObs)[names(curdatObs)=="Trial"] <- "trial_obs"
names(curdatObs)[names(curdatObs)=="Block"] <- "block_obs"
names(curdatObs)[names(curdatObs)=="Pair"] <- "pair_obs"
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
exedat_yb    = with(exedat, exedat[order(Pair,-asec),])#first agent YELLOW(Y) acting second, observed by agent BLUE(b) (to align with obsdat)
names(exedat_yb)[names(exedat_yb)=="Trial"] <- "trial_exe"
names(exedat_yb)[names(exedat_yb)=="Pair"] <- "pair_exe"

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
          geom_line(aes(Pair=trial_exe,color=as.factor(trial_exe)),position=position_jitter(width = .01, height = .01))+
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
          geom_line(aes(Pair=trial_exe,color=as.factor(trial_exe)),position=position_jitter(width = .01, height = .01))+
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

