pro find_dark_trends,year,month,startday,file_loc=file_loc; year_list=year_list, outdir=outdir, month_list=month_list, type=type, port=port
;level0 files are currently located here at SAO: /data/alisdair/opabina/scratch/joan/iris/newdat/orbit/level0/simpleB/YYYY/MM/
;What months of darks are you interested in?
if not keyword_set(year_list) then year_list = ['2014','2015','2016']
if not keyword_set(month_list) then month_list = ['01','02','03','04','05','06','07','08','09','10','11','12']
if not keyword_set(identifier) then identifier = []
if not keyword_set(type) then begin
    type=['FUV','NUV']
;    read, type, prompt='You need to specify FUV or NUV: '
endif
if not keyword_set(port) then begin
    port=['port1','port2','port3','port4']
;    read, port, prompt='You need to specify the port (port1, port2, port3, or port4): '
endif
if not keyword_set(file_loc) then file_loc = '/data/alisdair/opabina/scratch/joan/iris/newdat/orbit/level0/simpleB/'



year = repstr(string(year,format='(I4)'),'  ','20')
month = repstr(string(month,format='(I2)'),' ','0')
day = repstr(string(startday,format='(I2)'),' ','0')
day1 = repstr(string(startday+1,format='(I2)'),' ','0')


for ii=0,n_elements(type)-1 do begin
    sfil =  type[ii]+string(year)+string(month)+string(day)
    ;Added Jakub Prchlik 09/15/2016
    ;Include in search plus one day
    sfil1 =  type[ii]+string(year)+string(month)+day1

    files = file_search(file_loc+string(year)+'/'+string(month)+'/'+sfil+'_*.fits')
    files1 = file_search(file_loc+string(year)+'/'+string(month)+'/'+sfil1+'_*.fits')
    
    if n_elements(files1) eq 1 then files = files else files = [files,files1]
        
    read_iris,files,index,data
    
    iris_dark_trend_fix,index,offsets
    
    print,type[ii]
    print,offsets
endfor



end
