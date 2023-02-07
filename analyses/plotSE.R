#Plot with average values +/- se
plotSE <- function(n_var,df,xvar,yvar,colorvar,shapevar,xscale,yscale,titlestr,manual_col,disco) {
  if(n_var==2){
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

  if(n_var==3){
    ggplot(df, aes(x=xvar, y=yvar, color=colorvar, shape=shapevar)) +
      geom_errorbar(aes(ymin=yvar-se, ymax=yvar+se), size=0.7, width=.01, position=pd) +
      geom_point(aes(shape=shapevar, color=colorvar), size = 3,position=pd) +
      geom_line(aes(linetype=shapevar), size=1, position=pd) +
      scale_color_manual(values=manual_col) +
      scale_linetype_manual(values=c("dotted","dashed","solid"))+
      scale_size_manual(values=c(3,3,3)) +
      ggtitle(titlestr)+
      scale_y_continuous(limits = yscale$lim, breaks=yscale$breaks) +
      if(disco) {
        scale_x_discrete(limits = factor(xscale$breaks), breaks=xscale$breaks)
      } else {
        scale_x_continuous(limits = xscale$lim, breaks=xscale$breaks, labels = xscale$labels)
      } 
  }
  
}