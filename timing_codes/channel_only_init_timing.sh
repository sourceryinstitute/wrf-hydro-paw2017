                                                                                                                                             
templateDir=/glade/scratch/jamesmcc/channel_only_init_timing/template                                                                        
                                                                                                                                             
## First setup a template dir                                                                                                                
cd $templateDir                                                                                                                              
linkToTestCase . ~/WRF_Hydro/TESTING/FILES/CONUS/V1.2/RUN/ $templateDir                                                                      
## replace/customize namelists                                                                                                               
cp hydro.namelist hydro.namelist.0; rm hydro.namelist; mv hydro.namelist.0 hydro.namelist                                                    
cp namelist.hrldas namelist.hrldas.0; rm namelist.hrldas; mv namelist.hrldas.0 namelist.hrldas                                               
## remove unneeded things                                                                                                                    
rm forcing                                                                                                                                   
rm restart/*                                                                                                                                 
## put forcing files and a real restart.                                                                                                     
ln -s /glade/scratch/jamesmcc/NWM_v1.2.1/full_v1.2.0/Short_Range/run.2017070100/forcing .                                                    
ln -s /glade/scratch/jamesmcc/NWM_v1.2.1/full_v1.2.0/Short_Range/run.2017070100/HYDRO_RST* restart/.                                         
## manually edit the namelist.hrldas                                                                                                         
# 1) start date                                                                                                                              
## manually edit the hydro.namelist                                                                                                          
# 1) restart file                                                                                                                            
##  binary for a run: v1.2                                                                                                                   
cp /glade/p/work/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork_2/trunk/NDHMS/Run/wrf_hydro.fc6f4f9.v1.2_release.HYDRO_REALTIME-WRFIO_NCD_LARGE_FIL\
E_SUPPORT-SPATIAL_SOIL.ifort-IFORT-15-0-3-20150407.exe .                                                                                     
## binary with hack to exit after init.                                                                                                      
cp /glade/p/work/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork_2/trunk/NDHMS/Run/wrf_hydro.fc6f4f9+.v1.2_release.HYDRO_REALTIME-WRFIO_NCD_LARGE_FI\
LE_SUPPORT-SPATIAL_SOIL.ifort-IFORT-15-0-3-20150407.exe .                                                                                    
                                                                                                                                             
aboveRunDirs=/glade/scratch/jamesmcc/channel_only_init_timing                                                                                
cd $aboveRunDirs

for cc in 16 32 64 128 256 512 1024 ; do                                                                                                     
    cd $aboveRunDirs                                                                                                                         
    echo $cc                                                                                                                                 
    mkdir runCores${cc}                                                                                                                      
    cd runCores${cc}                                                                                                                         
    linkToTestCase . $templateDir .                                                                                                          
    cp /glade/p/work/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork_2/trunk/NDHMS/Run/wrf_hydro.fc6f4f9+.v1.2_release.HYDRO_REALTIME-WRFIO_NCD_LARG\
E_FILE_SUPPORT-SPATIAL_SOIL.ifort-IFORT-15-0-3-20150407.exe .                                                                                
    bCleanRun -j runCores${cc} -W05:00 -qpremium $cc wrf_hydro.fc6f4f9+.v1.2_release.HYDRO_REALTIME-WRFIO_NCD_LARGE_FILE_SUPPORT-SPATIAL_SOIL.ifo\
rt-IFORT-15-0-3-20150407.exe                                                                                                                 
    cd $aboveRunDirs                                                                                                                         
done  
