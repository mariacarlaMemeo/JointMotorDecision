compareMinMax <- function(wCollconf,wtarget,data_co_sum) {
  
  # The following analyses are based on Figure 2 in Mahmoodi et al., 2015
  # Mahmoodi, A., Bang, D., Olsen, K., Zhao, Y. A., Shi, Z., Broberg, K., ... & Bahrami, B. (2015).
  # Equality bias impairs collective decision-making across cultures. 
  # Proceedings of the national academy of sciences, 112(12), 3835-3840.
  
  
  # Figure 2A: who is more confident (min or max agent?)
  data_co_sum$targetContrast = factor(data_co_sum$targetContrast)
  data_co_sum$variable       = factor(data_co_sum$variable)
  if (wCollconf) {
    data_confcompare = data_co_sum
    # include target contrast as factor
    #if (wtarget) {
      print(ggplot(data_confcompare, aes(x = targetContrast, y = value, fill = variable, colour = variable)) +
              geom_bar(stat = "identity", position = "dodge", alpha = 0.5)+
              geom_errorbar(aes(x=targetContrast, ymin=value-se, ymax=value+se), 
                            position = position_dodge(0.9), width=0.2, size=1, alpha=0.9) +
              scale_y_continuous(breaks = conf_scale4$breaks, labels = conf_scale4$breaks) +
              scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
              ggtitle("who is more confident?") +
              ylab("Confidence") + xlab("Target contrast"))
      if (save_plots) {ggsave(file=sprintf("%sminmax_conf_wcoll_wtarget.png",PlotDir), 
                              dpi = 300, units=c("cm"), height =20, width = 20)}
      # across target contrasts
    #} else {
      data_confcompare = summarySE(data_confcompare,measurevar="value",groupvars=c("variable")) 
      data_confcompare$variable = factor(data_confcompare$variable)
      print(ggplot(data_confcompare, aes(x = variable, y = value)) +
              geom_bar(stat = "identity", position = "dodge", alpha = 0.5)+
              geom_errorbar(aes(x=variable, ymin=value-se, ymax=value+se), 
                            position = position_dodge(0.9), width=0.2, size=1, alpha=0.9) +
              #scale_y_continuous(breaks = conf_scale4$breaks, labels = conf_scale4$breaks) +
              scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
              ggtitle("who is more confident?") +
              ylab("Confidence") + xlab("Decisionmaker (max - min - coll)"))
      if (save_plots) {ggsave(file=sprintf("%sminmax_conf_wcoll.png",PlotDir), 
                              dpi = 300, units=c("cm"), height =20, width = 20)}
    #}
  } else {
    data_confcompare = data_co_sum[data_co_sum$variable=="maxConf" | data_co_sum$variable=="minConf",]
    # include target contrast as factor
    #if (wtarget) {
    print(ggplot(data_confcompare, aes(x = targetContrast, y = value, fill = variable, colour = variable)) +
            geom_bar(stat = "identity", position = "dodge", alpha = 0.5)+
            geom_errorbar(aes(x=targetContrast, ymin=value-se, ymax=value+se), 
                          position = position_dodge(0.9), width=0.2, size=1, alpha=0.9) +
            scale_y_continuous(breaks = conf_scale4$breaks, labels = conf_scale4$breaks) +
            scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
            ggtitle("who is more confident?") +
            ylab("Confidence") + xlab("Target contrast"))
    if (save_plots) {ggsave(file=sprintf("%sminmax_conf_wtarget.png",PlotDir), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
    # across target contrasts
    #} else {
    data_confcompare = summarySE(data_confcompare,measurevar="value",groupvars=c("variable")) 
    data_confcompare$variable = factor(data_confcompare$variable)
    print(ggplot(data_confcompare, aes(x = variable, y = value)) +
            geom_bar(stat = "identity", position = "dodge", alpha = 0.5)+
            geom_errorbar(aes(x=variable, ymin=value-se, ymax=value+se), 
                          position = position_dodge(0.9), width=0.2, size=1, alpha=0.9) +
            #scale_y_continuous(breaks = conf_scale4$breaks, labels = conf_scale4$breaks) +
            scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
            ggtitle("who is more confident?") +
            ylab("Confidence") + xlab("Decisionmaker (max - min)"))
    if (save_plots) {ggsave(file=sprintf("%sminmax_conf.png",PlotDir), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
    #}
  }
  
  
  # Figure 2B: how likely are min and max agent to switch (i.e., to confirm the other's decision)
  minmax_filt = minmax[,c("Pair","maxSwitchProb","minSwitchProb")]
  data_minmax_long = melt(minmax_filt, id=c("Pair"))
  data_minmax_sum = summarySE(data_minmax_long,measurevar="value",groupvars=c("variable")) 
  
  print(ggplot(data_minmax_sum, aes(x = variable, y = value)) +
          geom_bar(stat = "identity", position = "dodge", alpha = 0.5)+
          geom_errorbar(aes(x=variable, ymin=value-se, ymax=value+se), 
                        position = position_dodge(0.9), width=0.2, size=1, alpha=0.9) +
          #scale_y_continuous(breaks = conf_scale4$breaks, labels = conf_scale4$breaks) +
          #scale_x_discrete(breaks = target_scale$breaks, labels = target_scale$labels) +
          ggtitle("who is more likely to switch?") +
          ylab("probability to switch") + xlab("maxminAgent"))
  if (save_plots) {ggsave(file=sprintf("%sminmax_switchProbability.png",PlotDir), 
                          dpi = 300, units=c("cm"), height =20, width = 20)}
  
  
  # data_mima = curdat[,c("Pair","maxConf","maxAcc","minConf","minAcc")]
  # # COMPUTE PROBABILITY OF HIGH CONFIDENCE DEPENDING ON ACCURACY (mahmoodi fig 2C)
  # # XXX
  # # transform data_coac into long format
  # data_mima_long = melt(data_mima, id=c("Pair"))
  # # compute SUMMARY statistics, PER PAIR
  # data_mima_sum  = summarySE(data_mima_long,measurevar="value",groupvars=c("Pair","variable"))
  # data_mima_filt = data_mima_sum[data_mima_sum$value>0,]
  # # change variable names
  # data_mima_filt$variable=factor(data_mima_filt$variable)
  # levels(data_mima_filt$variable)=c("bla","bla","bla")
  # data_mm_sum  = summarySE(data_mima_filt,measurevar="value",groupvars=c("variable")) 
  
  #sprintf("compareMinMax function was run!")
  
}
