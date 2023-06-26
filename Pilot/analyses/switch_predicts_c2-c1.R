################################################################################

# add columns for the confidence difference values (deltas):
# confidence2 - confidence1:
# deltaC2C1 < 0 = conf2 < conf1; deltaC2C1 > 0 = conf2 > conf1
curdat$deltaC2C1 = curdat$confidence2-curdat$confidence1
dt      = curdat[curdat$agree==-1,]

# START SWITCH BAR PLOTS

# add confidence deltas to long format (only disagreement trials)
# without collective
dt_long_delta = melt(dt[,c("group","deltaC2C1","switch")], id=c("group","switch"))
switch_sum  = summarySE(dt_long_delta,measurevar="value",groupvars=c("switch","variable"))

# change factor level names
switch_sum$switch = as.factor(switch_sum$switch)
levels(switch_sum$switch) = c("No switch","Switch")
switch_sum$switch <- factor(switch_sum$switch, levels = c("Switch","No switch")) # change order
switch_sum$variable = as.factor(switch_sum$variable)
levels(switch_sum$variable) = c("Conf. 2 - Conf. 1")

# scale for confidence delta
delta_scale = list("lim"=c(-2,1),"breaks"=seq(-2,1, by=0.5))
# colors
delta_color = c("gray")

# variable = subjective vs. inferred, value = confidence delta 
print(ggplot(data=switch_sum, aes(x=switch, y=value, fill=variable, color = variable)) +
        ggtitle("Switching as a function of confidence delta (only disagreement)") +
        geom_bar(stat="identity", position="dodge", alpha = 0.5, color = "black") +
        scale_fill_manual(values=delta_color) +
        geom_errorbar(aes(ymin=value-se, ymax=value+se), size=0.5, width=0.1, color="black", position=position_dodge(.9)) + 
        scale_y_continuous(limits = delta_scale$lim, breaks=delta_scale$breaks) +
        xlab("Switching") + ylab("Confidence delta") + 
        # theme(panel.grid.major = element_line(color = "black", size = .5),
        #       panel.grid.minor = element_line(color = "black", size = .25),
        #       panel.grid.major.x = element_blank(),
        #       panel.grid.minor.x = element_blank()) +
        theme(legend.position = "none") + theme_custom()
)
ggsave(file=paste0(PlotDir,"deltaConf2-Conf1_Switching.png"), dpi = 300, units=c("cm"), height =20, width = 20)


# END SWITCH BAR PLOTS
###############################################################################
