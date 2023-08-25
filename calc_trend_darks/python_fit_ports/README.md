MODEL SEPARATION INSTRUCTIONS:
===================================

Starting in 2022, the model moved from a continues model to one with distinct segments. This was done for simplicity and to ensure proper data processing. 
The model is now refit every so often (annually) into distinct segments
See the Documentation folder for history on this thought process
Below are the steps needed when a new model segment is to be created:

1. Determine the range of the new model segment. The model segments follow an alphabetical order (A, B, C...) and are typically separated at the end of a given year. 
	- The new model segment will be derived from data from BOTH the previous model segment and the new model segment
	- Model C is used to process data for 2022. To create model D, we will use data from BOTH 2022 and 2023. And then model D will be used on only 2023 data. 
	- This is done to avoid overweighting any point from a single year and improve the model fit. 
	- See the file Dark_Model_Summary.png in the Documentation folder for a visual summary
	
2. Determine the time where the model will be separated. This needs to be converted into the python format used by the GUI code. 
	- IDL (the format the data in the .sav file is stored in) utilizes anytim with a Jan 1st 1979 start time
	- Data times in the python GUI are generated with a Jan 1st 1979 start in mind
         - Python utilizes a Jan 1st 1970 start time, so a conversion factor is needed between the two
        - Conversion factor: self.convert = 284014800.0
        - To convert manually in Python, use: datetime.fromtimestamp(284014800+X).strftime("%m/%d/%Y %I:%M") to find the correct start time
        - Start with the previous model separation time as X and iterate until correct time is found. (Model B: self.seperation_B = 1.31025595e+09  equals 2020/07/08 11:59:59pm)
        
3. Copy the current model parameter file and rename for the new model segment (Copy Model_Parameters_B.txt and then rename new copy Model_Parameters_C.txt')

4. Run a normal model refit to optimize the fit FOR THE TIME PERIOD COVERED BY THE NEW MODEL!
	- This is where this may be a bit confusing so please read carefully here
	- At this point, the GUI script will still be optimizing all the way back to whenever the last separation was. (This is what we want!)
	- Example: If you are working to create Model D that will be used to cover 2023, at this point you will be optimizing over data from the start of 2022 through the end 2023. 
	- At this step, you are only looking to create a good new model for your latest segment, but will be using the previous segment's data as well to improve consistency and not over correct. 
	- THESE NEW PARAMETERS GENERATED HERE WILL ONLY BE USED FOR YOUR NEW SEGMENT. (The next steps here will detail how to perform the separation in the GUI code)
	- Find parameters that use data from previous segment and new segment that fit the model well. See further below for how to perform a standard refit. 
	
5. Print the results and update parameters in the NEW parameter file. (The one for your new model segment)

6. Now that we have 2 sets of parameters for the previous model segment AND for the new model segment, we can begin the process of separating the models
	- This entails updating the GUI code to have the previous model segment locked in and have the GUI iterate only on the latest segment and forward
	
8. Update the GUI code (fit_ports_gui_VX.py). I strongly recommend making a copy of the previous version and creating the next version during this process in case anything breaks
	- This work is pretty straight forward. Basically all you need to do is copy the previous format to shift the model segment forward. I have noted each section where changes are needed
	a.) In the 'Parameter Read In Section', you need to create a new section to read in parameters and update the previous one. Copy the previous block and paste a new one below. Change references to the previous letter to the new one including the new parameters.txt file.  In the previous one, create a new dictionary with the correct letter and change the current_dict variables in the section to the LETTER_dict. See previous versions and match. The code expects the latest model to be using current_dict for the parameters. 
	b.) In the 'Timing Section', create a new self.seperation_X variable for the start of the new model. (From step 2) Follow previous format
	c.) In the "Model Parameters Section', you will need to create a new set of parameters to be read in. Following the previous format, create a new set of parameters for the PREVIOUS model version following the correct letter format. The script is reading in the CURRENT parameters without needing this step, but you need to hard code in the parameters for the previous version. Just copy the previous and change the parameter names accordingly. 
	d.) In the "Model Trend Section', you will need to both create a new model and update the previous one to use the renamed parameters. First, copy the previous model and create a new entry. In the new entry, change all letter variables to the next one forward. ( NOTE: cport variable is not part of the letter scheme and stays the same. c is also a constant, so be sure you are only updating the parameters). In the previous model, change parameter names to include letter prefix (amp1 --> C_amp1) 
	
Congrats! Model separated! Save this new file and verify that it runs with your updates. It will now be iterating over the last year and moving forward. 
	
7. While it is tempting, DO NOT run another model refit immediately once the models are separated. This will give you a better fit over the segment, but won't be using data from the previous segment. 
	- This leads to over-fitting the model and defeats the purpose of using the previous year's worth of data. 
	
8. Update the iris_dark_trend_fix.pro file for the new version. This is the file that will actually be used in processing the data. 
	a.) Copy block of text that described the parameters for the previous model. Paste below in the same format. Update variables with new letter name and new parameter values. Copy from parameter text file. Update start time for this new segment to match model start time. 
	b.) Create a new model entry for the new model by copying and pasting the previous model. Update the parameters to use the new model (change the letters) and verify your model is of the same form (should be unless there were major changes in one of the refits)
	c.) Create a new array to determine the time that the new model will use. This works by creating arrays with 0s for times outside the model segment and 1 for times within the model segment. Then by multiplying the calculated model offsets by these arrays, we are only getting data for the correct model for the correct time. Create an array called Model_X_time with the correct letter. Modify the previous model time to end at the start of the new model. The new model time should start from that time. Follow previous formats. Add a new + (Model_X_offsets * Model_X_time) to the final offsets equation. Again, follow previous format. 
	d.) Double check that all parameter names and variables have been updated correctly. 
	e.) Run test to ensure update was properly done. To do this, use the 'iris_dark_trend_fix.pro' file. There is a line in there that should be commented out to print out the offsets. There is also an entry that shows the correct format in order to run this. (Also see below). You want to compare the point of separation to make sure it is correctly using each of the models. 
	* iris_dark_trend_fix, '2021/12/31T23:59:01', off, 'FUV' *
	
9. Send out new model with instructions for reprocessing. 
	
NOTE: If during the time between model segments a large disagreement is seen, it is OK to perform a model refit. 
	- Let's say that during May of one year, a large deviation is seen and a refit is needed
	- We can perform a refit so that data being processed isn't significantly off 
	- We can then process back to the point of the previous segment to improve fit
	- This data will be refit with an optimized model at the end of the year anyway
So you would:
	- Run the refit and print the parameters WITHOUT changing anything in the GUI (GUI will be iterating over previous segment and part of new segment)
	- Preserve previous segment parameters as these will be locked into the GUI at the end of the year (Should be stored in the iris_dark_trend.pro file but to be safe, store them)
	- Add a new code in the IRIS_DARK_TREND_FIX.pro file with new parameters to cover only most recent time
	- At the end of the year, these parameters you just added can be updated in the GUI file and whole year will be reprocessed with final version of the model
	
	EXAMPLE: 
	At the end of 2023, Model D was finalized and used to reprocess all of 2023 data.
	In May of 2024, of 
	
	Your code in IRIS_DARK_TREND_FIX.pro would then read:
	For Start of mission to Model_B_Start --> Use Model A parameters
	For Model_B_Start to Model_C_Start --> Use Model B parameters
	For Model_C_Start to Model_D_Start --> Use Model C parameters
	For Model_D_Start to NOW --> Use Model D parameters
	
	So instead of waiting until the end of the year to add a new segment, you would do so now and have 
	For Start of mission to Model_B_Start --> Use Model A parameters
	For Model_B_Start to Model_C_Start --> Use Model B parameters
	For Model_C_Start to Model_D_Start --> Use Model C parameters
	For Model_D_Start to Model_E_Start--> Use Model D parameters
	****For Model_E_Start to NOW --> Use TEMPORARY Model E parameters
	
	The model E parameters here would then be updated at the end of the year to their final version and all data from the previous year would be reprocessed. 


fit_ports_gui.py
================
A python GUI for fitting the long term pedestal trend of the IRIS CCDs. 
The program uses the sav file created by the main IDL program, 
so no additional file formatting required. 

The python GUI imports the following modules. I also included the version my code works with the modules
in case any future issues arise.

    a. matplotlib 2.0.0
    b. numpy 1.11.3
    c. Tkinter Revision: 81008
    d. scipy 1.0.0


To run the program type the following command in a terminal window:  
> python fit_ports_gui.py  


After typing the command you will be greeted with a GUI containing two plots.
The left and right plots contain the FUV and NUV, respectively, difference between the model pedestal and the measured dark
pedestal as a function of time. Both the FUV and NUV CCDs contain four ports for rapid read out of the CCD
 (port 1 = red circle, port 2 = blue square, port 3 = teal diamond, and port 4 = black triangle).
The plot also contains a model for the pedestal's evolution with the color corresponding to the port number. 
The model pedestal parameters' for CCD type and port are below their respective plots in the med row. Above and below 
the med row for each parameter is the maximum and minimum range to search for new parameters. The parameter range maybe 
set automatically by usieng the % Range text box in the bottom right of the gui.

When observed trend in a port consistently does not look like the model is the only reason to use the GUI.  
Fortunately, deviations from the trend do not happen to all ports at the same time.
Therefore, you are often only refitting a few port every three months,
which is why the GUI allow you to select the ports you want to refit.
Furthermore, the parameters not all parameters need refit every recalibration,
 which is why the GUI allows you to dynamic freeze some parameters. In the example below I only 
wanted to refit FUV port 3 for the Amplitude of the sin function. 
Selecting port and freezing parameters example below:   
[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/v3VH7uBjTJw/0.jpg)](http://www.youtube.com/watch?v=v3VH7uBjTJw)

In the above example using an infinite range worked well. Frequently, using an unrestricted range causes the 
program to find nonoptimal minimums. Therefore, I included a range box in the lower right. The range box
sets the minimum and maximum allowed value for all thawed parameters. Of course this example did not benefit from
a restricted range, but it is an outlier not the norm.
Setting parameter range example below:  
[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/1Nu14eoA0ww/0.jpg)](http://www.youtube.com/watch?v=1Nu14eoA0ww)

Finally, you will want to efficiently save new parameters. The GUI has the print button for that.
The print button print the new parameter values in a format for the iris_trend_fix program, as well as,
the initial_parameters.txt file.
Printing new parameters example below:  
[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/jC0AbvZRth8/0.jpg)](http://www.youtube.com/watch?v=jC0AbvZRth8)


initial_parameters.txt
----------------------
A file containing a list of initial parameters for the long term pedestal offset model. 
The format is the same as the format printed by fit_ports_gui.py (e.g. below).


\     Amp1      ,Amp2      ,P1             ,Phi1      ,Phi2      ,Trend               ,Quad                ,Offset    
fuv1=[ 0.16210  , 0.02622  ,  3.1504e+07   , 0.41599  , 0.09384  ,  2.819499502e-08   ,  5.705285157e-16   , -0.56933 ]  
fuv2=[ 0.25704  , 0.19422  ,  3.1568e+07   , 0.37571  , 0.89102  ,  2.832588907e-08   ,  4.108370809e-16   , -0.54180 ]  
fuv3=[ 1.46520  , 1.62863  ,  3.1522e+07   , 0.33362  , 0.87265  ,  2.618708232e-08   ,  1.219050166e-15   , -0.60404 ]  
fuv4=[ 0.27947  , 0.14585  ,  3.1383e+07   , 0.39938  , 0.90869  ,  1.880687110e-08   ,  9.619889318e-16   , -0.59357 ]  
nuv1=[ 0.55495  , 0.53251  ,  3.1782e+07   , 0.32965  , -0.07967 ,  3.995823558e-09   ,  2.297179460e-16   , -0.16966 ]  
nuv2=[ 0.73259  , 0.68243  ,  3.1841e+07   , 0.33437  , 0.92937  ,  3.278569052e-09   ,  2.743724242e-16   , -0.21646 ]  
nuv3=[ 0.26427  , 0.24439  ,  3.1696e+07   , 0.33597  , 0.91779  ,  1.004922804e-08   ,  3.098606381e-16   , -0.12297 ]  
nuv4=[ 0.41707  , 0.44189  ,  3.1642e+07   , 0.32680  , 0.90548  ,  7.943234757e-09   ,  3.284834996e-16   , -0.21366 ]  