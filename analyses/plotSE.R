#Plot with average values +/- se
plotSE <- function(df,xvar,yvar,colorvar,shapevar,titlestr) {
  ggplot(df, aes(x=xvar, y=yvar, color=colorvar, shape=shapevar)) +
  geom_errorbar(aes(ymin=yvar-se, ymax=yvar+se), size=0.7, width=.01, position=pd) +
  scale_y_continuous(limits = conf_lim, breaks=conf_break) +
  geom_point(aes(shape=shapevar, color=colorvar), size = 3,position=pd) +
  geom_line(aes(linetype=shapevar), size=1, position=pd) +
  scale_color_manual(values=c("steelblue1", "darkgreen")) +
  scale_linetype_manual(values=c("dashed","solid"))+
  ggtitle(titlestr)
}