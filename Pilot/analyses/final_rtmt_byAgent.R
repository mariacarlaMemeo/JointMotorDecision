final_rtmt_byAgent <- function(dat){
  #The rt and mt in this function are related to those calculated with kinematic threshold (Matlab).
  # the function takes rt/mt_final columns from curdat dataframe and splits according to agent (B/Y or A1/A2)
  #rt agent 1
  rt1_a1=dat[dat$AgentTakingFirstDecision=="B",c("rt_final1","trial","group")]
  rt2_a1=dat[dat$AgentTakingSecondDecision=="B",c("rt_final2","trial","group")]
  names(rt1_a1) = c("rt","trial","group")
  names(rt2_a1) = c("rt","trial","group")
  drt_a1 = rbind(rt1_a1,rt2_a1)
  rt_a1  = with(drt_a1, drt_a1[order(group,trial,rt),])
  #rt agent 2
  rt1_a2=dat[dat$AgentTakingFirstDecision=="Y",c("rt_final1","trial","group")]
  rt2_a2=dat[dat$AgentTakingSecondDecision=="Y",c("rt_final2","trial","group")]
  names(rt1_a2) = c("rt","trial","group")
  names(rt2_a2) = c("rt","trial","group")
  drt_a2 = rbind(rt1_a2,rt2_a2)
  rt_a2  = with(drt_a2, drt_a2[order(group,trial,rt),])
  
  #mt agent 1
  mt1_a1=dat[dat$AgentTakingFirstDecision=="B",c("mt_final1","trial","group")]
  mt2_a1=dat[dat$AgentTakingSecondDecision=="B",c("mt_final2","trial","group")]
  names(mt1_a1) = c("mt","trial","group")
  names(mt2_a1) = c("mt","trial","group")
  dmt_a1 = rbind(mt1_a1,mt2_a1)
  mt_a1  = with(dmt_a1, dmt_a1[order(group,trial,mt),])
  #mt agent 2
  mt1_a2=dat[dat$AgentTakingFirstDecision=="Y",c("mt_final1","trial","group")]
  mt2_a2=dat[dat$AgentTakingSecondDecision=="Y",c("mt_final2","trial","group")]
  names(mt1_a2) = c("mt","trial","group")
  names(mt2_a2) = c("mt","trial","group")
  dmt_a2 = rbind(mt1_a2,mt2_a2)
  mt_a2  = with(dmt_a2, dmt_a2[order(group,trial,mt),])
  
  #merge
  all((rt_a1$trial == rt_a2$trial) & (mt_a1$trial == mt_a2$trial))
  dat$B_rtKin = rt_a1$rt
  dat$Y_rtKin = rt_a2$rt
  dat$B_mtKin = mt_a1$mt
  dat$Y_mtKin = mt_a2$mt
  
  return(dat)
}
