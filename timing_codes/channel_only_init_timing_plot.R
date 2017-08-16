timing <-                                                                                                                                    
  data.frame(nCores= c(  16,   32,  64, 128, 256, 512, 1024),                                                                                        
             seconds=c(2490, 1265, 644, 333, 175,  94,   70) )[-1,]                                                                                       
                                                                                                                                             
library(ggplot2)

options(warn=1)

baseSize=13

ggplot(timing) +
    geom_point(aes(x=nCores, y=seconds)) +
    scale_x_continuous(trans='log2', breaks=timing$nCores, name='# of cores') +
    scale_y_continuous(trans='log2', breaks=c(timing$nCores)) +
    theme_bw(base_size=baseSize) +
    ggtitle('WRF-Hydro Initialization (Channel-only mode)')
ggsave('~/WRF_Hydro/wrf-hydro-paw2017/figures/init_timing_log.png')

ggplot(timing) +
   geom_point(aes(x=nCores, y=seconds)) +
    scale_x_continuous(breaks=timing$nCores, name='# of cores') +
    scale_y_continuous(breaks=c(timing$nCores)) +
    theme_bw(base_size=baseSize) +
    ggtitle('WRF-Hydro Initialization (Channel-only mode)')
ggsave('~/WRF_Hydro/wrf-hydro-paw2017/figures/init_timing_linear.png')
