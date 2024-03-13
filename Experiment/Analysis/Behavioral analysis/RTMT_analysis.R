# RT and MT

# prep
conf_scale = list("lim"=c(1,6),"breaks"=seq(1,6, by=1))
time_scale = list("lim"=c(0.2,2.2),"breaks"=seq(0.25,2.25, by=0.25))
twoCol     = RColorBrewer::brewer.pal(5, "Greys")[c(3,5)]
# subselect data
rt_conf_2d      = curdat[,c("Pair","AgentTakingSecondDecision","confidence2","rt_final2")]
mt_conf_2d      = curdat[,c("Pair","AgentTakingSecondDecision","confidence2","mt_final2")]
# transform data into long format
rt_conf_2d_long = melt(rt_conf_2d, id=c("Pair","AgentTakingSecondDecision","confidence2"))
mt_conf_2d_long = melt(mt_conf_2d, id=c("Pair","AgentTakingSecondDecision","confidence2"))
# compute SUMMARY statistics, PER PAIR~AGENT
rt_conf_2d_sub  = summarySE(rt_conf_2d_long,measurevar="value",groupvars=c("Pair","AgentTakingSecondDecision","confidence2"))
mt_conf_2d_sub  = summarySE(mt_conf_2d_long,measurevar="value",groupvars=c("Pair","AgentTakingSecondDecision","confidence2"))
# compute SUMMARY statistics, across PAIR~AGENT
rt_conf_2d_sum  = summarySE(rt_conf_2d_sub,measurevar="value",groupvars=c("confidence2"))
mt_conf_2d_sum  = summarySE(mt_conf_2d_sub,measurevar="value",groupvars=c("confidence2"))
# combine rt and mt data frames
mt_rt_conf_2d_sum         = rbind(rt_conf_2d_sum,mt_conf_2d_sum); 
mt_rt_conf_2d_sum$var_lab = c(replicate(length(rt_conf_2d_sum), "rt"),replicate(length(mt_conf_2d_sum), "mt"))
mt_rt_conf_2d_sum$var_lab = as.factor(mt_rt_conf_2d_sum$var_lab)
rt_mt_conf                = mt_rt_conf_2d_sum # shorter name for convenience

# plot
# RT
print(ggplot(rt_conf_2d_sum, aes(x = confidence2, y = value)) +
        geom_point(position = position_dodge(width = 0.2), alpha=0.9, size=4)+
        geom_errorbar(aes(x=confidence2, ymin=value-se, ymax=value+se),
                      position = position_dodge(width = 0.2), width=0.2, alpha=0.9, size=1)+
        scale_y_continuous(limits = time_scale$lim, breaks = time_scale$breaks) +
        scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
        ggtitle("Reaction time by confidence level") +
        ylab("Reaction time (s)") + xlab("Confidence") + theme_custom())
#MT
print(ggplot(mt_conf_2d_sum, aes(x = confidence2, y = value)) +
        geom_point(position = position_dodge(width = 0.2), alpha=0.9, size=4)+
        geom_errorbar(aes(x=confidence2, ymin=value-se, ymax=value+se),
                      position = position_dodge(width = 0.2), width=0.2, alpha=0.9, size=1)+
        scale_y_continuous(limits = time_scale$lim, breaks = time_scale$breaks) +
        scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
        ggtitle("Movement time by confidence level") +
        ylab("Movement time (s)") + xlab("Confidence") + theme_custom())
#RT&MT
print(ggplot(rt_mt_conf, aes(x = confidence2, y = value, color=var_lab)) +
        geom_point(position = position_dodge(width = 0.2), alpha=0.9, size=4)+
        scale_color_manual(values = twoCol) +
        geom_errorbar(aes(x=confidence2, ymin=value-se, ymax=value+se,color=var_lab),
                      position = position_dodge(width = 0.2), width=0.2, alpha=0.9, size=1)+
        scale_y_continuous(limits = time_scale$lim, breaks = time_scale$breaks) +
        scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
        ggtitle("RT and MT by confidence level") +
        ylab("reaction and movement time (s)") + xlab("Confidence") + theme_custom())
if (save_plots) {ggsave(file=sprintf("%sRT&MT_Conf2.png",PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}


# different plot version
ggplot(rt_mt_conf, aes(x = confidence2, y = value)) +
  geom_line(data=rt_mt_conf, aes(y = value, color = var_lab), lwd = .7) + 
  geom_point(data=rt_mt_conf, aes(y = value, color = var_lab), size=3) +
  scale_color_manual(values = twoCol) +
  geom_ribbon(data=rt_mt_conf, aes(ymin = value-se, ymax = value+se, fill = var_lab),
              alpha = .3, color = "transparent")+
  scale_fill_manual(values = twoCol) +
  #xlim(0.115, 0.250) + ylim(3,9.5) +
  scale_y_continuous(limits = time_scale$lim, breaks = time_scale$breaks) +
  scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
  ggtitle("RT and MT by confidence level") +
  labs(x = "Confidence", y = "reaction and movement time (s)") + theme_custom()



