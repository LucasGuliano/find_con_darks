pro plot_median_data

    savdir = '/Volumes/Pegasus/jprchlik/IRIS_dark_and_hot_pixel/Hot_pixel_sav_files/5sigma_cutoff/'

    fstr = 'NEW_port'
    filt = ['NUV','FUV']
;   filt = ['FUV']
    fend = '_hot_pixel_counts.sav'
    endn = 4
;Filled circle
    A = findgen(17)*(!PI*2/16.)
    rad = 2
    usersym,rad*cos(A),rad*sin(A),/FILL
    labels = ['port1','port2','port3','port4']
    colors = [cgcolor('purple'),cgcolor('purple'),cgcolor('purple'),cgcolor('purple')]
; set the number of minor and labeled tick marks
    datescale = 10

    set_plot,'PS'
;loop over filters
    for i=0,n_elements(filt)-1 do begin
        fils = filt[i]
;loop over ports
        fname = fils+'_dark_sigma'
        device,filename=fname+'.eps',/encap,/color,xsize=8,ysize=8,/inches
        for j=1,endn do begin
            strp = string(j,format='(I1)')
            restore,savdir+fstr+strp+'_'+fils+fend
            all_dates_30 = median_index_by_month_30s.date_obs
            all_dates_00 = median_index_by_month_0s.date_obs
            juldays30s  = dblarr(n_elements(all_dates_30))
            juldays00s  = dblarr(n_elements(all_dates_00))
             
            for k=0,n_elements(juldays30s)-1 do begin
                full_date30s = all_dates_30[k]
                year  = strmid(full_date30s,0,4)
                month = strmid(full_date30s,5,2)
                day   = strmid(full_date30s,8,2)
                juldays30s[k] = julday(month,day,year)
            endfor
             
            for k=0,n_elements(juldays00s)-1 do begin
                full_date00s = all_dates_00[k]
                year  = strmid(full_date00s,0,4)
                month = strmid(full_date00s,5,2)
                day   = strmid(full_date00s,8,2)
                juldays00s[k] = julday(month,day,year)
            endfor

            dummy = label_date(date_format=['%D-%M-%Y'])

            arr30s = size(hot_pix_sig_by_month_30s)
            plot30sdar = dblarr(arr30s[2])
            for k=0,uint(arr30s[2])-1 do begin
               use = where(hot_pix_sig_by_month_30s[*,k] > 0.0)
               plot30sdar[k] = median(hot_pix_sig_by_month_30s[use,k]) 
            endfor


            arr00s = size(hot_pix_sig_by_month_0s)
            plot00sdar = dblarr(arr00s[2])
            for k=0,uint(arr00s[2])-1 do begin
               use = where(hot_pix_sig_by_month_0s[*,k] > 0.0)
               plot00sdar[k] = median(hot_pix_sig_by_month_0s[use,k]) 
            endfor



            if j eq 1 then begin
                plot,juldays30s,plot30sdar,Background=cgColor('white'),color=cgColor('black'),/nodata,xtickformat='label_date',xstyle=1,$
                    xticks=n_elements(juldays30s)/datescale, yrange=[0.,5.],title=fils,psym=8,xrange=[min(juldays30s)-26,max(juldays30s)+37], $
                    charthick=6,charsize=1.7,xgridstyle=1,ygridstyle=1,xticklen=1,yticklen=1,font=1,yminor=5,xminor=datescale, $
                    ytitle='Dark Sigma [ADU]',position=[.1,.1,.9,.9]
            endif
          
            oplot,juldays30s,plot30sdar,color=cgColor('red' ),linestyle=j-1,thick=3
            oplot,juldays00s,plot00sdar,color=cgColor('blue'),linestyle=j-1,thick=3
        endfor
       
        if fils eq 'FUV' then $
            al_legend,labels,color=purple,linestyle=findgen(4),/bottom,charsize=1.5
        if fils eq 'NUV' then $
            al_legend,labels,color=purple,linestyle=findgen(4),/left,charsize=1.5
        device,/close,/encap
;  get current working directory
        spawn,'pwd',cwd
        cwd = cwd+'/'
        print,cwd+fname+'.eps'
; convert file to png
;        spawn,'convert '+cwd+fname+'.eps '+cwd+fname+'.pdf' 
;        spawn,'convert '+cwd+fname+'.pdf '+cwd+fname+'.png' 
    endfor
end
