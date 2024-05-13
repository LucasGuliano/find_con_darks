import matplotlib
matplotlib.rcParams['font.size'] = 8

#Use TkAgg backend for plotting 
matplotlib.use('TkAgg',warn=False,force=True)

from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
#implement the deault mpl key bindings
from matplotlib.backend_bases import key_press_handler,MouseEvent
import numpy as np
import sys
import matplotlib.pyplot as plt
from datetime import datetime
from scipy.optimize import curve_fit
from fancy_plot import fancy_plot

#check the python version to use one Tkinter syntax or another
if sys.version_info[0] < 3:
    import Tkinter as Tk
    import tkMessageBox as box
    import tkFileDialog as Tkf
    import tkFont
else:
    import tkinter as Tk
    from tkinter import messagebox as box
    from tkinter import filedialog as Tkf
    from tkinter import font as tkFont

class gui_dark(Tk.Frame):

    def __init__(self,parent):
        """
        Program to fit the long term evolution of the IRIS pedestal.
        tcsh>python fit_ports_gui.py
        However, there will be times when this code should be modified. For example, following a prolonged bake out like the one from June 13-15, 2018.
        In that case the code modification will still be small and the exact functions you will need to edit will be specified below.
        The one thing you will need to change every time you preform a model dark pedestal recalibration is the initial_parameters.txt file in this
        directory. This file contains 9 lines. The first line is the Comma sepearated parameter header. The header information matters because it 
        is read by this GUI and used to create parameter list you see below the plots in the GUI and the "Freeze Par." check boxes. The next lines are
        the values for each parameter, comma separated, for each port, specified on the left. The GUI will read those parameters from the file and 
        create the long term trend on the plot and set the value in median text box for each parameter. The reason the file is formatted this way
        is that the iris_dark_trend_fix.pro expects the parameters in this format, so you can copy and paste the values from initial_parameters.txt
        into the newest version of iris_dark_trend_fix.pro. See the README at 
        https://github.com/jprchlik/find_contaminated_darks/tree/master/calc_trend_darks/python_fit_ports for detailed information on refitting a 
        model. This page includes video examples on refitting model parameters.
        Now if you are ever unfortunate enough to have to redefine the IRIS dark pedestal model, then you will need to make a few modifications to 
        this code. Fortunately, you will not have to add the new parameter names in manually because that is done automatically by the list of 
        parameters in the header of initial_parameters.txt. You will need to change the offset function in this module. The reason for this
        is the code needs to know how to handle to new parameters you are giving it. You will need to also add the new variable names and 
        values to the Print function in this module. The reason you have to add the Print explicitly is I do not know a priori the best format
        for printing whatever variable you add. After you bend those two short funcitons to your will, no further modifications of the
        code are needed.

        UPDATED BY LRG end of 2021 to improve readability and implement new variable.

        V3 NOTES:
        THE MODEL IS NO LONGER CONTINUOUS! Version 3 of this GUI treats the model in seperate parts. 
        MODEL A covers early mission data. These parameters are locked in and in the Model_A_Parameters.txt file
        It is now planned that the model will be seperated every so often and parameters will no longer be adjusted for the past. 
        This GUI will NOT adjust parameters for previous models, as these should not be changed. 
        
        V4 NOTES:
        Model D covers 2023, added some data printing features
        
        V5 NOTES:
        Model E covers 2024
        
        ***Please see the 'Model_Seperation_README" file for instruction on how to create a new model segment.***
        
        Models describe the following time periods:
        MODEL A: 2014 to July 8th, 2020 23:59:59
        MODEL B: July 9th, 2020 to December 31st, 2021
        MODEL C: January 1st, 2022 to November 1st, 2022
        MODEL D: Janaury 1st, 2023 to .......
        
        """
        Tk.Frame.__init__(self,parent,background='white') #create initial frame with white background

        #dictionary of initial Guess parameters (Manually update with the previous version of trend fix 
        #This should always be utilized for parameters related to the CURRENT model
        self.current_dict = {}

        #create a variable which switch to true after creating a plot once
        self.lat_plot = False
        
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
        # A) PARAMETER READ IN SECTION      #
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
        
###################  FIRST SET OF PARAMETERS ############################
# From 2014 to 20220709

        #dictionary of MODEL A parameters (DO NOT ADJUST. THESE ARE NOW LOCKED IN)
        self.A_dict = {}
        
        Afile = open('Model_A_Parameters.txt','r')

        #read input parameters from file
        for i,line in enumerate(Afile):
           
            #remove whitespace and brackets
            line = line.replace(' ','').replace('[','').replace(']','')
            #Use the header to label all the columns
            if i == 0: self.plis=line.split(',')
            #else read in parameters
            else:
                sline = line.split('=')
                #create parameter lis for dictionary input
                self.A_dict[sline[0]] = [float(j) for j in sline[1].split(',')]

        #close parameter file
        Afile.close()    
        
###################    Model B    #####################
        #dictionary of MODEL B parameters (DO NOT ADJUST. THESE ARE NOW LOCKED IN)
        self.B_dict = {}
        Bfile = open('Model_B_Parameters.txt','r')
        #read input parameters from file
        for i,line in enumerate(Bfile):
            #remove whitespace and brackets
            line = line.replace(' ','').replace('[','').replace(']','')
            #Use the header to label all the columns
            if i == 0: self.plis=line.split(',')
            #else read in parameters
            else:
                sline = line.split('=')
                #create parameter lis for dictionary input
                self.B_dict[sline[0]] = [float(j) for j in sline[1].split(',')]
        #close parameter file
        Bfile.close()

###################    Model C    #####################      
        #dictionary of MODEL C parameters (DO NOT ADJUST. THESE ARE NOW LOCKED IN)
        self.C_dict = {}
        Cfile = open('Model_C_Parameters.txt','r')
        #read input parameters from file
        for i,line in enumerate(Cfile):
            #remove whitespace and brackets
            line = line.replace(' ','').replace('[','').replace(']','')
            #Use the header to label all the columns
            if i == 0: self.plis=line.split(',')
            #else read in parameters
            else:
                sline = line.split('=')
                #create parameter lis for dictionary input
                self.C_dict[sline[0]] = [float(j) for j in sline[1].split(',')]
        #close parameter file
        Cfile.close()        

###################    Model D    #####################
        #When adding new model, change this dict from current_dict to LETTER_dict
        self.D_dict = {}
        Dfile = open('Model_D_Parameters.txt','r')
        #read input parameters from file
        for i,line in enumerate(Dfile):
            #remove whitespace and brackets
            line = line.replace(' ','').replace('[','').replace(']','')
            #Use the header to label all the columns
            if i == 0: self.plis=line.split(',')
            #else read in parameters
            else:
                sline = line.split('=')
                #create parameter lis for dictionary input
                self.D_dict[sline[0]] = [float(j) for j in sline[1].split(',')]
        #close parameter file
        Dfile.close()           
        
###################    Model E    #####################
        #When adding new model, change this dict from current_dict to LETTER_dict
        Efile = open('Model_E_Parameters.txt','r')
        #read input parameters from file
        for i,line in enumerate(Efile):
            #remove whitespace and brackets
            line = line.replace(' ','').replace('[','').replace(']','')
            #Use the header to label all the columns
            if i == 0: self.plis=line.split(',')
            #else read in parameters
            else:
                sline = line.split('=')
                #create parameter lis for dictionary input
                self.current_dict[sline[0]] = [float(j) for j in sline[1].split(',')]
        #close parameter file
        Efile.close()           
        
#######################################################################

        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
        # B) TIMING SECTION                #
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#  
      
        #IDL utilizes anytim with a Jan 1st 1979 start time
        #Data times here are generated with a Jan 1st 1979 start in mind
        #Python utilizes a Jan 1st 1970 start time
        #Value to convert start time in IDL to Python datetime start
        self.convert = 284014800.0
        #To convert manually in Python, use: datetime.fromtimestamp(284014800+X).strftime("%m/%d/%Y %I:%M") 
    
        #dictionary of time offsets (i.e. start times in IDL anytim format)
        self.t0dict = {}
        self.t0dict['fuv1'] = 1090654728.
        self.t0dict['fuv2'] = 1089963933.
        self.t0dict['fuv3'] = 1090041516.
        self.t0dict['fuv4'] = 1090041516.
        self.t0dict['nuv1'] = 1090037115. 
        self.t0dict['nuv2'] = 1090037115.
        self.t0dict['nuv3'] = 1090037185.
        self.t0dict['nuv4'] = 1090037185.

        #dictionary of when to start the quadratic term for the fit
        self.dtq0 = {}
        self.dtq0['fuv'] = 5.e7 #02/23/2015 
        self.dtq0['nuv'] = 7.e7 #10/05/2015

        #dictionary of when to end the quadratic term for the fit
        self.dtq1 = {}
        #Time where Quadratic term is flattened 2018/05/25 J. Prchlik
        self.dtq1['fuv'] = 1.295e8 #08/31/2017
        self.dtq1['nuv'] = 1.295e8

        ################################################
        #Add the June 13-15th bake out to the dropped pedestal level
        #unit s from 1-jan-1958 based on anytim from IDL 
        self.bojune152018 = 1.2450240e+09

        #Add non-standard telescope operations following IRIS coarse control
        #From Oct. 28 - Dec. 15 2018 (Added 2019/01/10 J. Prchlik)
        self.nsdec152018  = 1.2608352e+09
    
        #################################################################
        # SEPERATE MODEL AT GIVEN TIME AND FREEZE PARAMETERS BEFORE     #
        #                     Start of Model B                          #
        #                       07/09/2020                              #
        #################################################################
        self.seperation_B = 1.31025595e+09  #2020/07/08 11:59:59pm
        
        ############s#####################################################
        #                     Start of Model C                          #
        #                       01/01/2022                              #
        #################################################################
        self.seperation_C = 1.3569984e+09  #2022/01/01 12:00:00am
        
        ################################################
        
        ############s#####################################################
        #                     Start of Model D                          #
        #                       01/01/2022                              #
        #################################################################
        self.seperation_D = 1.3832605e+09 #11/01/2022 12:01
        ################################################
        
        ############s#####################################################
        #                     Start of Model E                          #
        #                       01/01/2022                              #
        #################################################################
        self.seperation_E = 1.4200705e+09 #01/01/2024 12:01
        ################################################

        #basic set of keys
        self.current_keys = sorted(self.current_dict.keys())
        #add min and max parameters (Default no restriction)
        for i in self.current_keys:
            self.current_dict[i+'_min'] = [-np.inf]*len(self.current_dict[i])
            self.current_dict[i+'_max'] = [ np.inf]*len(self.current_dict[i])

        #set up initial dictionary of guesses
        self.idict = self.current_dict.copy()

        #initialize scaling limit variable
        self.sc_limit = None

        #add parameter code corresponding to position
        self.p_code = {}
        for j,i in enumerate(self.plis):
            self.p_code['{0:1d}'.format(j)] = i

        #create parent variable
        self.parent = parent

        #Start the creation of the window and GUI
        self.centerWindow()
        self.FigureWindow()
        self.initUI()
        self.iris_dark_set()
        self.iris_dark_plot()


    #Create area and window for figure
    def FigureWindow(self):
        """
        This function creates a GUI window with a given size and format
        Args
        ------
        self: class
            The GUI class in this module
   
        Returns
        --------
            None
        """

#set the information based on screen size
        x =  self.parent.winfo_screenwidth()*0.5
        y =  (self.parent.winfo_screenheight())*1.0

        irisframe = Tk.Frame(self)

        aratio = float(x)/float(y)
        #Create the figure
        self.f,self.a = plt.subplots(ncols=2,figsize=(12*aratio,8*aratio*.75),sharex=True)
        #Separate the two plotting windows fuv and nuv
        self.wplot = {}
        self.wplot['fuv'] = self.a[0]
        self.wplot['nuv'] = self.a[1]

        #set title and axis labels
        for i in self.wplot.keys(): 
            self.wplot[i].set_title(i.upper())
            self.wplot[i].set_xlabel('Offset Time [s]')
            self.wplot[i].set_ylabel('Pedestal Offset [ADU]')

        #Create window for the plot
        self.canvas = FigureCanvasTkAgg(self.f,master=self)
        #Draw the plot
        self.canvas.draw()
        #Turn on matplotlib widgets
        self.canvas.get_tk_widget().pack(side=Tk.TOP,fill=Tk.BOTH,expand=1)
        #Display matplotlib widgets
        self.toolbar = NavigationToolbar2TkAgg(self.canvas,self)
        self.toolbar.update()
        self.canvas._tkcanvas.pack(side=Tk.TOP,fill=Tk.BOTH,expand=1)

        irisframe.pack(side=Tk.TOP)

#Create window in center of screen
    def centerWindow(self):
        """
        This function sets the size of the GUI window based on the screen size. Can cause problems for small screens.
        Args
        ------
        self: class
            The GUI class in this module
   
        Returns
        --------
            None
        """
        self.w = 1800/1
        self.h = 1200/1
        sw = self.parent.winfo_screenwidth()
        sh = self.parent.winfo_screenheight()

        self.h = self.w*float(sh)/float(sw)

        self.x = (sw-self.w)/2
        self.y = (sh-self.h)/2
        #self.parent.geometry('%dx%d+%d+%d' % (self.w,self.h,self.x,self.y))
        self.parent.geometry('%dx%d+0+0' % (sw,sh))


#Initialize the GUI
    def initUI(self):
        """
        This function initializes the GUI. This includes creating an appropriately sized GUI, adding buttons to the GUI, adding parameter text
        boxes and values, adding freeze check boxes, and adding refit check boxes.
        Args
        ------
        self: class
            The GUI class in this module
   
        Returns
        --------
            None
        """
#set up the title 
        self.parent.title("FIT IRIS DARK PEDESTAL")

#create frame for parameters
        frame = Tk.Frame(self,relief=Tk.RAISED,borderwidth=1)
        frame.pack(fill=Tk.BOTH,expand=1)

        self.pack(fill=Tk.BOTH,expand=1)

#set up print, refit, and quit buttons
        quitButton = Tk.Button(self,text="Quit",command=self.onExit)
        quitButton.pack(side=Tk.RIGHT,padx=.5,pady=5)
        printButton = Tk.Button(self,text="Print",command=self.Print)
        printButton.pack(side=Tk.RIGHT,padx=.5,pady=5)
        refitButton = Tk.Button(self,text="Refit",command=self.refit)
        refitButton.pack(side=Tk.RIGHT,padx=.5,pady=5)
        resetButton = Tk.Button(self,text="Reset",command=self.reset)
        resetButton.pack(side=Tk.RIGHT,padx=.5,pady=5)

        #set up percent variation box (maximum allowed variation in parameters)
        inp_lab_per = Tk.Label(self,textvariable=Tk.StringVar(value='%'),height=1,width=1)
        inp_lab_per.pack(side=Tk.RIGHT,padx=0.1,pady=5)


        inp_val_per = Tk.StringVar(value='{0:10}'.format(np.inf))
        self.val_per = Tk.Entry(self,textvariable=inp_val_per,width=3)
        self.val_per.bind("<Return>",self.set_limt_param)
        self.val_per.pack(side=Tk.RIGHT,padx=1,pady=5)

        #list of port to refit
        self.refit_list = []

        #set up check boxes for which ports to refit
        self.check_box = {}
        for i in self.current_keys:
            self.check_box[i+'_val'] = Tk.IntVar()
            self.check_box[i] = Tk.Checkbutton(master=self,text=i.upper(),variable=self.check_box[i+'_val'],onvalue=1,offvalue=0,command=self.refit_list_com)
            self.check_box[i].pack(side=Tk.LEFT,padx=0.1,pady=5)

        #set up box showing which parameters to freeze
        inp_lab_per = Tk.Label(self,textvariable=Tk.StringVar(value='Freeze Checked Par. = '),height=1,width=20)
        #Use below to fit all parameters on screen
        inp_lab_per = Tk.Label(self,textvariable=Tk.StringVar(value=''),height=1,width=1)
        
        inp_lab_per.pack(side=Tk.LEFT,padx=0.1,pady=5)

        #list of parameters to freeze
        self.freeze_list = []
        #set up check boxes for which parameter to freeze
        self.freeze_box = {}
        for i in self.plis:
            self.freeze_box[i+'_val'] = Tk.IntVar()
            self.freeze_box[i] = Tk.Checkbutton(master=self,text=i.upper(),variable=self.freeze_box[i+'_val'],onvalue=1,offvalue=0,command=self.freeze_list_com)
            self.freeze_box[i].pack(side=Tk.LEFT,padx=0.1,pady=5)

        #dictionary containing variable descriptors 
        self.dscr = {}
        #dictionary of variables containing the Tkinter values for parameters
        self.ivar = {}

        #create column for list
        for c,i in enumerate(self.plis): 
            #crate FUV descriptors 
            Tk.Label(frame,textvariable=Tk.StringVar(value=i),height=1,width=5).grid(row=0,column=c+2)
            #crate NUV descriptors 
            Tk.Label(frame,textvariable=Tk.StringVar(value=i),height=1,width=5).grid(row=0,column=c+5+len(self.plis))

        #top left (FUV) descriptor
        Tk.Label(frame,textvariable=Tk.StringVar(value='PORT'),height=1,width=5).grid(row=0,column=0)
        #top NUV descriptor which is two after the length of the parameters array
        Tk.Label(frame,textvariable=Tk.StringVar(value='PORT'),height=1,width=5).grid(row=0,column=len(self.plis)+3)
        #Add a column to separate  NUV and FUV
        Tk.Label(frame,textvariable=Tk.StringVar(value='  '),height=1,width=5).grid(row=0,column=len(self.plis)+2)
       # loop over string containing all the current_dict keys (i.e. port names)
        for m,i in enumerate(self.current_keys):
            txt = Tk.StringVar()
            txt.set(i.upper())

            #If NUV Put in the second column
            if 'nuv' in i:  
                r = int(i.replace('nuv',''))-1
                col = len(self.current_dict[i])+3
            #If FUV put in the first column
            else:
                col = 0
                r = int(i.replace('fuv',''))-1
     
            #create min and max labels
            self.dscr[i+'_min'] = Tk.Label(frame,textvariable=Tk.StringVar(value='min'),height=1,width=5).grid(row=3*r+1,column=col+1)
            self.dscr[i+'_med'] = Tk.Label(frame,textvariable=Tk.StringVar(value='med'),height=1,width=5).grid(row=3*r+2,column=col+1)
            self.dscr[i+'_max'] = Tk.Label(frame,textvariable=Tk.StringVar(value='max'),height=1,width=5).grid(row=3*r+3,column=col+1)

            #Text Describing the particular port
            self.dscr[i] = Tk.Label(frame,textvariable=txt,height=1,width=5).grid(row=3*r+1,column=col)
                     
            #loop over all columns (parameters) for each port
            for c,j in enumerate(self.current_dict[i]):
                inp_val = Tk.StringVar(value='{0:10}'.format(j))
                inp_max = Tk.StringVar(value='{0:10}'.format(self.current_dict[i+'_max'][c]))
                inp_min = Tk.StringVar(value='{0:10}'.format(self.current_dict[i+'_min'][c]))
   
                #create input text
                self.ivar[i+'_'+self.plis[c]+'_min'] = Tk.Entry(frame,textvariable=inp_min,width=12)
                self.ivar[i+'_'+self.plis[c]+'_med'] = Tk.Entry(frame,textvariable=inp_val,width=12)
                self.ivar[i+'_'+self.plis[c]+'_max'] = Tk.Entry(frame,textvariable=inp_max,width=12)

                #place on grid
                self.ivar[i+'_'+self.plis[c]+'_min'].grid(row=3*r+1,column=c+col+2)
                self.ivar[i+'_'+self.plis[c]+'_med'].grid(row=3*r+2,column=c+col+2)
                self.ivar[i+'_'+self.plis[c]+'_max'].grid(row=3*r+3,column=c+col+2)

                #bind input to return event
                self.ivar[i+'_'+self.plis[c]+'_min'].bind("<Return>",self.get_iris_param)
                self.ivar[i+'_'+self.plis[c]+'_med'].bind("<Return>",self.get_iris_param)
                self.ivar[i+'_'+self.plis[c]+'_max'].bind("<Return>",self.get_iris_param)


    #update the port values in the GUI
    def update_port_vals(self):  
       """
       This function updates the parameter text in the GUI based on the parameter in the current_dict class. 
       This function will call after you refit a parameter and accept the new parameter values.
       Args
       ------
       self: class
           The GUI class in this module
   
       Returns
       --------
           None
       """
       #loop over all columns (parameters) for each port
       for c,j in enumerate(self.current_dict[i]):
           inp_val = '{0:10}'.format(j)
           inp_max = '{0:10}'.format(self.current_dict[i+'_max'][c])
           inp_min = '{0:10}'.format(self.current_dict[i+'_min'][c])
   
           #create input text
           #self.ivar[i+'_'+self.plis[c]+'_min'].set(inp_min)
           self.ivar[i+'_'+self.plis[c]+'_med'].set(inp_val)
           #self.ivar[i+'_'+self.plis[c]+'_max'].set(inp_max)


    #Update parameters in current_dict with percentage limit
    def set_limt_param(self,onenter):
        """
        This function will set the parameter limits after updating the range value in the lower right text box.
        Args
        ------
        self: class
            The GUI class in this module
        onenter: class
            Initiate on enter
   
        Returns
        --------
            None
        """
        #release cursor from entry box and back to the figure
        #needs to be done otherwise key strokes will not work
        self.f.canvas._tkcanvas.focus_set()

        #scale parameters value
        self.sc_limit = float(self.val_per.get().replace(' ',''))/100.

       # loop over string containing all the current_dict keys (i.e. port names)
        for m,i in enumerate(self.current_keys):
            #loop over all parameters and update values (remove all white space before converting to float
            for c,j in enumerate(self.current_dict[i]):
               #skip frozen parameters
               if self.p_code['{0:1d}'.format(c)] not in self.freeze_list: 
                   self.current_dict[i+'_min'][c] = self.current_dict[i][c]-np.abs(self.sc_limit*self.current_dict[i][c])
                   self.current_dict[i+'_max'][c] = self.current_dict[i][c]+np.abs(self.sc_limit*self.current_dict[i][c])

        #update parameters shown in the boxes
        self.iris_show()

    #Update parameters in current_dict base on best fit values
    def get_iris_param(self,onenter):
        """
        This function will get the parameter limits from the parameter text boxes and update them in the fitting dictionary.
        Args
        ------
        self: class
            The GUI class in this module
        onenter: class
            Initiate on enter
   
        Returns
        --------
            None
        """
        #release cursor from entry box and back to the figure
        #needs to be done otherwise key strokes will not work
        self.f.canvas._tkcanvas.focus_set()

       # loop over string containing all the current_dict keys (i.e. port names)
        for m,i in enumerate(self.current_keys):
            #loop over all parameters and update values (remove all white space before converting to float
            for c,j in enumerate(self.current_dict[i]):
               self.current_dict[i][c] = float(self.ivar[i+'_'+self.plis[c]+'_med'].get().replace(' ','')) 
               self.current_dict[i+'_min'][c] = float(self.ivar[i+'_'+self.plis[c]+'_min'].get().replace(' ','')) 
               self.current_dict[i+'_max'][c] = float(self.ivar[i+'_'+self.plis[c]+'_max'].get().replace(' ','')) 


    #Update shown parameters base on new best fit
    def iris_show(self):
        """
        This function will updated the parameter text boxes values based on the best fit.
        Args
        ------
        self: class
            The GUI class in this module
   
        Returns
        --------
            None
        """
       # loop over string containing all the current_dict keys (i.e. port names)
        for m,i in enumerate(self.current_keys):
            #loop over all parameters and update values
            for c,j in enumerate(self.current_dict[i]):
               self.ivar[i+'_'+self.plis[c]+'_min'].delete(0,'end')
               self.ivar[i+'_'+self.plis[c]+'_med'].delete(0,'end')
               self.ivar[i+'_'+self.plis[c]+'_max'].delete(0,'end')

               #set formatting based on output value
               if abs(self.current_dict[i][c]) < .001:
                   dfmt = '{0:10.5e}'
               elif abs(self.current_dict[i][c]) > 10000.:
                   dfmt = '{0:10.1f}'
               elif abs(self.current_dict[i][c]) == 0:
                   dfmt = '{0:10d}'
               else:
                   dfmt = '{0:10.5f}'

               #update in text box
               #self.ivar[i+'_'+self.plis[c]+'_med'].insert(0,dfmt.format(self.current_dict[i][c]))
               self.ivar[i+'_'+self.plis[c]+'_min'].insert(0,dfmt.format(self.current_dict[i+'_min'][c]))
               self.ivar[i+'_'+self.plis[c]+'_med'].insert(0,dfmt.format(self.current_dict[i][c]))
               self.ivar[i+'_'+self.plis[c]+'_max'].insert(0,dfmt.format(self.current_dict[i+'_max'][c]))
         
    #set up data for plotting 
    def iris_dark_set(self):
        """
        This function reads in the IDL save files containing the dark trend information. It also sets default plotting symbols,
        linestyles, and colors per port.
        Args
        ------
        self: class
            The GUI class in this module
   
        Returns
        --------
            None
        """
        from scipy.io import readsav
        #Possible types of IRIS ports
        ptype = ['fuv','nuv']

        #colors associated with each port
        colors = ['red','blue','teal','black']
        #symbols associated with each port
        symbol = ['o','s','D','^']
        #format name of file to read
        self.fdata = {}
        for i in ptype: 
            fname = '../offset30{0}.dat'.format(i.lower()[0])
            #read in trend values for given ccd
            dat = readsav(fname)
            #correct for different variable name formats
            aval = '' 
            if i == 'nuv': aval = 'n'
            #put readsav arrays in defining variables
            time = dat['t{0}i'.format(aval)] #seconds since Jan. 1st 197   
            port = dat['av{0}i'.format(aval)]
            errs = dat['sigmx']

            #loop over all ports
            for j in range(port.shape[1]):
                toff = self.t0dict['{0}{1:1d}'.format(i.lower(),j+1)] 
                dt0 = time - toff#- 31556926.#makes times identical to the values taken in iris_trend_fix
                #store in dictionary [time,measured value, 1 sigma uncertainty]
                self.fdata['{0}{1:1d}'.format(i,j+1)] = [dt0,port[:,j],errs[:,j],colors[j],symbol[j]]

            #LRG Added 2022 for testing purposes, can print out yearly averages and data for comparison
            ##################### FOR DATA ANALYSIS #############################
            #Print data points and times:
            '''print('FUV2 Data:')
            for entry in range(len(self.fdata['fuv2'][1])):             
                print(datetime.fromtimestamp(284014800+time[entry]).strftime("%m/%d/%Y %I:%M"))    
                print(self.fdata['fuv2'][1][entry])'''
                
            '''y14 = range(0,7)
            y15 = range(8,19)
            y16 = range(19,32)
            y17 = range(32,45)
            y18 = range(45,56)
            y19 = range(56,70)
            y20 = range(70,83)
            y21 = range(83,97)
            y22 = range(97, 103)
            all_years =[y14, y15, y16, y17, y18, y19, y20, y21, y22]'''
         
        '''print(self.fdata['fuv3'][1])
            for dta in self.fdata['fuv3'][1]:
                print(dta)
            for tm in time:
                print(datetime.fromtimestamp(284014800+tm).strftime("%m/%d/%Y %I:%M"))
            for yrs in all_years:
                if i == 'fuv':
                    print('#########################')
                    print(datetime.fromtimestamp(284014800+time[tt[0]]).strftime("%m/%d/%Y %I:%M"))
                    print('******************')
                    print('FUV2 AVG: '+str(np.round(np.average(self.fdata['fuv2'][1][yrs]),2)))
                    print('FUV2 MED: '+str(np.median(self.fdata['fuv2'][1][yrs])))
                    print('FUV2 MIN: '+str(np.round(np.min(self.fdata['fuv2'][1][yrs]),2)))
                    print('FUV2 MIN: '+str(np.round(np.max(self.fdata['fuv2'][1][yrs]),2)))
                    print('******************')
                    print('FUV3 AVG: '+str(np.round(np.average(self.fdata['fuv3'][1][yrs]),2)))
                    print('FUV3 MED: '+str(np.median(self.fdata['fuv2'][1][yrs])))
                    print('FUV3 MIN: '+str(np.round(np.min(self.fdata['fuv3'][1][yrs]),2)))
                    print('FUV3 MIN: '+str(np.round(np.max(self.fdata['fuv3'][1][yrs]),2)))
                if i == 'nuv':
                    #print('#########################')
                    print('NUV1 AVG: '+str(np.round(np.average(self.fdata['nuv1'][1][yrs]),2)))
                    print('NNUV1 MED: '+str(np.median(self.fdata['fuv2'][1][yrs])))
                    print('NUV1 MIN: '+str(np.round(np.min(self.fdata['nuv1'][1][yrs]),2)))
                    print('NUV1 MIN: '+str(np.round(np.max(self.fdata['nuv1'][1][yrs]),2)))
        exit()'''
            ########################################################

    #plot the best fit data
    def iris_dark_plot(self):
        """
        This function will plot and IRIS pedestal data and the best fit parameters for each port.
        Args
        ------
        self: class
            The GUI class in this module
   
        Returns
        --------
            None
        """
        #clear the plot axes 
        for i in self.wplot.keys(): 

            #If a previous plot exists get x and y limits
            if self.lat_plot:
                #get previous x and y limits
                xlim = self.wplot[i].get_xlim()
                ylim = self.wplot[i].get_ylim()
  
            #clear previous plot
            self.wplot[i].clear()
            self.wplot[i].set_title(i.upper())
            self.wplot[i].set_xlabel('Offset Time [s]')
            self.wplot[i].set_ylabel('Pedestal Offset [ADU]')

            #If a previous plot exists set x and y limits
            if self.lat_plot:
                #set previous x and y limits
                self.wplot[i].set_xlim(xlim)
                self.wplot[i].set_ylim(ylim)

        #After first run through set lat(er)_plots to true
        self.lat_plot = True

        #best fit lines
        self.bline = {}
        #data scatter
        self.sdata = {}
       
        #plot data for all IRIS dark remaining pedestals
        for i in sorted(self.fdata.keys()):
            #Get plot associated with each port
            ax = self.wplot[i[:-1]] 
            #Put data in temp array
            dat = self.fdata[i]

            #set ptype attribute for curvefit and offset model 
            self.ptype = i[:-1]
            #set the current port variable
            self.cport= i 

            #get variance in best fit model
            var = self.get_var(i,self.current_dict[i])
            #get offset in last data point
            last = self.get_last(i,self.current_dict[i])
            
            '''times = dat[0]
            for t in range(0, len(times)-1):
                converted = float(times[t]+self.convert+self.t0dict[i])
                times[0][t] = datetime.fromtimestamp(converted)'''
            
            #Uploaded best fit
            #current dark time plus a few hours
            #ptim = np.linspace(self.fdata[i][0].min(),self.fdata[i][0].max()+1e3,500)
            
            # OR LRG UPDATED, added plot for next cycle to showw where data is going
            ptim = np.linspace(self.fdata[i][0].min(),self.fdata[i][0].max()+4e7,500)
            
            #plot values currently in current_dict for best fit values (store in dictionary for updating line)
            self.bline[i] = self.wplot[i[:-1]].plot(ptim,self.offset(ptim,*self.current_dict[i]),color=self.fdata[i][3],label='{0}(Unc.) = {1:5.4f}'.format(i,var)) 

            #plot each port
            self.sdata[i] = ax.scatter(dat[0],dat[1],color=dat[3],marker=dat[4],label='{0}(last) = {1:3.2f}'.format(i,last))
            ax.errorbar(dat[0],dat[1],yerr=dat[2],color=dat[3],fmt=dat[4],label=None)
 
        #add legend
        for i in self.wplot.keys():
            self.wplot[i].legend(loc='upper left',frameon=True)
            #add fancy plotting
            fancy_plot(self.wplot[i])

        self.canvas.draw()

    #get variance in the model
    def get_var(self,port,parm):
        """
        This function will calculate the varience between the model and the data for a given port for the latest best fit model.
        Args
        ------
        self: class
            The GUI class in this module
        port: str
            String containing the port name (e.g. 'nuv1'), which is the dictionary key
        parm: np.array
            An array of parameter value to send to the offset function
   
        Returns
        --------
        var: float
            The sum squared error divided by N. That is the average uncertainty per observation.   
        """
        var = np.sqrt(np.sum((self.fdata[port][1]-self.offset(self.fdata[port][0],*parm))**2.)/float(len(self.fdata[port][0])))
        return var
    
    #get fit value for most recent data point
    def get_last(self,port,parm):
        """
        This function will calculate the difference between the model and the most recent data point
        Args
        ------
        self: class
            The GUI class in this module
        port: str
            String containing the port name (e.g. 'nuv1'), which is the dictionary key
        parm: np.array
            An array of parameter value to send to the offset function
   
        Returns
        --------
        last: float
            The difference between the model and the most recent data point
        """
        last = np.sqrt(((self.fdata[port][1]-self.offset(self.fdata[port][0],*parm))**2.))[-1]
        return last

################################################################################################################
#                                MODEL
################################################################################################################       

    #Pedestal offset model
    def offset(self,dt0,amp1,amp2,p1,phi1,phi2,lin,quad,off):
        """
        This function creates the model used for fitting. If you want to add new parameters to the
        model, then you will need to add them this is function and document them. This function
        will get passed to the minimization routine when trying to derive new parameters.

        Model A utilizes 12 parameters as described below. 8 main paramters and 4 additional ones that are turned on and off based on time

        Model B,C,D,E utilizes only the 8 main paramters.

        Parameters from Model A,B,C,D are locked in and no longer adjsuted.

        Current model E is still adjustable
        
        Args
        ------
        self: class
            The GUI class in this module
        dt0: np.array
            The time is referenced with seconds since t0dict reference, which is port dependent. There is one time for every dark observation.

        ####################### MAIN PARAMS ##########################  
        amp1: float
            The amplitude of the approximately 1 year sine function.
        amp2: float
            The amplitude of the approximately 1/2 year sine function.
        p1: float
            Period of approximately 1 year sine function (or 1/2 year in second term)
        phi1: float
            The phase of the approximately 1 year sine function in radians.
        phi2: float
            The phase of the approximately 1/2 year sine function in radians.
        Lin: float
            The linear coefficient explaining the increase in the pedestal level. 
        quad : float
            The quadratic coefficient explaining the increase in the pedestal level. 
        off:  float
            The intercept for the quadratic and linear function
            
        ####################### MODEL A MODIFIERS ##########################   
        qscale: float
            The flattening of the linear and quadratic term after August 2017
        bo_drop: float
            The fractional drop in the offset (intercept term) due to the bake out on June 13-15, 2018
        sc_amp: float
            The amplication fraction in the in the sine function amplitudes due to the bake out on 
            June 13-15, 2018.
        ns_incr: float
            The fractional increase in the offset (intercept term) due to non-standard IRIS operations
            from October 27th to December 15th, 2018.
   
        Returns
        --------
        trend: float
            The value of the trend at each t0 for a given set of parameters.
        """
        #Determine the port in order to get the correct parameter values
        port = (self.cport)
        
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
        # C) MODEL PARAMETERS SECTION       #
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
        
        ####################### PARAMETERS FOR MODEL A ######################
        #Read in the the Model A parameters (DO NOT ADJUST PARAMETERS)
        A_amp1 = self.A_dict[port][0]
        A_amp2 = self.A_dict[port][1]
        A_p1 = self.A_dict[port][2]
        A_phi1 = self.A_dict[port][3]
        A_phi2 = self.A_dict[port][4]
        A_lin = self.A_dict[port][5]
        A_quad = self.A_dict[port][6]
        A_off = self.A_dict[port][7]
        A_qscale = self.A_dict[port][8]
        A_bo_drop = self.A_dict[port][9]
        A_sc_amp = self.A_dict[port][10]
        A_ns_incr = self.A_dict[port][11]
        
        ####################### PARAMETERS FOR MODEL B ######################
        #Read in the the Model B parameters (DO NOT ADJUST PARAMETERS)
        B_amp1 = self.B_dict[port][0]
        B_amp2 = self.B_dict[port][1]
        B_p1 = self.B_dict[port][2]
        B_phi1 = self.B_dict[port][3]
        B_phi2 = self.B_dict[port][4]
        B_lin = self.B_dict[port][5]
        B_quad = self.B_dict[port][6]
        B_off = self.B_dict[port][7]
        
        ####################### PARAMETERS FOR MODEL C ######################
        #Read in the the Model C parameters (DO NOT ADJUST PARAMETERS)
        C_amp1 = self.C_dict[port][0]
        C_amp2 = self.C_dict[port][1]
        C_p1 = self.C_dict[port][2]
        C_phi1 = self.C_dict[port][3]
        C_phi2 = self.C_dict[port][4]
        C_lin = self.C_dict[port][5]
        C_quad = self.C_dict[port][6]
        C_off = self.C_dict[port][7]
        
        ####################### PARAMETERS FOR MODEL C ######################
        #Read in the the Model D parameters (DO NOT ADJUST PARAMETERS)
        D_amp1 = self.D_dict[port][0]
        D_amp2 = self.D_dict[port][1]
        D_p1 = self.D_dict[port][2]
        D_phi1 = self.D_dict[port][3]
        D_phi2 = self.D_dict[port][4]
        D_lin = self.D_dict[port][5]
        D_quad = self.D_dict[port][6]
        D_off = self.D_dict[port][7]
        
        #constant on period term
        c = 2.*np.pi
        dtq = dt0-self.dtq0[self.ptype]
        
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
        # D) MODEL TRENDS SECTION       #
        #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
        
        ################################################################################################################
        #                       MODEL A                                        #
        ################################################################################################################
     
        #do not add quadratic term before start time
        dtq[dtq < 0.] = 0.

        #stop quad term after end time
        #range to adjust quadratic term over 2018/05/25 J. Prchlik
        adj = np.where(dtq > self.dtq1[self.ptype]-self.dtq0[self.ptype])
        A_off = np.zeros(dtq.size)+A_off
        #adjust offset for given quad flattening time
        A_off[adj] = A_off[adj]+A_quad*(1-A_qscale)*(self.dtq1[self.ptype]-self.dtq0[self.ptype])**2+A_lin*(1-A_qscale)*(self.dtq1[self.ptype])
        dtq[adj] = (dtq[adj])*(A_qscale)**.5

        #adjust offset for given linear flattening time
        dtl = dt0.copy()
        dtl[adj] = (dtl[adj])*(A_qscale)

        ################################################################################################################
        #Default config
        trend = (A_amp1*np.sin(c*(dt0/A_p1+A_phi1)))+(A_amp2*np.sin(c*(dt0/(A_p1/2.)+A_phi2)))+(A_lin*(dtl))+(A_quad*(dtq**2.00))+(A_off)
        ################################################################################################################
        #drop the trend following the June 2018 bakeout
        #Stop this trend once the non-standard coarse control of the telescope, which begins in Oct, 2018, end in Dec. 2018
        
        #Assume the trend is only for a time period between the bakeout and coarse control mode (June - Dec. 2018
        #2019/01/22 J. Prchlik
        post_bo = [((dt0 >  self.bojune152018-self.t0dict[self.cport]) & (dt0 < self.nsdec152018-self.t0dict[self.cport]))]
        #For now assumed the amplitude increase in the periodic trend presists after the bake and through the non-standard
        
        #Drop offset after June 2018 bake out by a fractional amount
        drop_trend_offset = -(A_bo_drop)*A_off
        
        #increase the amplitutude of the periodic terms after the June 2018 bake out by a fractional amount
        incs_trend_amplit = ((A_amp1*np.sin(c*(dt0/A_p1+A_phi1)))+(A_amp2*np.sin(c*(dt0/(A_p1/2.)+A_phi2))))*A_sc_amp

        #Trend after the 2018/06/15 bake out
        trend[post_bo] = (trend+drop_trend_offset+incs_trend_amplit)[post_bo]
        
        #Increase in the pedestal level following non-standard operations of the IRIS telescope from Oct.-Dec 2018
        post_ns = [(dt0 > self.nsdec152018-self.t0dict[self.cport])]
        #Increase pedestal offset after Oct.-Dec. 2018 non-standard operations by a fractional amount
        incr_trend_offset = (A_ns_incr)

        #Trend after the non-standard operations between Oct. 27th and Dec. 15 2018
        trend[post_ns] = (trend+incr_trend_offset)[post_ns]
        
        ################################################################################################################
        #                       MODEL B STARTING 2020/07/09                                          #
        ################################################################################################################
        #All times after July, 9th 2020 are handlded by a seperate model of the same form, but with unique variables
        model_B_start = [(dt0 > self.seperation_B - self.t0dict[self.cport]) & (dt0 < self.seperation_C - self.t0dict[self.cport])]
        #New trend takes the same form as the orignal model, just with new parameter values
        B_trend = (B_amp1*np.sin(c*(dt0/B_p1+B_phi1)))+(B_amp2*np.sin(c*(dt0/(B_p1/2.)+B_phi2)))+(B_lin*(dt0))+(B_quad*(dt0**2.00))+(B_off)
        
        #Trend from 2020/07/09 forward 
        trend[model_B_start] = B_trend[model_B_start]
        
        ################################################################################################################
        #                       MODEL C STARTING 2022/01/01                                          #
        ################################################################################################################
        model_C_start = [(dt0 >= self.seperation_C - self.t0dict[self.cport])]
        #New trend takes the same form as the orignal model, just with new parameter values
        C_trend = (C_amp1*np.sin(c*(dt0/C_p1+C_phi1)))+(C_amp2*np.sin(c*(dt0/(C_p1/2.)+C_phi2)))+(C_lin*(dt0))+(C_quad*(dt0**2.00))+(C_off)
        
        #Trend from 2022/01/01 forward 
        trend[model_C_start] = C_trend[model_C_start]
        
        ################################################################################################################
        #                       MODEL D STARTING 2022/11/01                                          #
        ################################################################################################################
        model_D_start = [(dt0 >= self.seperation_D - self.t0dict[self.cport])]
        #New trend takes the same form as the orignal model, just with new parameter values
        D_trend = (D_amp1*np.sin(c*(dt0/D_p1+D_phi1)))+(D_amp2*np.sin(c*(dt0/(D_p1/2.)+D_phi2)))+(D_lin*(dt0))+(D_quad*(dt0**2.00))+(D_off)
        
        #Trend from 2022/11/01 forward 
        trend[model_D_start] = D_trend[model_D_start]
        
        ################################################################################################################
        #                       MODEL E STARTING 2024/01/01                                          #
        ################################################################################################################
        model_E_start = [(dt0 >= self.seperation_E - self.t0dict[self.cport])]
        #New trend takes the same form as the orignal model, just with new parameter values
        D_trend = (amp1*np.sin(c*(dt0/p1+phi1)))+(amp2*np.sin(c*(dt0/(p1/2.)+phi2)))+(lin*(dt0))+(quad*(dt0**2.00))+(off)
        
        #Trend from 2024/01/01 forward 
        trend[model_E_start] = D_trend[model_E_start]

        ################################################################################################################
        #                       ADD NEW MODEL BELOW FOLLOWING FORMAT ABOVE                                    #
        ################################################################################################################
        

        ################################################################################################################
        #Return trend of both models
        return trend

    #print data to terminal
    def Print(self):

    ##########################################################################
    #!!!!!!Will need to update parameters here if you add new parameters!!!!!!
    ##########################################################################
        
        print('      {0:10},{1:10},{2:15},{3:10},{4:10},{5:20},{6:20},{7:10}'.format('Amp1','Amp2','P1','Phi1','Phi2','Lin','Quad','Offset'))
        for i in self.current_keys:
            print('{0}=[{1:^10.5f},{2:^10.5f},{3:^15.4e},{4:^10.5f},{5:^10.5f},{6:^20.9e},{7:^20.9e},{8:^10.5f}]'.format(i,*self.current_dict[i]))

    #refit list (i.e. which ports should you refit)
    def refit_list_com(self):
        self.f.canvas._tkcanvas.focus_set()
        #check which boxes are checked 
        for i in self.current_keys:
            #if checked and not in list update the list 
            if ((self.check_box[i+'_val'].get() == 1) and (i not in self.refit_list)):
                self.refit_list.append(i)
            #if checked and already in the list continue 
            elif ((self.check_box[i+'_val'].get() == 1) and (i in self.refit_list)):
                continue
            #if not checked remove from list and deselect
            elif ((self.check_box[i+'_val'].get() == 0) and (i in self.refit_list)):
                self.refit_list.remove(i)
                self.check_box[i].deselect()
            #if not checked and not in list do nothing
            else:
                continue
            
    #parameter freeze list
    def freeze_list_com(self):
        #allows you to get back to the main part of the GUI
        self.f.canvas._tkcanvas.focus_set()

        #freeze limit percentage
        self.fr_limit = 0.0001

        #check which boxes are checked and use array locattion to update limits
        for m,i in enumerate(self.plis):
            #if checked and not in list update the list 
            if ((self.freeze_box[i+'_val'].get() == 1) and (i not in self.freeze_list)):
                self.freeze_list.append(i)
                #set selected limit to 0.0001* of primary value
                for j in self.current_keys:
                    self.current_dict[j+'_min'][m] = self.current_dict[j][m]-np.abs(self.fr_limit*self.current_dict[j][m])
                    self.current_dict[j+'_max'][m] = self.current_dict[j][m]+np.abs(self.fr_limit*self.current_dict[j][m])
            #if freezeed and already in the list continue 
            elif ((self.freeze_box[i+'_val'].get() == 1) and (i in self.freeze_list)):
                continue
            #if not freezeed remove from list and deselect
            elif ((self.freeze_box[i+'_val'].get() == 0) and (i in self.freeze_list)):
                self.freeze_list.remove(i)
                self.freeze_box[i].deselect()

                #set to global limit if sc_limit is set
                if isinstance(self.sc_limit,float):
                    for j in self.current_keys:
                        self.current_dict[j+'_min'][m] = self.current_dict[j][m]-np.abs(self.sc_limit*self.current_dict[j][m])
                        self.current_dict[j+'_max'][m] = self.current_dict[j][m]+np.abs(self.sc_limit*self.current_dict[j][m])
                else: 
                    #set unselected limit to infinity
                    for j in self.current_keys: self.current_dict[j+'_min'][m],self.current_dict[j+'_max'][m] = -np.inf,np.inf
            #if not freezeed and not in list do nothing
            else: continue

        self.iris_show() 

    #Refit the model
    def refit(self):
        #refit for every model in refit list
        for i in self.refit_list:
            guess = self.current_dict[i]
            mins  = self.current_dict[i+'_min']
            maxs  = self.current_dict[i+'_max']
            dt0   = self.fdata[i][0]
            port  = self.fdata[i][1]
            errs  = self.fdata[i][2]

            #get the current port type
            self.ptype = i[:-1]
            #get current full port informtion (i.e. nuv1 or fuv2)
            self.cport = i
             
            #for j,k in enumerate(mins): print(k,guess[j],maxs[j])
            popt, pcov = curve_fit(self.offset,dt0,port,p0=guess,sigma=errs,bounds=(mins,maxs),xtol=1e-10) 
 
            #temporary line plot
            #ptim = np.linspace(self.fdata[i][0].min(),self.fdata[i][0].max()+1e3,500)
            
            # OR LRG UPDATED, added plot for next cycle to showw where data is going
            ptim = np.linspace(self.fdata[i][0].min(),self.fdata[i][0].max()+2e7,500)
            
            
            t_line, = self.wplot[i[:-1]].plot(ptim,self.offset(ptim,*popt),'--',color=self.fdata[i][3]) 
            self.canvas.draw()
           
            #get model variance 
            old_var = self.get_var(i,self.current_dict[i])
            new_var = self.get_var(i,popt)

            #Ask if you should update the new parameter for a given fit
            if box.askyesno('Update','Should the Dark Trend Update for {0} (dashed line)?\n $\sigma$(old,new) = ({1:5.4f},{2:5.4f})'.format(i.upper(),old_var,new_var)):
                                      
                #update with new fit values
                self.current_dict[i] = popt
                #update strings in GUI

            #remove temp line
            t_line.remove()
            self.canvas.draw()
        
        #update parameters in the box
        self.iris_show()
        #self.update_port_vals()
        #update plots
        self.iris_dark_plot()
            
    #resets parameter guesses
    def reset(self):
        self.current_dict = self.idict.copy()
        self.iris_show()
        #self.update_port_vals()

#Exits the program
    def onExit(self):
       plt.clf()
       plt.close()
       self.quit()
       self.parent.destroy()

#Tells Why Order information is incorrect
    def onError(self):
        if self.error == 1:
            box.showerror("Error","File Not Found")
        if self.error == 4:
            box.showerror("Error","Value Must be an Integer")
        if self.error == 6:
            box.showerror("Error","File is not in Fits Format")
        if self.error == 10:
            box.showerror("Error","Value Must be Float")
        if self.error == 20:
            box.showerror("Error","Must Select Inside Plot Bounds")

#main loop
def main():
    global root
    root = Tk.Tk()
    app = gui_dark(root)
    default_font = tkFont.nametofont("TkDefaultFont")
    default_font.configure(size=12)
    root.option_add("*Font", default_font)
    root.option_add("*Font", default_font)
    root.mainloop()

if __name__=="__main__":
#create root frame
   main()

