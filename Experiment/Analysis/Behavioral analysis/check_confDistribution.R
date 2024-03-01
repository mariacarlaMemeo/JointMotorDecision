check_confDistribution <- function(curdat) {
  
  # check confidence distribution per agent, using curdat data frame
  
  # prep
  conf_scale = list("lim"=c(1,6),"breaks"=seq(1,6, by=1))
  conf2_info = setNames(data.frame(matrix(ncol = 4, nrow = length(unique(curdat$Pair))*2)),c("pair", "agent", "mean confidence2", "SD confidence2"))
  counter = 1;
  
  for (p in unique(curdat$Pair)) {
    
    cur_pair      = curdat[curdat$Pair==p,c("AgentTakingSecondDecision","confidence2")]
    cur_pair_info = table(cur_pair)
    
    # check confidence distribution per agent
    meanConf_B            = mean(cur_pair[cur_pair$AgentTakingSecondDecision=="B","confidence2"])
    sdConf_B              = sd(cur_pair[cur_pair$AgentTakingSecondDecision=="B","confidence2"])
    conf2_info[counter,1] = p; conf2_info[counter,2] = "B"
    conf2_info[counter,3] = meanConf_B; conf2_info[counter,4] = sdConf_B
    counter               = counter + 1;
    if (sdConf_B < 1) {print(sprintf(paste("Pair", p, "agent B has SD < 1.")))}
    meanConf_Y            = mean(cur_pair[cur_pair$AgentTakingSecondDecision=="Y","confidence2"])
    sdConf_Y              = sd(cur_pair[cur_pair$AgentTakingSecondDecision=="Y","confidence2"])
    conf2_info[counter,1] = p; conf2_info[counter,2] = "Y"
    conf2_info[counter,3] = meanConf_Y; conf2_info[counter,4] = sdConf_Y
    if (sdConf_Y < 1) {print(sprintf(paste("Pair", p, "agent Y has SD < 1.")))}
    
    cur_pair_long <- melt(cur_pair,id=c("AgentTakingSecondDecision"))
    names(cur_pair_long)[names(cur_pair_long)=='AgentTakingSecondDecision'] <- 'agent'
    
    print(ggplot(cur_pair_long, aes(x = value)) +
            geom_histogram(aes(color = agent, fill = agent), 
                           position = position_dodge(width = 0.5), binwidth = 1, alpha =0.5) +
            scale_color_manual(values = c("#00AFBB", "#E7B800")) +
            scale_fill_manual(values = c("#00AFBB", "#E7B800")) +
            scale_x_continuous(breaks = conf_scale$breaks, labels = conf_scale$breaks) +
            ggtitle(sprintf(paste("Pair",p))) +
            ylab("Count") + xlab("Confidence level") +
            theme(legend.position = c(.95, .95),legend.justification = c("right", "top"),
                  legend.box.just = "right", legend.margin = margin(6, 6, 6, 6),
                  legend.text = element_text(size = 12, colour = "black"),
                  legend.title = element_text(face = "bold")))
    
    if (save_plots) {ggsave(file=sprintf(paste0("%sdistributionConf2_pair",p,".png"),PlotDir), 
                            dpi = 300, units=c("cm"), height =20, width = 20)}
    
    counter = counter + 1;
    
  }
  
}