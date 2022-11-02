pro find_con_darks_no_thread,month,yeari,sdir=sdir,simpleb=simpleb,complexa=complexa,type=type,plotter=plotter,logdir=logdir,outdir=outdir
    set_plot,'Z'
;Commented OUT compile_opt idl2 J. Prchlik 2018/01/02
;    compile_opt idl2
;;;;;;;;;;;;;;;;;;;;;;;;;
;needs simpleb or complexa keyword set
;;;;;;;;;;;;;;;;;;;;;;;;

;look up directory structure which contain level0 darks
    if keyword_set(sdir) then sdir=sdir else sdir = '/data/alisdair/opabina/scratch/joan/iris/newdat/orbit/level0/'
    if keyword_set(simpleb) then sdir=sdir+'simpleB/'
    if keyword_set(complexa) then sdir=sdir+'complexA/' 
    if keyword_set(type) then type = type else type = 'FUV'
    if keyword_set(logdir) then logdir=logdir+'/' else logdir = 'log/'
    if keyword_set(outdir) then outdir=outdir+'/' else outdir = 'txtout/'

; find whether month is list or single value
    monarr = n_elements(size(month))
    monsin = 0
    if monarr eq 3 then begin

;month is a single value
        monsin = 1
        month = [month]
    endif

;check whether year is a single value
    yeaarr = n_elements(size(yeari))
    yeasin = 0
    if yeaarr eq 3 then begin

;yeari is a single value
        yeasin = 1
        yeari = [yeari]
    endif

;check that if year or month are arrays that their lengths are the same
    yearlen = n_elements(yeari)
    montlen = n_elements(month)
    if ((yeasin eq 0) and (monsin eq 0)) then begin
        if yearlen ne montlen then MESSAGE,'Arrays must be the same size if both Month and Year are arrays'        
    endif

;create arrays of the same size if one array is just one value
    if ((yeasin eq 0) and (monsin eq 1)) then month = month[0]+intarr(yearlen)
    if ((yeasin eq 1) and (monsin eq 0)) then yeari = yeari[0]+intarr(montlen)

;loop over all elements arrays
    for i=0,n_elements(month)-1 do begin
        smonth = strcompress(string(month[i]),/remove_all)
        syeari = strcompress(string(yeari[i]),/remove_all)

;add extra information for short handed inputs
        if strlen(smonth) eq 1 then smonth = '0'+smonth
        if strlen(syeari) eq 2 then syeari = '20'+syeari

;check to make sure the month and year strings are the correct length
        if strlen(smonth) ne 2 then MESSAGE,'Month must be input in either DD or D'
        if strlen(syeari) ne 4 then MESSAGE,'Year must be input in either YYYY or YY'

;create full path
        fullp = sdir+syeari+'/'+smonth+'/'

;list files of specified type 
        filelist = file_search(fullp+type+'*fits')
        nFiles = n_elements(filelist)
        passarra = intarr(nFiles)

;Check to make sure dark exist that month (added 2016/10/17)
        if n_elements(filelist) le 1 then begin
            print,syeari,'/',smonth,' contains no darks'
            continue
        endif
;create arrrays to store results for each file
        cpl = 0
        passer = []
        total_5 = []
        exptim = []
        timeou = strarr(1)
        basicf = strarr(1)
        f_results = []
;Check the sig level for each file
        for j=0, nFiles-1 do begin
           filetodo = filelist[j]
           check_sig_level,filetodo,pass,endfile,timfile,total5,exptime
           ;Save values
           cpl += pass
           passer = [passer,pass]
           basicf = [basicf,endfile]
           timeou = [timeou,timfile]
           total_5 = [total_5,total5]
           exptim = [exptim,exptime]
        endfor

;remove first empty element from string arrays
       basicf = basicf[1:*]
       timeou = timeou[1:*]
;sort by output time
       sorter = sort(timeou)
       basicf = basicf[sorter]
       timeou = timeou[sorter]
       passer = passer[sorter]
       exptim = exptim[sorter]
       total5 = total5[sorter]

;Stats for the entire month
        bigstat = '#'+syeari+'/'+smonth+' Number Pass = '+strcompress(cpl,/remove_all)+' ('+strcompress(float(cpl)/nFiles*100.,/remove_all)+'%)'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
        format = '(A35,2X,A20,2X,I6,2X,I8,2X,F8.2)'
        fname = outdir+type+'_'+syeari+'_'+smonth+'.txt'
        openw,1,fname
;print main result summary
        printf,1,bigstat
; add header to file
        printf,1,'file','time','pass','total5','exptime',format='(A35,2X,A20,2X,A6,2X,A8,2X,A8)'
        print, n_elements(passer)
;print each result to the file
        for j=0,n_elements(passer)-1 do printf,1,basicf[j],timeou[j],passer[j],total_5[j],exptim[j],format=format
        close,1
;Print bigstat to the user
        print,bigstat

 ;plot if ploter keyword set
        if keyword_set(plotter) then make_saa_plot,smonth,syeari,type,outdir,plotdir='plots'
    endfor
;
end
