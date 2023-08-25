#!/bin/tcsh

source $HOME/.cshrc
source $HOME/.cshrc.user
alias sswidl /proj/DataCenter/ssw/gen/setup/ssw_idl
setenv SSW /proj/DataCenter/ssw
setenv SSW_INSTR    "AIA IRIS"
source $SSW/gen/setup/setup.ssw /quiet
set dday=`python find_dark_runs.py`
echo ${dday}
##### set iday=YYYY/MM

set splt=( $dday:as/,/ / )
set iday=`echo $splt[2]/$splt[1]`
rm dummydir/*
set tcsh_levz=`tail -1 parameter_file`
set sidl_levz="'"`tail -1 parameter_file`"'"
if ($splt[1] != 'FAILED') then
    sswidl -e "do_lev1to0_darks,'"${iday}"/simpleB/','','',0,'dummydir/'"
    mv dummydir/*fits ${tcsh_levz}/simpleB/${iday}/
    sswidl -e "do_lev1to0_darks,'"${iday}"/complexA/','','',0,'dummydir/'"
    mv dummydir/*fits ${tcsh_levz}/complexA/${iday}/
    echo ${dday}
    echo ${sidl_levz}
endif

    #find_con_darks_no_thread, 08, 2023, type='NUV',logdir='log/',outdir='txtout/',/sim,sdir='/data/alisdair/opabina/scratch/joan/iris/newdat/orbit/level0/'
    #find_con_darks, MM, YYYY, type='FUV',logdir='log/',outdir='txtout/',/sim,sdir='/data/alisdair/opabina/scratch/joan/iris/newdat/orbit/level0/'
    sswidl -e "find_con_darks_no_thread,"${dday}",type='NUV',logdir='log/',outdir='txtout/',/sim,sdir="${sidl_levz}
    sswidl -e "find_con_darks_no_thread,"${dday}",type='FUV',logdir='log/',outdir='txtout/',/sim,sdir="${sidl_levz}

    cd temps
    python get_list_of_days.py
    cd ../calc_trend_darks
    sswidl -e "dark_trend,/sim,sdir="${sidl_levz}
    sswidl -e "format_for_steve"
    cd ../IRIS_dark_and_hot_pixel/
    sswidl -e "hot_pixel_plot_wrapper,file_loc="${sidl_levz}"+'/simpleB/'"        


