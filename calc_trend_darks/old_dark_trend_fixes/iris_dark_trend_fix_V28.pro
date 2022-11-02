
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
;                                       channels. Refit Quad, Scale, Offdop, and OffNSop for FUV channels. 
;                                       Reduced overall model overestimations after eclipse season. 
; 
progver = 'v2021.Jul.14' ;--- (Guliano) V26 (All Ports): All ports were refit following large disagreement in June 2021.
;                                       Parameters Amp1, Quad, Scale, Offdrop, and OffNSop were modified.                          
;
progver = 'v2021.Nov.10' ;--- (Guliano) V27 (All Ports): All ports were refit following continued overestimates and consistent darks.
;                                       All parameters were adjusted to attempt to capture the
;                                       large amount of disagreement being seen.                                     
; ============================================================================                                                                            
;
;-
; ============================================================================

ins = index.instrume ne 'FUV'

k=indgen(4)  + ins*4                          


;      Amp1      ,Amp2      ,P1        ,Phi1      ,Phi2      ,Trend     
;      Quad      ,Offset    ,Scale     ,OffDrop   ,AmpInc    ,OffNSop   ,Lower 
fuv1=[ 0.19558  , 0.12712  ,  3.2311e+07   , 0.50261  , 1.11078  ,  2.735379656e-08   , $
       6.220927142e-16   , -0.55024 ,   0.13202,   0.17022,  12.66423,   1.59281,   0.67487]
fuv2=[ 0.26618  , 0.23390  ,  3.1800e+07   , 0.39819  , 0.92197  ,  2.675696634e-08   , $
       4.677465979e-16   , -0.48893 ,   0.18394,   0.14506,   3.85901,   1.42579,   0.46792]
fuv3=[ 1.66232  , 1.64090  ,  3.1625e+07   , 0.34022  , 0.88080  ,  2.686365601e-08   , $
       1.274132917e-15   , -0.71285 ,   0.05733,   0.18035,   0.98069,   1.98472,   0.7293]
fuv4=[ 0.32527  , 0.24580  ,  3.2127e+07   , 0.46622  , 1.02618  ,  1.481538540e-08   , $
       1.078909025e-15   , -0.44590 ,   0.06972,   0.18831,   7.88246,   1.75345,   0.61661]
nuv1=[ 0.59564  , 0.56807  ,  3.1648e+07   , 0.32951  , -0.09999 ,  4.955533291e-09   , $
       2.128058178e-16   , -0.23383 ,   0.10147,   0.31489,   0.59089,   0.54497,   0.10528]
nuv2=[ 0.73066  , 0.69590  ,  3.1637e+07   , 0.32599  , 0.89012  ,  3.595992386e-09   , $
       2.904600543e-16   , -0.23044 ,   0.09162,   0.28383,   0.54390,   0.44284,   0.18663]
nuv3=[ 0.27819  , 0.24401  ,  3.1634e+07   , 0.34827  , 0.88583  ,  9.349879026e-09   , $
       3.898948800e-16   , -0.10490 ,   0.10903,   0.11569,   1.55508,   0.62288,   0.23798]
nuv4=[ 0.45866  , 0.45042  ,  3.1649e+07   , 0.34282  , 0.90130  ,  8.468853620e-09  , $
       3.593957898e-16   , -0.26213 ,   0.12187,   0.15326,   0.66889,   0.46980,   0.26014]

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
   off_incr=[fuv1(11),fuv2(11),fuv3(11),fuv4(11)]   ; Increasing the offset term following non-standard IRIS operations starting in Dec. 2018
   lower=[fuv1(12),fuv2(12),fuv3(12),fuv4(12)]    ;Decrease all ports due to drop off seen in June 2021
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
   off_incr=[nuv1(11),nuv2(11),nuv3(11),nuv4(11)]   ; Increasing the offset term following non-standard IRIS operations starting in Dec. 2018
   lower=[nuv1(12),nuv2(12),nuv3(12),nuv4(12)]    ;Decrease all ports due to drop off seen in June 2021
   dtq0 = 7e7                               ; start time, quad term
   tq_end = 1.295e8                               ; end time, quad term
endelse

;Add the June 13-15th bake out to the dropped pedestal level
;unit s from 1-jan-1958 based on anytim from IDL 
bojune152018 = 1.2450240d9

;Add non-standard telescope operations following IRIS coarse control
;From Oct. 28 - Dec. 15 2018 (Added 2019/01/10 J. Prchlik)
nsdec152018  = 1.2608352e+09

;Add time after June 2021 to account for overestimation by model during this time
fix2021  = 1.33865e+09

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

offsets = amp1 *sin(c*(dt0/p1 + phi1)) +  $
           amp2 *sin(c*(dt0/(p1/2) + phi2)) +  $
           trend*adj*dt0  + adj*quad*dtq^2 + off 

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
offsets = (off_incr*post_ns)+offsets

;Add decreasing term for data post June 2021 disagreement
drop_2021 = dt0 gt fix2021-t0[k]
offsets = offsets - (lower*drop_2021)

return
end
;
;
;
