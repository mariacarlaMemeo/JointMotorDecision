# confidence-accuracy calibration
# NOT SURE HOW TO COMPUTE VARIABILITY HERE??!

# create new dataframe for the confidence/accuracy ratio
data_caR_sum = setNames(data.frame(matrix(ncol = dim(data_coac_sum)[2], nrow = dim(data_coac_sum)[1]/2)), 
                        c(colnames(data_coac_sum)))
data_caR_sum$targetContrast = data_coac_sum[-c(4,5,6,10,11,12,16,17,18,22,23,24), ][,c("targetContrast")]
data_caR_sum$N = data_coac_sum[-c(4,5,6,10,11,12,16,17,18,22,23,24), ][,c("N")]
data_caR_sum$variable = rep(c("confacc1","confacc2","confaccColl"),times=4)
# compute ratios
c1=data_coac_sum[data_coac_sum$variable=="confidence1",c("value","sd","se","ci")]
a1=data_coac_sum[data_coac_sum$variable=="accuracy1",c("value","sd","se","ci")]
ca1=c1/a1
c2=data_coac_sum[data_coac_sum$variable=="confidence2",c("value","sd","se","ci")]
a2=data_coac_sum[data_coac_sum$variable=="accuracy2",c("value","sd","se","ci")]
ca2=c2/a2
cC=data_coac_sum[data_coac_sum$variable=="Coll_conf",c("value","sd","se","ci")]
aC=data_coac_sum[data_coac_sum$variable=="Coll_acc",c("value","sd","se","ci")]
caC=cC/aC
# insert ratios
data_caR_sum[data_caR_sum$variable=="confacc1",c("value","sd","se","ci")]    = ca1
data_caR_sum[data_caR_sum$variable=="confacc2",c("value","sd","se","ci")]    = ca2
data_caR_sum[data_caR_sum$variable=="confaccColl",c("value","sd","se","ci")] = caC

# reshape and rename
data_caR_sum = reshape_wider(
  data_caR_sum,
  id_cols = "targetContrast",
  names_from = "variable",
  values_from = c("value", "sd","se","ci"))
names(data_caR_sum)[names(data_caR_sum)=="value_confacc1"] = "confaccD1";
names(data_caR_sum)[names(data_caR_sum)=="value_confacc2"] = "confaccD2";
names(data_caR_sum)[names(data_caR_sum)=="value_confaccColl"] = "confaccDColl";

# plot confacc ratio by target contrast for d1,d2,dColl (within one plot)
ggplot(data_caR_sum, aes(x = targetContrast)) +
  geom_line(aes(y = confaccD1), color = threeCol[1], lwd = .7) + 
  geom_point(aes(y = confaccD1), color = threeCol[1]) +
  #geom_ribbon(aes(ymin = confaccD1-se_confacc1, ymax = confaccD1+se_confacc1),
              #alpha = .3, fill = threeCol[1], color = "transparent") +
  geom_line(aes(y = confaccD2), color = threeCol[2], lwd = .7) +
  geom_point(aes(y = confaccD2),color = threeCol[2]) +
  #geom_ribbon(aes(ymin = confaccD2-se_confacc2, ymax = confaccD2+se_confacc2),
              #alpha = .3, fill = threeCol[2], color = "transparent") +
  geom_line(aes(y = confaccDColl), color = threeCol[3], lwd = .7) +
  geom_point(aes(y = confaccDColl),color = threeCol[3]) +
  #geom_ribbon(aes(ymin = confaccDColl-se_confaccColl, ymax = confaccDColl+se_confaccColl),
              #alpha = .3, fill = threeCol[3], color = "transparent") +
  xlim(0.115, 0.250) + ylim(3,6.5) +
  labs(x = "Target contrast", y = "Confidence/Accuracy") + ggtitle(paste("Individual and collective CA-ratio",agree_title)) +
  theme(legend.position="none")
if (save_plots) {ggsave(file=sprintf(paste0("%sallDec_ConfRContrast",agree_lab,".png"),PlotDir), 
                        dpi = 300, units=c("cm"), height =20, width = 20)}
