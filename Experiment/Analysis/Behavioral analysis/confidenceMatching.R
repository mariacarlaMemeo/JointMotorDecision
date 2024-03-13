# try to recreate analysis from Bang et al. 2017
# Bang  et al. (2017). Confidence matching in group decision-making. 
# Nature Human Behaviour, 1(6), 0117.

# prep
conf_scale = list("lim"=c(1,6),"breaks"=seq(1,6, by=1))
# subselect data
data_match = curdat[,c("Pair","maxConf","minConf")]
# transform data into long format
data_match_long = melt(data_match, id=c("Pair"))
# compute SUMMARY statistics, PER PAIR
data_match_sum  = summarySE(data_match_long,measurevar="value",groupvars=c("Pair", "variable"))
# subset for min/max confidence
data_match_sum_max = data_match_sum[data_match_sum$variable=="maxConf",]
data_match_sum_min = data_match_sum[data_match_sum$variable=="minConf",]
# add min confidence to max data frame
data_match_sum_max$value_min = data_match_sum_min$value
# just to try: take only pairs whose members have similar sensitivity
data_match_sum_similar = data_match_sum_max[data_match_sum_max$Pair==110|
                                              data_match_sum_max$Pair==113|
                                              data_match_sum_max$Pair==115|
                                              data_match_sum_max$Pair==116|
                                              data_match_sum_max$Pair==117|
                                              data_match_sum_max$Pair==122|
                                              data_match_sum_max$Pair==123|
                                              data_match_sum_max$Pair==124,]

# plot (regression line is not working if you add color)
ggplot(data_match_sum_max, aes(x=value, y=value_min, color=as.factor(Pair))) +
  #geom_smooth(method=lm,se=FALSE, size=0.5) +
  #abline(lm(value ~ value_min, data = data_match_sum_max), col = "blue") +
  geom_point(shape=19,size=3) + scale_colour_discrete() + 
  xlab("maxAgent") + ylab("minAgent") +
  scale_y_continuous(limits = conf_scale$lim, breaks = conf_scale$breaks, labels = conf_scale$breaks) +
  scale_x_continuous(limits = conf_scale$lim, breaks = conf_scale$breaks, labels = conf_scale$breaks) +
  theme_custom()


# ggplot(data_match_sum_similar, aes(x=value, y=value_min, color=as.factor(Pair))) +
#   geom_point(shape=19,size=6) + scale_colour_discrete() + geom_smooth(method=lm,se=FALSE, size=0.5)
