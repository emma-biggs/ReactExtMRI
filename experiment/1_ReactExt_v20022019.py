# EXPERIMENT: ReactExt_v1
# EB - last update 26/12/2018


# General notes:
# trialType 1 = CSplus_Reactivation
# trialType 2 = CSplus_NoReactivation
# trialType 3 = CSplus_Extinction
# trialType 4 = CSminus
# NOTE: assumes USB mode (i.e. 5 for scanner trigger and values for button box (1 & 6))
# NOTE: need to manually change from emulation to scan mode
#---------------------------------------------

# Import libraries
from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual, core, data, event, logging, sound, gui, parallel
from psychopy.constants import *  # things like STARTED, FINISHED
from psychopy.hardware.emulator import *
from psychopy.tools.filetools import fromFile, toFile
from numpy import linspace
from numpy.random import shuffle
import os  # system and path functions

#*************************** 
#---EXPERIMENT SETTINGS
#***************************

# Ensure that relative paths start from the same directory as this script
thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(thisDir)

# Store info about the experiment session
expName = 'ReactExtstudy'
expInfo = {
    'participant': '#',
    'phase': 'a/r/e/r1/r2',
    'cbContext': 'A/B',
    'cbColor': '1/2/3/4'
    }
dlg = gui.DlgFromDict(expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a timestamp
expInfo['expName'] = expName

MR_settings = {
    'TR': 1.000,        # duration (sec) per whole-brain volume
    'volumes': 1600,     # number of whole-brain 3D volumes per scanning run
    'sync': '5',        # character to use as the sync timing event; assumed to come at start of a volume
    'skip': 0,          # number of volumes lacking a sync pulse at start of scan (for T1 stabilization)
    'sound': False      # in test mode: play a tone as a reminder of scanner noise
    }

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
logFoldername = os.path.join(thisDir, 'data', '%s') %(expInfo['participant'])
if not os.path.exists(logFoldername): os.makedirs(logFoldername)
logFilename     = os.path.join(logFoldername, 'Log_%s_%s_%s_%s') %(expInfo['participant'], expInfo['phase'], expName, expInfo['date'])
PRTfileName     = os.path.join(logFoldername, 'PRT_%s_%s_%s_%s') %(expInfo['participant'], expInfo['phase'], expName, expInfo['date'])
RatingfileName  = os.path.join(logFoldername, 'Ratings_%s_%s_%s_%s') %(expInfo['participant'], expInfo['phase'], expName, expInfo['date'])

# ExperimentHandler for saving data
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=None,
    savePickle=True, saveWideText=True,
    dataFileName=logFilename)

#save a log file for detail verbose info
logFile = logging.LogFile(logFilename+'.log', level=logging.INFO, filemode='a')
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file
endExpNow = False  # flag for 'escape' or other condition => quit the exp
PRT_logFile = open(PRTfileName + '.prt', 'w')
Rating_logFile = open(RatingfileName + '.txt', 'w')


# ****************************************
#-----INITIALIZE GENERIC COMPONENTS
# ****************************************

# WINDOW (should be 1920x1200 for 3T; 1440x900 for mac; 3840x2160 for dell; 1680x1050 for KUL lab)
win = visual.Window(size=(1680, 1050), fullscr=True, screen=0, allowGUI=True, allowStencil=False,
    monitor='LabMonitor', color=[-1,-1,-1], colorSpace='rgb',
    blendMode='avg', useFBO=True, units='height'
    )

DS7                 = parallel.ParallelPort(address=0x0378)            # CHECK ME
DS7Pin              = 5


biopac              = parallel.ParallelPort(address=0x0378)            # CHECK ME
biopacCSplusRPin    = 3    #biopac channel D9
biopacCSplusNRPin   = 4    #biopac channel D10
biopacCSplusEPin    = 6    #biopac channel D12
biopacCSminusPin    = 7   #biopac channel D13
biopacUSPin         = 8    #biopac channel D14
biopac.setData(0)

# STIMULI
if expInfo['cbColor'] == '1':     csNames = ['CSblue','CSred','CSyellow','CSgreen']
elif expInfo['cbColor'] == '2':   csNames = ['CSgreen','CSblue','CSred','CSyellow']
elif expInfo['cbColor'] == '3':   csNames = ['CSyellow','CSgreen','CSblue','CSred']
elif expInfo['cbColor'] == '4':   csNames = ['CSred','CSyellow','CSgreen','CSblue']

if expInfo['cbContext'] == 'A':
    if expInfo['phase'] in ['a','r2']:          contextName = 'ContextA'
    elif expInfo['phase'] in ['r','e','r1']:    contextName = 'ContextB'
elif expInfo['cbContext'] == 'B':
    if expInfo['phase'] in ['a','r2']:          contextName = 'ContextB'
    elif expInfo['phase'] in ['r','e','r1']:    contextName = 'ContextA'
    
CSplusR = visual.ImageStim(win=win, size=(1.2,1), image=(contextName+'_'+csNames[0]+'.bmp'))
CSplusNR = visual.ImageStim(win=win, size=(1.2,1), image=(contextName+'_'+csNames[1]+'.bmp'))
CSplusE = visual.ImageStim(win=win, size=(1.2,1), image=(contextName+'_'+csNames[2]+'.bmp'))
CSminus = visual.ImageStim(win=win, size=(1.2,1), image=(contextName+'_'+csNames[3]+'.bmp'))
context = visual.ImageStim(win=win, size=(1.2,1), image=(contextName+'.bmp'))

# CLOCKS ETC.
globalClock     = core.Clock()
fmriClock       = core.Clock()
logging.setDefaultClock(fmriClock)
ratingClock     = core.Clock()
shockClock      = core.Clock()
ITITimer        = core.CountdownTimer()
CSTimer         = core.CountdownTimer()

# ARRAYS FOR PRT FILE
CSplusRTimes        = [[],[]]
CSplusNRTimes        = [[],[]]
CSplusETimes        = [[],[]]
CSminusTimes        = [[],[]]
shockTimes          = [[],[]]
ratingTimes         = [[],[]]
buttonTimes         = [[],[]]

#************************
#---TRIAL RANDOMIZATIONS
#************************

if expInfo['phase'] == 'a': trialTypes = [1,2,4]
elif expInfo['phase'] == 'r': trialTypes = [1]
else: trialTypes = [1,2,3,4]

if expInfo['phase'] == 'a': ITILengths = [12,14,16]
elif expInfo['phase'] == 'r': ITILengths = [12]
else: ITILengths = [12,14,16,18]

if expInfo['phase'] == 'a': numReps = 12
if expInfo['phase'] == 'r': numReps = 1
if expInfo['phase'] == 'e': numReps = 16
if expInfo['phase'] == 'r1': numReps = 8
if expInfo['phase'] == 'r2': numReps = 8

tmpTypes = []
tmpITI = []

for i in range(0,numReps):
    shuffle(trialTypes)
    shuffle(ITILengths)
    tmpTypes.extend(trialTypes)
    tmpITI.extend(ITILengths)

trialNumbers = linspace(1,len(tmpTypes),num=(len(tmpTypes)),dtype='int')
stimList = []
for tmp in range(0,len(trialNumbers)):
    stimList.append({'trialType':tmpTypes[tmp], 'ITIlength':tmpITI[tmp], 'trialNumber':trialNumbers[tmp]})


#********************
#---FMRI SETTINGS
#********************

sync_now    = False
waitForSync = True
print 'waiting for sync'

insText = 'The experiment is about to begin.\n'
insText += '\n\nExperimenter: Press s then wait for trigger'
msg = visual.TextStim(win, text=insText, color=(1,1,1), height=0.05)
msg.draw()
win.flip()

core.wait(1)
event.waitKeys(keyList='s')

vol = launchScan(win, MR_settings, globalClock=fmriClock, mode='Test')      #or 'Scan' mode
print 'scan launched'


event.waitKeys(keyList='5')
print 'sync now'
print fmriClock.getTime()
event.Mouse(visible=False)

#***********************
#---BASELINE
#***********************

print 'baseline started'
print fmriClock.getTime()
context.setAutoDraw(True)                    # draw context background
win.flip()
core.wait(19.5)                                           # wait for 20s baseline

#***********************
#---START OF TRIALS
#***********************

a_trial = data.TrialHandler(nReps=1, method='sequential', 
    extraInfo=expInfo, originPath=None,
    trialList=stimList,
    seed=None, name='a_trial')
thisExp.addLoop(a_trial)  # add the loop to the experiment
#thisA_trial = a_trial.trialList[0]  # so we can initialise stimuli with some values
for currtrial in a_trial:
#    if currtrial != None: 
#        for paramName in thisA_trial.keys():
#            exec(paramName + '= thisA_trial.' + paramName)
    currTrialNumber = int(currtrial['trialNumber'])
    currTrialType = int(currtrial['trialType'])
    currITIlength = int(currtrial['ITIlength'])
    print (u"trial number: %u" % (currTrialNumber))
    
    # -------ITI PERIOD--------
    event.waitKeys(keyList='5')
    print 'sync now'
    print fmriClock.getTime()
    thisExp.addData('ITIstartTime', fmriClock.getTime())
    
    core.wait(currITIlength - 0.5)
    if event.getKeys(keyList='escape'):
        core.quit()
        
    # -------CS PERIOD---------
    event.waitKeys(keyList='5')
    print 'sync now'
    print fmriClock.getTime()
    thisExp.addData('CSstartTime', fmriClock.getTime())
    
    print 'CS started'
    # CSplusR
    if currTrialType == 1:
        CSplusR.setAutoDraw(True)                                   # draw CSplusR
        biopac.setPin(biopacCSplusRPin,1)
        PRTStartTime = int((fmriClock.getTime()) *1000)            # record start time
        CSplusRTimes[0].append(PRTStartTime)
    # CSplusNR
    if currTrialType == 2:
        CSplusNR.setAutoDraw(True)                                   # draw CSplusNR
        biopac.setPin(biopacCSplusNRPin,1)
        PRTStartTime = int((fmriClock.getTime()) *1000)            # record start time
        CSplusNRTimes[0].append(PRTStartTime)
    # CSplusE
    if currTrialType == 3:
        CSplusE.setAutoDraw(True)                                  # draw CSplusE
        biopac.setPin(biopacCSplusEPin,1)
        PRTStartTime = int((fmriClock.getTime()) *1000)            # record start time
        CSplusETimes[0].append(PRTStartTime)
    # CSminus
    if currTrialType == 4:
        CSminus.setAutoDraw(True)                                  # draw CSminus
        biopac.setPin(biopacCSminusPin,1)
        PRTStartTime = int((fmriClock.getTime()) *1000)            # record start time
        CSminusTimes[0].append(PRTStartTime)
    context.setAutoDraw(False)
    win.flip()
    
    core.wait(5.3)
    biopac.setData(0)
    if currTrialType == 1 and expInfo['phase']=='a':    shock=True
    elif currTrialType == 2 and expInfo['phase']=='a':  shock=True
    elif currTrialType == 3:                            shock=True
    else:
        shock=False
        core.wait(0.7)
    
    if shock==True:
        print 'shock'
        isi = 0.175
        shockClock.reset()
        biopac.setPin(biopacUSPin,1)
        PRTStartTime = int((fmriClock.getTime())*1000)
        while shockClock.getTime() < 0.7:
            DS7.setPin(DS7Pin,1)
            core.wait(0.002)
            DS7.setPin(DS7Pin,0)
            core.wait(isi)
            if isi > 0.002:
                isi = isi/1.55
        DS7.setPin(DS7Pin,0)
        biopac.setPin(biopacUSPin,0)
        # details for protocol log file
        PRTEndTime = int((fmriClock.getTime())*1000)
        shockTimes[0].append(PRTStartTime)
        shockTimes[1].append(PRTEndTime)
        shock=False
    
    # remove CS & signal, show context
    context.setAutoDraw(True)
    CSplusR.setAutoDraw(False)
    CSplusNR.setAutoDraw(False)
    CSplusE.setAutoDraw(False)
    CSminus.setAutoDraw(False)
    win.flip()
    biopac.setPin(biopacCSplusRPin,0)
    biopac.setPin(biopacCSplusNRPin,0)
    biopac.setPin(biopacCSplusEPin,0)
    biopac.setPin(biopacCSminusPin,0)
    # save CS end time to PRT
    PRTEndTime = int((fmriClock.getTime())*1000)
    if currTrialType == 1: CSplusRTimes[1].append(PRTEndTime)
    if currTrialType == 2: CSplusNRTimes[1].append(PRTEndTime)
    if currTrialType == 3: CSplusETimes[1].append(PRTEndTime)
    if currTrialType == 4: CSminusTimes[1].append(PRTEndTime)

    thisExp.nextEntry()

#*****************************
# END OF BLOCK
#*****************************

core.wait(20)
# ----------RATING PERIOD------------

print 'expectancy rating started'
expResp = ['NaN','NaN','NaN','NaN']     # Create empty array for saving rating responses

# 11-point scale from 0 (0%) to 10 (100%), cursor resets to 5 before display, displayed within a box for better visualization
expRating = visual.RatingScale(win, name='expectancy_rating', pos=(0.0,-0.5), low=0, high=10, markerStart=5, leftKeys='left', rightKeys='right', 
    showAccept=False, noMouse=True, size=1, stretch=2, textColor='black', lineColor='black', labels=[u'0%', u'100%'], scale=''
    )
ratingBox = visual.ShapeStim(win, vertices=[(-0.65,-0.35),(-0.65,0.15),(0.65,0.15),(0.65,-0.35)], fillColor=[0.200,0.200,0.192], lineColor='white')

# Array of text to use in question based on counterbalance code
if expInfo['cbColor'] == '1':     cbTrialColor = ['blauwe','rode','gele','groene']      #CSplusR, CSplusNR, CSplusE, CSminus
elif expInfo['cbColor'] == '2':   cbTrialColor = ['groene','blauwe','rode','gele']      #CSplusR, CSplusNR, CSplusE, CSminus
elif expInfo['cbColor'] == '3':   cbTrialColor = ['gele','groene','blauwe','rode']      #CSplusR, CSplusNR, CSplusE, CSminus
elif expInfo['cbColor'] == '4':   cbTrialColor = ['rode','gele','groene','blauwe']      #CSplusR, CSplusNR, CSplusE, CSminus

# Array of which colors to use in question based on phase (and which trial types were presented)
if expInfo['phase'] == 'a': currRatings = [0,1,3]       #CSplusR, CSplusNR, CSminus
if expInfo['phase'] == 'r': currRatings = [0]           #CSplusR
if expInfo['phase'] == 'e': currRatings = [0,1,2,3]     #CSplusR, CSplusNR, CSplusE, CSminus
if expInfo['phase'] == 'r1': currRatings = [0,1,2,3]    #CSplusR, CSplusNR, CSplusE, CSminus
if expInfo['phase'] == 'r2': currRatings = [0,1,2,3]    #CSplusR, CSplusNR, CSplusE, CSminus

shuffle(currRatings)        # shuffle the order to randomize order of questions based on trial type

# Loop through colors
for rating in currRatings:
    
    # Create rating text using the counterbalance code (cbTrialColor) and trial types present (currRatings)
    expRatingText = visual.TextStim(
        win, alignHoriz='center', alignVert='center', 
        text=('In welke mate verwachte je dat het \n'+cbTrialColor[rating]+' licht \ngevolgd werd door een elektrische prikkel?'), 
        color=[-1,-1,-1], height = 0.035, pos=(0,0)
        )
    
    # Present rating for 10 seconds
    ratingClock.reset()
    while ratingClock.getTime() <= 10:
        ratingBox.setAutoDraw(True)
        expRating.setAutoDraw(True)
        expRatingText.setAutoDraw(True)
        win.flip()

    # Save response in array and remove rating
    expResp[rating] = expRating.getRating()
    expRating.setAutoDraw(False)
    ratingBox.setAutoDraw(False)
    expRatingText.setAutoDraw(False)
    win.flip()

# Write ratings to log file
Rating_logFile.write(
    'CSplusR\t' + str(expResp[0]) + '\n' + \
    'CSplusNR\t'+ str(expResp[1]) + '\n' + \
    'CSplusE\t'+ str(expResp[2]) + '\n' + \
    'CSminus\t'+ str(expResp[3]) + '\n'
    )


#******************************SAVE OUTPUT TO PRT FILE*******************

header = \
    '\n' + \
    'FileVersion: 2\n' + \
    '\n' + \
    'ResolutionOfTime: msec\n' + \
    '\n' + \
    'Experiment:  PEstudy \n' + \
    '\n' + \
    'BackgroundColor: 0 0 0\n' + \
    'TextColor:   255 255 217\n' + \
    'TimeCourseColor: 255 255 255\n' + \
    'TimeCourseThick: 3\n' + \
    'ReferenceFuncColor:  255 255 51\n' + \
    'ReferenceFuncThick:  2\n' + \
    '\n' + \
    'NrOfConditions:  5'

PRT_logFile.write(header)
stimulusName = ['CSplusR', 'CSplusNR', 'CSplusE', 'CSminus', 'US']
stimulusColour = ['255 0 0', '0 255 0', '0 0 255', '255 255 0', '255 255 0']
stimulusTimes = [CSplusRTimes, CSplusNRTimes, CSplusETimes, CSminusTimes, shockTimes] 
    
for PRTstimulus in range(len(stimulusName)):
    if not stimulusTimes[PRTstimulus][0]:
        continue
    PRT_logFile.write('\n' + '\n' + \
    stimulusName[PRTstimulus] + '\n' + \
    str(len(stimulusTimes[PRTstimulus][0])) + '\n')
    for PRTtimes in range(len(stimulusTimes[PRTstimulus][0])):
        PRT_logFile.write('\t' + str(stimulusTimes[PRTstimulus][0][PRTtimes]) + '\t' + str(stimulusTimes[PRTstimulus][1][PRTtimes]) + '\n')
    PRT_logFile.write('Color: ' + stimulusColour[PRTstimulus])
    
PRT_logFile.close()
Rating_logFile.close()

# --------------END------------

print 'experiment end'
print fmriClock.getTime()
endMsg = visual.TextStim(win=win, color='White', text='End of run')
endMsg.setAutoDraw(True)
context.setAutoDraw(False)
win.flip()
core.wait(3)
win.close()
core.quit()