
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
progver = 'v2020.Jan.22' ;--- (Guliano) V21 (FUV 2 and 4, NUV3): refit the amp1, amp2, scale, AmpInc, and 
;                                       OffNSop for FUV2. For FUV4 refit PHI1, Offset, Scale, and OffNSop.              ;                                       Refit all parameters for NUV3
;-;                                       
;                                                                            
progver = 'v2020.April.21' ;--- (Guliano) V22 (FUV1,2,3,and 4, NUV1,3 and 4): refit all parameters for all channgels except NUV2 to account for consistent over estimated from the model for the last few months in these 7 channels.
;-
progver = 'v2020.August.26' ;--- (Guliano) V23 (FUV1,2,3,and 4, NUV1,3 and 4): refit Scale, OffDrop, and OffNSop parameters for all channgels except NUV2 to account for the continued over estimation from the model in these 7 channels.
; ============================================================================



ins = index.instrume ne 'FUV'

k=indgen(4)  + ins*4                          


;      Amp1      ,Amp2      ,P1             ,Phi1      ,Phi2      ,Trend               , $
;      Quad                ,Offset    ,Scale     ,OffDrop   ,AmpInc
fuv1=[ 0.24353  , 0.14831  ,  3.2877e+07   , 0.55958  , 1.28312  ,  2.747592140e-08   , $
       5.839828956e-16   , -0.54579 ,   0.28855,   0.39300,   9.10224,   0.32835]
fuv2=[ 0.29961  , 0.22739  ,  3.1848e+07   , 0.40402  , 0.93822  ,  2.756572669e-08   , $
       4.289751469e-16   , -0.53940 ,   0.37059,   0.37261,   4.55072,   0.24408]
fuv3=[ 1.70120  , 1.60650  ,  3.1646e+07   , 0.34286  , 0.88734  ,  2.845255024e-08   , $
       1.223695813e-15   , -0.79526 ,   0.13824,   0.26568,   1.03596,   0.63011]
fuv4=[ 0.33782  , 0.23399  ,  3.2257e+07   , 0.48969  , 1.06305  ,  1.623049512e-08   , $
       1.023078060e-15   , -0.50600 ,   0.16981,   0.28676,   8.94207,   0.51390]
nuv1=[ 0.59455  , 0.55915  ,  3.1603e+07   , 0.32084  , -0.10783 ,  4.733166411e-09   ,  $
       2.076235353e-16   , -0.21194 ,   0.19387,   0.48756,   0.59792,   0.32465]
nuv2=[ 0.74602  , 0.69290  ,  3.1654e+07   , 0.32541  , 0.89458  ,  3.562004702e-09   , $
       2.873002169e-16   , -0.23126 ,   0.12149,   0.36016,   0.55561,   0.34187]
nuv3=[ 0.27547  , 0.25015  ,  3.1629e+07   , 0.34168  , 0.89895  ,  9.520416820e-09   , $
       3.621996212e-16   , -0.11274 ,   0.25429,   0.24664,   1.05627,   0.03047]
nuv4=[ 0.45788  , 0.45089  ,  3.1639e+07   , 0.33739  , 0.90414  ,  8.401508251e-09   , $
       3.402974326e-16   , -0.25608 ,   0.24201,   0.28734,   0.53837,   0.02337]


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
