#Plot with average values +/- se
plotSE <- function(df,xvar,yvar,colorvar,shapevar,xscale,yscale,titlestr,manual_col,disco) {
  ggplot(df, aes(x=xvar, y=yvar, color=colorvar, shape=shapevar)) +
    geom_errorbar(aes(ymin=yvar-se, ymax=yvar+se), size=0.7, width=.01, position=pd) +
    geom_point(aes(shape=shapevar, color=colorvar), size = 3,position=pd) +
    geom_line(aes(linetype=shapevar), size=1, position=pd) +
    scale_color_manual(values=manual_col) +
    scale_linetype_manual(values=c("dashed","solid"))+
    ggtitle(titlestr)+
    scale_y_continuous(limits = yscale$lim, breaks=yscale$breaks) +
    if(disco) {
      scale_x_discrete(limits = factor(xscale$breaks), breaks=xscale$breaks)
    } else {
      scale_x_continuous(limits = xscale$lim, breaks=xscale$breaks, labels = xscale$labels)
    }
}