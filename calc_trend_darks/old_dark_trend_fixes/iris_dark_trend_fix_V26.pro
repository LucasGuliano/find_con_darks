
pro iris_dark_trend_fix, index, offsets,  progver = progver

; ============================================================================
;+
;
; PROJECT:
;
;     IRIS
;
; NAME:
;
;     IRIS_DARK_TREND_FIX
;
; CATEGORY:
;
;       Data calibration
;
; PURPOSE:
;
;       Calculates offsets for long-term trends in dark levels based on BLS
;       measurements and measured dark levels;  meant to be used within 
;       IRIS_MAKE_DARK
;
; CALLING SEQUENCE:
;
; INPUTS:
;
;         INDEX:  [mandatory] IRIS type index structure of the data array
;                 for which you want a dark generated (a single index).
;
;
;
; OUTPUTS:
;
;       OFFSETS:  [mandatory] Set of offsets to correct for long-term trends
;                 for 4 CCD read ports
;                 (either FUV 1-4, or SJI/NUV 1-4, depending on INDEX)
;   
;                 values of offsets should be subtracted from the values
;                 calculated for each CCD port in IRIS_MAKE_DARK
;
;
;  EXAMPLE:
;
;               iris_dark_trend_fix index, offsets
;
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;                 None
;
; OPTIONAL OUTPUT KEYWORD PARAMETERS:
;         PROGVER:   String describing the version of this routine that was run
;
;
; 
;
; CONTACT:
;
;       Comments, feedback, and bug reports regarding this routine may be
;       directed to this email address (temporarily): saar@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
progver = 'v2014.Sep.12' ;--- (SSaar) Written.
progver = 'v2014.Sep.23' ;--- (SSaar) V2 with double sine model.
progver = 'v2014.Sep.28' ;--- (SSaar) V3 with double sine model; cyclic amp var.
progver = 'v2014.Nov.15' ;--- (SSaar) V3 with updated parameters #1 
progver = 'v2015.Apr.13' ;--- (SSaar) V3.1 with updated parameters #2, split
;                                       secondary trend phase shift
progver = 'v2015.Sep.30' ;--- (SSaar) V4 with new double sine model + linear
;                                       trend, P2=P1/2 
progver = 'v2016.Jan.10' ;--- (SSaar) V5 update of double sine model + linear
;                                       trend, P2=P1/2, data thru 11/15 
progver = 'v2016.May.13' ;--- (SSaar) V6 update of double sine model + quad 
;                                       trend, P2=P1/2, data thru 05/16 
progver = 'v2016.Oct.07' ;--- (SSaar) V7 update of 2 sine model + shifted quad
;                                       trend, P2=P1/2, data thru 09/16
progver = 'v2016.Nov.14' ;--- (SSaar) V8 same as V7, fixed indexing bug
;
progver = 'v2016.Dec.28' ;--- (SSaar) V9 update (NUV only) of double sine model
;                                       +quad trend, P2=P1/2, data thru 12/16
progver = 'v2017.Apr.07' ;--- (SSaar) V10 update of double sine model
;                                       +quad trend, P2=P1/2, data thru 03/17
progver = 'v2017.Jun.06' ;--- (SSaar,JPrchlik) V11 update of double sine model
;                                       +quad trend, P2=P1/2, data thru 05/17
progver = 'v2017.Oct.16' ;--- (SSaar,JPrchlik) V12 update of double sine model
;                                       +quad trend, P2=P1/2, data thru 10/17
progver = 'v2017.Dec.14' ;--- (SSaar,JPrchlik) V13 update of double sine model
;                                       +quad trend (now with stop time for
;                                        FUV), P2=P1/2, data thru 11/17
progver = 'v2018.Feb.02' ;--- (SSaar,JPrchlik) V14 update of double sine model
;                                       +quad trend (now with stop time),
;                                        P2=P1/2, data thru 01/18
progver = 'v2018.May.29' ;--- (SSaar,JPrchlik) V15 update of double sine model
;                                       +quad trend, P2=P1/2, data thru 05/18
;                                      linear+quad trend now reduced after 8/17
progver = 'v2018.Oct.17' ;--- (SSaar,JPrchlik) V16 update of double sine model
;                                       +quad trend, P2=P1/2, data thru 05/18
;                                      linear+quad trend now reduced after 8/17
;                                      fractional drop in offset and increase
;                                      Amp terms following the 6/18
;                                      bakeout 
progver = 'v2019.Jan.10' ;--- (SSaar,JPrchlik) V17 update of double sine model
;                                        +quad trend, P2=P1/2, data thru 05/18
;                                       linear+quad trend now reduced after 8/17
;                                       fractional drop in offset and increase
;                                       Amp terms following the 6/18
;                                       bakeout, an increase the the pedestal
;                                       offset level following non-standard
;                                       IRIS operations following 2018/12/15
progver = 'v2019.Jan.22' ;--- (SSaar,JPrchlik) V18 update of double sine model
;                                        +quad trend, P2=P1/2, data thru 05/18
;                                       linear+quad trend now reduced after 8/17
;                                       fractional drop in offset and increase
;                                       Amp terms following the 6/18
;                                       bakeout, an increase the the pedestal
;                                       offset level following non-standard
;                                       IRIS operations following 2018/12/15.
;                                       Turned off increase in sine amplitude 
;                                       due to bakeout following the resumption 
;                                       of IRIS on 2018/12/15.
progver = 'v2019.Apr.26' ;--- (VPolito,JPrchlik,SSaar) V19 (FUV1,2 and 4 only): refit parameters 
;                                       of double sin model +quad, trend and OffNSop 
;                                       for data from 02/07. Offset, scale and AmpInc 
;                                       also modified for FUV2 port only
progver = 'v2019.Oct.30' ;--- (Guliano) V20 (FUV1,2,3, 4 and NUV 2, 3, 4): refit all model
;                                       parameters for FUV 1,2,4 and NUV 2,3,4. All pararamets 
;                                       for FUV 3 were updated other than P1 which was held constant.
;                                       This was done in response to the drop seen in the 2019/09 darks   
;                                       
progver = 'v2020.Jan.22' ;--- (Guliano) V21 (FUV 2 and 4, NUV3): refit the amp1, amp2, scale, AmpInc, and 
;                                       OffNSop for FUV2. For FUV4 refit PHI1, Offset, Scale, and OffNSop.     ;                                       Refit all parameters for NUV3                                    
;                                                                            
progver = 'v2020.Apr.21' ;--- (Guliano) V22 (FUV1,2,3,and 4, NUV1,3 and 4): refit all parameters for all
;                                       channgels except NUV2 to account for consistent over estimated from
;                                       the model for the last few months in these 7 channels.
;-
progver = 'v2020.Aug.26' ;--- (Guliano) V23 (FUV1,2,3,and 4, NUV1,3 and 4): refit Scale, OffDrop, and OffNSop
;                                       parameters for all channgel except NUV2 to account for the continued 
;                                       over estimation from the model in these 7 channels.
;
progver = 'v2021.Jan.12' ;--- (Guliano) V24 (FUV1,2,4, and NUV3): refit Amp1, Amp2, and Scale for 4 
;                                       channels to account for the drop due to eclipse season

progver = 'v2021.Apr.27' ;--- (Guliano) V25 (FUV1,2,3,and 4, NUV1,3 and 4): Refit Scale and OffNSop for NUV
;                                       channels. Refit Quad, Scale, Offdrop, and OffNSop for FUV channels. 
;                                       Reduced overall model overestimations after eclipse season. 
; 
progver = 'v2021.Jul.14' ;--- (Guliano) V26 (All Ports): All ports were refit following large disagreement in June 2021.
;                                       Parameters Amp1, Quad, Scale, Offdrop, and OffNSop were modified.                              
;
; ============================================================================                                                                            
;
;-
; ============================================================================



ins = index.instrume ne 'FUV'

k=indgen(4)  + ins*4                          


;      Amp1      ,Amp2      ,P1             ,Phi1      ,Phi2      ,Trend               , $
;      Quad                ,Offset    ,Scale     ,OffDrop   ,AmpInc
fuv1=[ 0.23862  , 0.16105  ,  3.2879e+07   , 0.55948  , 1.28338  ,  2.747484021e-08   , $
       6.029028012e-16   , -0.54581 ,   0.15975,   0.25465,   9.10043,   1.35478]
fuv2=[ 0.27669  , 0.24420  ,  3.1850e+07   , 0.40393  , 0.93822  ,  2.756605447e-08   , $
       4.482032184e-16   , -0.53942 ,   0.21256,   0.18957,   4.55163,   1.23323]
fuv3=[ 1.64281  , 1.60698  ,  3.1654e+07   , 0.34283  , 0.88725  ,  2.845254996e-08   , $
       1.243784963e-15   , -0.79534 ,   0.07212,   0.19668,   1.03606,   1.70187]
fuv4=[ 0.32631  , 0.24587  ,  3.2257e+07   , 0.48949  , 1.06327  ,  1.623217610e-08   , $
       1.045704045e-15   , -0.50600 ,   0.08517,   0.20088,   8.94385,   1.55313]
nuv1=[ 0.59340  , 0.55933  ,  3.1612e+07   , 0.32081  , -0.10786 ,  4.733692361e-09   , $
       2.128452835e-16   , -0.21192 ,   0.11989,   0.36441,   0.59810,   0.49101]
nuv2=[ 0.72833  , 0.69297  ,  3.1657e+07   , 0.32544  , 0.89449  ,  3.562360902e-09   , $
       2.886785511e-16   , -0.23124 ,   0.10221,   0.31730,   0.55555,   0.40787]
nuv3=[ 0.27390  , 0.25241  ,  3.1635e+07   , 0.34168  , 0.89859  ,  9.522320904e-09   , $
       3.780200188e-16   , -0.11272 ,   0.14033,   0.13907,   1.05671,   0.46192]
nuv4=[ 0.45186  , 0.45104  ,  3.1648e+07   , 0.33736  , 0.90387  ,  8.402445002e-09  , $
       3.525391125e-16   , -0.25605 ,   0.14240,   0.16248,   0.53852,   0.38140]

if ins eq 0 then begin                     ; if FUV, load up variables
   amp1=[fuv1(0),fuv2(0),fuv3(0),fuv4(0)]   ; amp of variation with period p1
   amp2=[fuv1(1),fuv2(1),fuv3(1),fuv4(1)]  ; amp of variation with period p1/2
   p1=[fuv1(2),fuv2(2),fuv3(2),fuv4(2)]    ; period of main variation [s]
   phi1=[fuv1(3),fuv2(3),fuv3(3),fuv4(3)]  ; phase offset for p=p1 variation
   phi2=[fuv1(4),fuv2(4),fuv3(4),fuv4(4)]  ; phase offset for p=p1/2 variation
   trend=[fuv1(5),fuv2(5),fuv3(5),fuv4(5)] ; linear long-term trend
   quad=[fuv1(6),fuv2(6),fuv3(6),fuv4(6)]  ;  quadratic term
   off=[fuv1(7),fuv2(7),fuv3(7),fuv4(7)]   ; offset constant
   scl=[fuv1(8),fuv2(8),fuv3(8),fuv4(8)]   ; Rescaling trend after given time 
   off_drop=[fuv1(9),fuv2(9),fuv3(9),fuv4(9)]   ; Rescaling intercept after bake out in June 2018
   amp_incr=[fuv1(10),fuv2(10),fuv3(10),fuv4(10)]   ; Rescaling amplitudes after bake out in June 2018
   off_incr=[fuv1(11),fuv2(11),fuv3(11),fuv4(11)]; Increasing the offset term following non-standard IRIS operations starting in Dec. 2018
   dtq0 = 5e7                               ; start time, quad term
   tq_end = 1.295e8                               ; end time, quad term
endif else begin                          ; if NUV/SJI
   amp1=[nuv1(0),nuv2(0),nuv3(0),nuv4(0)]
   amp2=[nuv1(1),nuv2(1),nuv3(1),nuv4(1)]
   p1=[nuv1(2),nuv2(2),nuv3(2),nuv4(2)]
   phi1=[nuv1(3),nuv2(3),nuv3(3),nuv4(3)]
   phi2=[nuv1(4),nuv2(4),nuv3(4),nuv4(4)]
   trend=[nuv1(5),nuv2(5),nuv3(5),nuv4(5)]
   quad=[nuv1(6),nuv2(6),nuv3(6),nuv4(6)]
   off=[nuv1(7),nuv2(7),nuv3(7),nuv4(7)]
   scl=[nuv1(8),nuv2(8),nuv3(8),nuv4(8)]   ; Rescaling trend after given time 
   off_drop=[nuv1(9),nuv2(9),nuv3(9),nuv4(9)]   ; Rescaling intercept after bake out in June 2018
   amp_incr=[nuv1(10),nuv2(10),nuv3(10),nuv4(10)]   ; Rescaling amplitudes after bake out in June 2018
   off_incr=[nuv1(11),nuv2(11),nuv3(11),nuv4(11)]; Increasing the offset term following non-standard IRIS operations starting in Dec. 2018
   dtq0 = 7e7                               ; start time, quad term
   tq_end = 1.295e8                               ; end time, quad term
endelse


;Add the June 13-15th bake out to the dropped pedestal level
;unit s from 1-jan-1958 based on anytim from IDL 
bojune152018 = 1.2450240d9


;Add non-standard telescope operations following IRIS coarse control
;From Oct. 28 - Dec. 15 2018 (Added 2019/01/10 J. Prchlik)
nsdec152018  = 1.2608352e+09

t0=[1090654728d0,1089963933d0,1090041516d0,1090041516d0,1090037115d0, $ 
     1090037115d0,1090037185d0,1090037185d0]     ; zero epoch


t=anytim(index.date_obs)

c=2*!pi



dt0 = t - t0[k]

dtq = dt0 > dtq0                   ; Removed quadratic end time 
dtq = dtq - dtq0                   ; timeline for quad term, for dt0>dtq0

tred = (dt0 gt tq_end)             ; times > when lin+quad trend are reduced 
                                   ;  (tq_end is now where trends are reduced)
adj = 1.0 - tred*(1.0-scl)         ; rescale at trend change boundary: 
                                   ;      1->scl
; Change offset across boundary so trend is continuous 
toff = (1.0-scl)*(quad*(tq_end-dtq0)^2+trend*tq_end)+off ; new boundary value 
off = off*(tred ne 1) + toff*tred  ; apply new boundary when t>tq_end

; add it together: 
;  A1 *sin(t/p +phi1) + A2 *sin (2*t/p +phi2) + B*t + C*(t>tq0)^2   


offsets = amp1 *sin(c*(dt0/p1 + phi1)) +  $
           amp2 *sin(c*(dt0/(p1/2) + phi2)) +  $
           trend*adj*dt0  + adj*quad*dtq^2 + off 

;Times after the June 2018 bake out
;post_bo = dt0 gt bojune152018-t0[k]
;Times after the June 2018 bake out but before then Dec. return from coarse control 2019/01/22 J. Prchlik
post_bo = ((dt0 gt bojune152018-t0[k]) and (dt0 lt nsdec152018-t0[k]))
;Adjust offsets after June 2018 bake out
drop_offset_june2018 = -(off_drop)*off
;Amplitudes adjusted after June 2018 bake out
incs_amplit_june2018 = ((amp1*sin(c*(dt0/p1+phi1)))+(amp2*sin(c*(dt0/(p1/2.)+phi2))))*amp_incr


;Times following the non-standard IRIS operations from Oct. 27-Dec. 15, 2018
post_ns = dt0 ge nsdec152018-t0[k]


;Add new bake out scaling to trend
offsets = (drop_offset_june2018+incs_amplit_june2018)*post_bo+offsets

;Add non-standard IRIS operations change in pedestal level to the trend
;Oct. 27-Dec. 15
offsets = off_incr*post_ns+offsets


return
end
;
;
;