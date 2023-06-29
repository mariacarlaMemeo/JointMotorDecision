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




#####################################################


# SWITCH: inferred confidence
print(ggplot(sub_switch, aes(x=sub_switch[,"inferred Conf. - Conf. 1"], y=sub_switch[,"coll. Conf. - Conf. 1"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1))+ 
        stat_smooth(method="lm",se=TRUE) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("inferred Confidence - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("inferred Conf. - Conf. 1, switch trials"))
ggsave(file=paste0(PlotDir,"deltaInfConf-Conf1_CollConf_Switch.png"), dpi = 300, units=c("cm"), height =20, width = 20)

# NO SWITCH: inferred confidence
print(ggplot(sub_noswitch, aes(x=sub_noswitch[,"inferred Conf. - Conf. 1"], y=sub_noswitch[,"coll. Conf. - Conf. 1"], color = sub_noswitch[,"Agreement"]))+
        geom_point(size = 1,position=position_jitter(width = .1, height = .1)) + 
        stat_smooth(method="lm",se=TRUE) +
        scale_color_manual(values=c("limegreen","red4")) +
        scale_y_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        scale_x_continuous(limits = c(-5.5,5.5), breaks=seq(-5.5,5.5, by=1)) +
        xlab("inferred Confidence - Confidence 1") + ylab("collective Confidence - Confidence 1") +
        ggtitle("inferred Conf. - Conf. 1, no switch trials") +
        theme(legend.position = "none"))
ggsave(file=paste0(PlotDir,"deltaInfConf-Conf1_CollConf_NoSwitch.png"), dpi = 300, units=c("cm"), height =20, width = 20)


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
             xscale=conf_scale,yscale=time_scale,titlestr=paste0("MT/RT as a function of confidence (individual 2nd) "),
             manual_col=c("grey", "black"),linevar=c("dashed","solid"),sizevar=c(3,3),disco=TRUE) +
        xlab("observer confidence") + ylab("time [s]") + theme_custom())
ggsave(file=sprintf(paste0("%stime_obs_conf",".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


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
ggsave(file=sprintf(paste0("%sexeconf_vs_obsconfAveraged",".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20)


# multiple facets with all the agents
# https://r-graphics.org/recipe-annotate-facet
mpg_plot <- ggplot(sinout, aes(x=agent_confidence, y=conf_aveBlock)) +
  geom_point() +
  facet_grid(. ~ interaction(pair_obs,Oagent)) +
  geom_point(shape = 1, position = position_jitter(width = 0.1, height = .1)) +
  geom_smooth(method = lm, color = "blue", fill = "#69b3a2",se = TRUE) 
print(mpg_plot)
ggsave(file=sprintf(paste0("%sexeconf_vs_obsconf_perPair_",".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 20*length(levels(interaction(sinout$pair_obs,sinout$Oagent))))




###############################################################
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
ggsave(file=sprintf(paste0("%sdiffConf_vs_contrasts_",".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)


## (averaged obs conf - agent conf) vs movement time
## averaged movement time - divided by CONTRAST/agent/Pair
diffConf_mt  = sinout_1block[,c("targetContrast","diff_conf","diff_mt_signed","pair_obs","Oagent")]
diffConf_mt_sum = summarySE(diffConf_mt,measurevar="diff_mt_signed",groupvars=c("targetContrast","pair_obs","Oagent"))
diffConf_mt_sum$diff_conf = diffConf_targ_sum$diff_conf

## averaged movement time - divided by AGENT/Pair
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
ggsave(file=sprintf(paste0("%sdiffConf_vs_diffMt",".png"),PlotDir), dpi = 300, units=c("cm"), height =20, width = 30)

