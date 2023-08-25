
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
;                                       large amount of disagreement
;                                       being seen.   
progver = 'v2022.Jan.14' ;--- (Guliano) V28 (All Ports): All ports were refit following continued overestimates.
;                                       A new parameter (lower) was
;                                       added to bring the model down starting June 2021.
progver = 'v2022.Jul.22' ;--- (Guliano) V29 (All Ports): MAJOR CHANGE TO DARK MODEL.
;                                    Model data from the start of the
;                                    mission to 2020/07/09 (Model A) was
;                                    optimized and LOCKED IN. THIS
;                                    DATA WILL NO LONGER BE ADJUSTED.
; Data from 2022/07/09 onward (Model B) was fitted with a new and simplified model that 
; will continue to be adjusted moving forward. Returns to simple model
; with original 8 parameters and modifier parameters were removed                                  
progver = 'v2023.Jan.20' ;--- (Guliano) V30 (All Ports): Model C was created to cover data from 2022. 
;                                       Utilizes data from 2020/07/09
;                                       through 12/2022. Model B now
;                                       stops at 2021/12/31. New
;                                       parameters for Model C added.   
progver = 'v2023.Jun.01' ;--- (Guliano) V31 (All Ports): First, model C was updated to run from 01/01/2022 to 11/01/2022 for better fit. A new model D was created to cover from that date forward with all ports being updated to reflect a decrease seen across the ports.   ;
;
progver = 'v2023.Aug.11' ;--- (Guliano) V32 (All Ports): Minor adjustments to all ports due to larger than expected decrease.                            
; ============================================================================                                                     ;
;-
; ============================================================================ 


ins = index.instrume ne 'FUV'

k=indgen(4)  + ins*4                          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                              ******MODEL A**********
;              PARAMETERS COVERING MODEL FROM 2014 to 2022/07/08
;                               DO NOT ADJUST!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;      Amp1      Amp2         P1       Phi1      Phi2         Lin             Quad           Offset     Scale     OffDrop    AmpInc     OffNSop    
A_fuv1=[ 0.22504, 0.14123,  3.2876e+07, 0.57710 , 1.27583,  2.688194354e-08,  6.027637770e-16, -0.51376,   0.21860,   0.27468,  11.12696,   0.79547]
A_fuv2=[ 0.28405, 0.22782,  3.1761e+07, 0.39463 , 0.91922,  2.726109985e-08,  4.380741231e-16, -0.52228,   0.32913,   0.30626,   4.28409,   0.45041]
A_fuv3=[ 1.65115, 1.63702,  3.1643e+07, 0.34131 , 0.88297,  2.648864226e-08,  1.274301392e-15, -0.70601,   0.05882,   0.17961,   0.96134,   1.94921]
A_fuv4=[ 0.32979, 0.23508,  3.2168e+07, 0.48204 , 1.03840,  1.540202648e-08,  1.049035742e-15, -0.47445,   0.12195,   0.22495,   9.10567,   1.01930]
A_nuv1=[ 0.58894, 0.55962,  3.1648e+07, 0.32813, -0.09963,  4.898462163e-09,  2.070366876e-16, -0.22547,   0.17021,   0.41487,   0.58865,   0.37707]
A_nuv2=[ 0.72862, 0.68366,  3.1665e+07, 0.32753 , 0.89597,  3.518766768e-09,  2.866893629e-16, -0.22624,   0.12186,   0.33818,   0.56151,   0.34956]
A_nuv3=[ 0.27157, 0.24522,  3.1635e+07, 0.34720 , 0.89485,  9.403417868e-09,  3.724874287e-16, -0.10939,   0.19875,   0.18738,   1.25642,   0.21802]
A_nuv4=[ 0.45593, 0.45128,  3.1626e+07, 0.33509 , 0.90171,  8.337784755e-09,  3.418901087e-16, -0.25099,   0.23615,   0.28125,   0.53626,   0.03761]

;FUV for Model A
if ins eq 0 then begin                     ; if FUV, load up variables
   A_amp1=[A_fuv1(0),A_fuv2(0),A_fuv3(0),A_fuv4(0)]   ; amp of variation with period p1
   A_amp2=[A_fuv1(1),A_fuv2(1),A_fuv3(1),A_fuv4(1)]  ; amp of variation with period p1/2
   A_p1=[A_fuv1(2),A_fuv2(2),A_fuv3(2),A_fuv4(2)]    ; period of main variation [s]
   A_phi1=[A_fuv1(3),A_fuv2(3),A_fuv3(3),A_fuv4(3)]  ; phase offset for p=p1 variation
   A_phi2=[A_fuv1(4),A_fuv2(4),A_fuv3(4),A_fuv4(4)]  ; phase offset for p=p1/2 variation
   A_lin=[A_fuv1(5),A_fuv2(5),A_fuv3(5),A_fuv4(5)] ; linear long-term trend
   A_quad=[A_fuv1(6),A_fuv2(6),A_fuv3(6),A_fuv4(6)]  ;  quadratic term
   A_off=[A_fuv1(7),A_fuv2(7),A_fuv3(7),A_fuv4(7)]   ; offset constant
   A_scl=[A_fuv1(8),A_fuv2(8),A_fuv3(8),A_fuv4(8)]   ; Rescaling trend after given time 
   A_off_drop=[A_fuv1(9),A_fuv2(9),A_fuv3(9),A_fuv4(9)]   ; Rescaling intercept after bake out in June 2018
   A_amp_incr=[A_fuv1(10),A_fuv2(10),A_fuv3(10),A_fuv4(10)]   ; Rescaling amplitudes after bake out in June 2018
   A_off_incr=[A_fuv1(11),A_fuv2(11),A_fuv3(11),A_fuv4(11)]   ; Increasing the offset term following non-standard IRIS operations starting in Dec. 2018
   dtq0 = 5e7                               ; start time, quad term
   tq_end = 1.295e8                         ; end time, quad term
;NUV for Model A
endif else begin                          ; if NUV/SJI
   A_amp1=[A_nuv1(0),A_nuv2(0),A_nuv3(0),A_nuv4(0)]
   A_amp2=[A_nuv1(1),A_nuv2(1),A_nuv3(1),A_nuv4(1)]
   A_p1=[A_nuv1(2),A_nuv2(2),A_nuv3(2),A_nuv4(2)]
   A_phi1=[A_nuv1(3),A_nuv2(3),A_nuv3(3),A_nuv4(3)]
   A_phi2=[A_nuv1(4),A_nuv2(4),A_nuv3(4),A_nuv4(4)]
   A_lin=[A_nuv1(5),A_nuv2(5),A_nuv3(5),A_nuv4(5)]
   A_quad=[A_nuv1(6),A_nuv2(6),A_nuv3(6),A_nuv4(6)]
   A_off=[A_nuv1(7),A_nuv2(7),A_nuv3(7),A_nuv4(7)]
   A_scl=[A_nuv1(8),A_nuv2(8),A_nuv3(8),A_nuv4(8)]   ; Rescaling trend after given time 
   A_off_drop=[A_nuv1(9),A_nuv2(9),A_nuv3(9),A_nuv4(9)]   ; Rescaling intercept after bake out in June 2018
   A_amp_incr=[A_nuv1(10),A_nuv2(10),A_nuv3(10),A_nuv4(10)]   ; Rescaling amplitudes after bake out in June 2018
   A_off_incr=[A_nuv1(11),A_nuv2(11),A_nuv3(11),A_nuv4(11)]   ; Increasing the offset term following non-standard IRIS operations starting in Dec. 2018
   dtq0 = 7e7                               ; start time, quad term
   tq_end = 1.295e8                               ; end time, quad term
endelse


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                              ******MODEL B**********
;              PARAMETERS COVERING 2020/07/09 through 2021/12/31
;                               DO NOT ADJUST!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;        Amp1      Amp2         P1             Phi1      Phi2           Lin                 Quad           Offset 
B_fuv1=[ 0.09694  , 0.21753  ,  2.9936e+07   , 0.07824  , 0.06349  ,  3.085653174e-28   ,  1.525218636e-19   , 11.35675 ]
B_fuv2=[ 0.23372  , 0.28808  ,  3.0710e+07   , 0.13176  , 0.42573  ,  3.459347456e-28   ,  1.654071242e-19   , 10.48543 ]
B_fuv3=[ 1.71215  , 2.03107  ,  3.0976e+07   , 0.16851  , 0.56506  ,  3.009511127e-10   ,  -3.554634104e-18  , 14.99669 ]
B_fuv4=[ 0.20105  , 0.31999  ,  2.9871e+07   , -0.10259 , -0.02492 ,  1.380340229e-11   ,  -4.190107715e-18  , 12.58521 ]
B_nuv1=[ 0.60380  , 0.61525  ,  3.0825e+07   , 0.12776  , -0.51741 ,  1.386837464e-29   ,  5.929546679e-21   , 2.31754  ]
B_nuv2=[ 0.72822  , 0.77593  ,  3.0860e+07   , 0.13780  , 0.49530  ,  1.669404226e-28   ,  8.101393357e-20   , 2.43615  ]
B_nuv3=[ 0.27805  , 0.31907  ,  3.0913e+07   , 0.16475  , 0.53237  ,  1.839560687e-29   ,  5.267296998e-21   , 4.30594  ]
B_nuv4=[ 0.45343  , 0.49038  ,  3.0859e+07   , 0.15163  , 0.49575  ,  2.079848910e-28   ,  1.014358772e-19   , 3.81356  ]

;FUV for Model B
if ins eq 0 then begin                     ; if FUV, load up variables
   B_amp1=[B_fuv1(0),B_fuv2(0),B_fuv3(0),B_fuv4(0)]   ; amp of variation with period p1
   B_amp2=[B_fuv1(1),B_fuv2(1),B_fuv3(1),B_fuv4(1)]  ; amp of variation with period p1/2
   B_p1=  [B_fuv1(2),B_fuv2(2),B_fuv3(2),B_fuv4(2)]    ; period of main variation [s]
   B_phi1=[B_fuv1(3),B_fuv2(3),B_fuv3(3),B_fuv4(3)]  ; phase offset for p=p1 variation
   B_phi2=[B_fuv1(4),B_fuv2(4),B_fuv3(4),B_fuv4(4)]  ; phase offset for p=p1/2 variation
   B_lin= [B_fuv1(5),B_fuv2(5),B_fuv3(5),B_fuv4(5)] ; linear long-term trend
   B_quad=[B_fuv1(6),B_fuv2(6),B_fuv3(6),B_fuv4(6)]  ;  quadratic term
   B_off= [B_fuv1(7),B_fuv2(7),B_fuv3(7),B_fuv4(7)]   ; offset constant
   ;STARTING TIME FOR MODEL B
   Model_B_Start  = 1.31025595e+09 

;NUV for Model B
endif else begin                          ; if NUV/SJI
   B_amp1=[B_nuv1(0),B_nuv2(0),B_nuv3(0),B_nuv4(0)]
   B_amp2=[B_nuv1(1),B_nuv2(1),B_nuv3(1),B_nuv4(1)]
   B_p1=  [B_nuv1(2),B_nuv2(2),B_nuv3(2),B_nuv4(2)]
   B_phi1=[B_nuv1(3),B_nuv2(3),B_nuv3(3),B_nuv4(3)]
   B_phi2=[B_nuv1(4),B_nuv2(4),B_nuv3(4),B_nuv4(4)]
   B_lin=[B_nuv1(5),B_nuv2(5),B_nuv3(5),B_nuv4(5)]
   B_quad=[B_nuv1(6),B_nuv2(6),B_nuv3(6),B_nuv4(6)]
   B_off=[B_nuv1(7),B_nuv2(7),B_nuv3(7),B_nuv4(7)]
   ;STARTING TIME FOR MODEL B
   Model_B_Start = 1.31025595e+09 ;2020/07/08 11:59pm

endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                              ******MODEL C**********
;              PARAMETERS COVERING 2022/01/01 through 2022/11/01
;                               DO NOT ADJUST!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;        Amp1      Amp2         P1             Phi1      Phi2           Lin                 Quad           Offset 
C_fuv1=[ 0.12657  , 0.22457  ,  2.9702e+07   , -0.03916 , -0.08545 ,  3.250413962e-10   ,  -1.611625494e-18  , 11.35661 ]
C_fuv2=[ 0.29034  , 0.29229  ,  3.0500e+07   , 0.08523  , 0.31209  ,  8.866168829e-10   ,  -4.126666799e-18  , 10.48483 ]
C_fuv3=[ 1.66409  , 2.03024  ,  3.0855e+07   , 0.15222  , 0.49300  ,  2.030364456e-08   ,  -8.364926755e-17  , 14.99549 ]
C_fuv4=[ 0.23380  , 0.31245  ,  3.0023e+07   , -0.02528 , 0.05283  ,  3.696596760e-09   ,  -1.899870450e-17  , 12.58396 ]
C_nuv1=[ 0.60380  , 0.61525  ,  3.0825e+07   , 0.12776  , -0.51741 ,  4.365519501e-28   ,  1.381746022e-19   , 2.31754  ]
C_nuv2=[ 0.69213  , 0.74576  ,  3.1342e+07   , 0.27244  , 0.74656  ,  -1.496726904e-09  ,  5.776993217e-18   , 2.43614  ]
C_nuv3=[ 0.28873  , 0.31987  ,  3.1396e+07   , 0.30258  , 0.78026  ,  1.615616359e-09   ,  -6.488810056e-18  , 4.30558  ]
C_nuv4=[ 0.45455  , 0.48908  ,  3.0980e+07   , 0.18911  , 0.55671  ,  -6.365715445e-10  ,  2.272330252e-18   , 3.81355  ]

;FUV for Model C
if ins eq 0 then begin                     ; if FUV, load up variables
   C_amp1=[C_fuv1(0),C_fuv2(0),C_fuv3(0),C_fuv4(0)]   ; amp of variation with period p1
   C_amp2=[C_fuv1(1),C_fuv2(1),C_fuv3(1),C_fuv4(1)]  ; amp of variation with period p1/2
   C_p1=  [C_fuv1(2),C_fuv2(2),C_fuv3(2),C_fuv4(2)]    ; period of main variation [s]
   C_phi1=[C_fuv1(3),C_fuv2(3),C_fuv3(3),C_fuv4(3)]  ; phase offset for p=p1 variation
   C_phi2=[C_fuv1(4),C_fuv2(4),C_fuv3(4),C_fuv4(4)]  ; phase offset for p=p1/2 variation
   C_lin= [C_fuv1(5),C_fuv2(5),C_fuv3(5),C_fuv4(5)] ; linear long-term trend
   C_quad=[C_fuv1(6),C_fuv2(6),C_fuv3(6),C_fuv4(6)]  ;  quadratic term
   C_off= [C_fuv1(7),C_fuv2(7),C_fuv3(7),C_fuv4(7)]   ; offset constant
   ;STARTING TIME FOR MODEL C
   Model_C_Start  = 1.3569984e+09 ;2022/01/01 12:00am

;NUV for Model C
endif else begin                          ; if NUV/SJI
   C_amp1=[C_nuv1(0),C_nuv2(0),C_nuv3(0),C_nuv4(0)]
   C_amp2=[C_nuv1(1),C_nuv2(1),C_nuv3(1),C_nuv4(1)]
   C_p1=  [C_nuv1(2),C_nuv2(2),C_nuv3(2),C_nuv4(2)]
   C_phi1=[C_nuv1(3),C_nuv2(3),C_nuv3(3),C_nuv4(3)]
   C_phi2=[C_nuv1(4),C_nuv2(4),C_nuv3(4),C_nuv4(4)]
   C_lin= [C_nuv1(5),C_nuv2(5),C_nuv3(5),C_nuv4(5)]
   C_quad=[C_nuv1(6),C_nuv2(6),C_nuv3(6),C_nuv4(6)]
   C_off= [C_nuv1(7),C_nuv2(7),C_nuv3(7),C_nuv4(7)]
   ;STARTING TIME FOR MODEL C
   Model_C_Start = 1.3569984e+09 ;2022/01/01 12:00am

endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                              ******MODEL D**********
;              PARAMETERS COVERING 2022/11/01 through 2023/12/31
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;        Amp1      Amp2         P1             Phi1      Phi2           Lin                 Quad           Offset 
D_fuv1=[ 0.11270  , 0.12196  ,  2.9715e+07   , -0.00000 , -0.15673 ,  -3.802984336e-10  ,  -2.074162011e-17  , 12.89842 ]
D_fuv2=[ 0.23160  , 0.26085  ,  3.0852e+07   , 0.00047  , 0.35883  ,  1.492734321e-11   ,  -3.253508431e-17  , 12.49973 ]
D_fuv3=[ 1.51628  , 1.55313  ,  3.0984e+07   , 0.15444  , 0.51026  ,  1.553228809e-08   ,  -1.058163234e-16  , 17.50802 ]
D_fuv4=[ 0.18938  , 0.26532  ,  3.0296e+07   , -0.02781 , 0.06392  ,  2.994243376e-09   ,  -2.298843244e-17  , 12.71879 ]
D_nuv1=[ 0.60374  , 0.61519  ,  3.1037e+07   , 0.19164  , -0.43397 ,  -4.551473749e-10  ,  1.381864698e-19   , 2.31777  ]
D_nuv2=[ 0.64218  , 0.65171  ,  3.1349e+07   , 0.26782  , 0.73745  ,  -9.898691283e-10  ,  3.177344676e-18   , 2.42533  ]
D_nuv3=[ 0.21610  , 0.25537  ,  3.1684e+07   , 0.33067  , 0.94706  ,  8.142541541e-10   ,  -1.070653659e-17  , 4.70490  ]
D_nuv4=[ 0.34902  , 0.36050  ,  3.1267e+07   , 0.24126  , 0.71042  ,  -1.145820997e-09  ,  1.136051513e-18   , 3.74757  ]

;FUV for Model C
if ins eq 0 then begin                     ; if FUV, load up variables
   D_amp1=[D_fuv1(0),D_fuv2(0),D_fuv3(0),D_fuv4(0)]   ; amp of variation with period p1
   D_amp2=[D_fuv1(1),D_fuv2(1),D_fuv3(1),D_fuv4(1)]  ; amp of variation with period p1/2
   D_p1=  [D_fuv1(2),D_fuv2(2),D_fuv3(2),D_fuv4(2)]    ; period of main variation [s]
   D_phi1=[D_fuv1(3),D_fuv2(3),D_fuv3(3),D_fuv4(3)]  ; phase offset for p=p1 variation
   D_phi2=[D_fuv1(4),D_fuv2(4),D_fuv3(4),D_fuv4(4)]  ; phase offset for p=p1/2 variation
   D_lin= [D_fuv1(5),D_fuv2(5),D_fuv3(5),D_fuv4(5)] ; linear long-term trend
   D_quad=[D_fuv1(6),D_fuv2(6),D_fuv3(6),D_fuv4(6)]  ;  quadratic term
   D_off= [D_fuv1(7),D_fuv2(7),D_fuv3(7),D_fuv4(7)]   ; offset constant
   ;STARTING TIME FOR MODEL D
   Model_D_Start = 1.3832605e+09 ;2022/11/01 12:01am

;NUV for Model C
endif else begin                          ; if NUV/SJI
   D_amp1=[D_nuv1(0),D_nuv2(0),D_nuv3(0),D_nuv4(0)]
   D_amp2=[D_nuv1(1),D_nuv2(1),D_nuv3(1),D_nuv4(1)]
   D_p1=  [D_nuv1(2),D_nuv2(2),D_nuv3(2),D_nuv4(2)]
   D_phi1=[D_nuv1(3),D_nuv2(3),D_nuv3(3),D_nuv4(3)]
   D_phi2=[D_nuv1(4),D_nuv2(4),D_nuv3(4),D_nuv4(4)]
   D_lin= [D_nuv1(5),D_nuv2(5),D_nuv3(5),D_nuv4(5)]
   D_quad=[D_nuv1(6),D_nuv2(6),D_nuv3(6),D_nuv4(6)]
   D_off= [D_nuv1(7),D_nuv2(7),D_nuv3(7),D_nuv4(7)]
   ;STARTING TIME FOR MODEL D
   Model_D_Start = 1.3832605e+09 ;2022/11/01 12:01am

endelse

;;;;;;;;;;;;;;;;;;;;;;;;Times needed for Model A;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
t=anytim(index.date_obs)

c=2*!pi

dt0 = t - t0[k]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       MODEL A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dtq = dt0 > dtq0                   ; Removed quadratic end time 
dtq = dtq - dtq0                   ; timeline for quad term, for dt0>dtq0

tred = (dt0 gt tq_end)             ; times > when lin+quad trend are reduced 
                                   ;  (tq_end is now where trends are reduced)
adj = 1.0 - tred*(1.0-A_scl)         ; rescale at trend change boundary: 
                                ;      1->scl

; Change offset across boundary so trend is continuous 
toff = (1.0-A_scl)*(A_quad*(tq_end-dtq0)^2+A_lin*tq_end)+A_off ; new boundary value 
A_off = A_off*(tred ne 1) + toff*tred  ; apply new boundary when t>tq_end

model_A_offsets = A_amp1 *sin(c*(dt0/A_p1 + A_phi1)) +  $
           A_amp2 *sin(c*(dt0/(A_p1/2) + A_phi2)) +  $
           A_lin*adj*dt0  + adj*A_quad*dtq^2 + A_off 

;Times after the June 2018 bake out but before then Dec. return from coarse control 2019/01/22 J. Prchlik
post_bo = ((dt0 gt bojune152018-t0[k]) and (dt0 lt nsdec152018-t0[k]))

;Adjust offsets after June 2018 bake out
drop_offset_june2018 = -(A_off_drop)*A_off

;Amplitudes adjusted after June 2018 bake out
incs_amplit_june2018 = ((A_amp1*sin(c*(dt0/A_p1+A_phi1)))+(A_amp2*sin(c*(dt0/(A_p1/2.)+A_phi2))))*A_amp_incr

;Times following the non-standard IRIS operations from Oct. 27-Dec. 15, 2018
post_ns = dt0 ge nsdec152018-t0[k]

;Add new bake out scaling to trend
model_A_offsets = (drop_offset_june2018+incs_amplit_june2018)*post_bo+model_A_offsets

;Add non-standard IRIS operations change in pedestal level to the trend
;Oct. 27-Dec. 15
model_A_offsets = (A_off_incr*post_ns)+model_A_offsets

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       MODEL B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
model_B_offsets = B_amp1 *sin(c*(dt0/B_p1 + B_phi1)) +  $
           B_amp2 *sin(c*(dt0/(B_p1/2) + B_phi2)) +  $
           B_lin*dt0  + B_quad*dt0^2 + B_off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       MODEL C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
model_C_offsets = C_amp1 *sin(c*(dt0/C_p1 + C_phi1)) +  $
           C_amp2 *sin(c*(dt0/(C_p1/2) + C_phi2)) +  $
           C_lin*dt0  + C_quad*dt0^2 + C_off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       MODEL D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
model_D_offsets = D_amp1 *sin(c*(dt0/D_p1 + D_phi1)) +  $
           D_amp2 *sin(c*(dt0/(D_p1/2) + D_phi2)) +  $
           D_lin*dt0  + D_quad*dt0^2 + D_off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Choose which model to derrive the offsets from
;Creates array to show what times each model should be used. 

model_A_time = (dt0 lt model_B_start - t0[k])
model_B_time = (dt0 ge model_B_start - t0[k]) and (dt0 lt model_C_start - t0[k])
model_C_time = (dt0 ge model_C_start - t0[k]) and (dt0 lt model_D_start - t0[k])
model_D_time = (dt0 ge model_D_start - t0[k])

;will be 1 for correct model and 0 for incorect
;creating a final offsets array using only correct models
offsets =  (model_A_offsets*model_A_time) + (model_B_offsets*model_B_time) + (model_C_offsets*model_C_time) + (model_D_offsets*model_D_time)

return
end
;
;
;
