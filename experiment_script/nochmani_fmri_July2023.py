# Nochmani replication - Feb 2018 



# self-paced hand localiser task

"""### Before importing packages, make sure you have installed 
'psychopy', 
'SpeechRecognition', 
'google-api-core google-auth google-cloud google-cloud-speech googleapis-common-protos', 
and 'psychopy-sounddevice'."""

import csv
import datetime
import numpy as np
import random
import math
#from psychopy import prefs, sound
#prefs.general['audioLib'] = ['pygame']
from psychopy import visual, core, event, monitors, os, data, gui
from psychopy.tools.fileerrortools import handleFileCollision
# from psychopy.hardware.emulator import launchScan

##########################
# settings for launchScan:
##########################

MR_settings = {
    'Subject number': '', # subject info
    'TR': 2.000, # duration (sec) per volume
    'volumes': 5, # number of whole-brain 3D volumes / frames (was 5) or should be pick 180?
    'sync': '5', # character to use as the sync timing event; assumed to come at start of a volume
    'skip': 0, # number of volumes lacking a sync pulse at start of scan (for T1 stabilization)
    'sound': True # in test mode only, play a tone as a reminder of scanner noise
    }

infoDlg = gui.DlgFromDict(MR_settings, title='fMRI parameters')
if not infoDlg.OK: core.quit()

###############################
# GLobal settings & Variables #
###############################

win = visual.Window(fullscr=False)
# core.monotonicClock = core.Clock() # Use core.monotonicClock

# Monitor settings
CS = 'rgb255'  # ColorSpace
GREY = [125, 125, 125]
WHITE = [255, 255, 255]
BLACK = [0, 0, 0]
POSITION = (0.0, 0.0)

data_dir = os.path.expanduser('C:/Users/CasasantoLab/Desktop/nochmani/data/')
pic_dir = os.path.expanduser('C:/Users/CasasantoLab/Desktop/nochmani/image_stimuli/')

assert os.path.exists(data_dir)
assert os.path.exists(pic_dir)

pic_suffix = '.jpg'
pic_names = [s for s in os.listdir(pic_dir) if s.endswith(pic_suffix)]

# Make 4 prac stims
prac_stim_names = [s for s in pic_names if s.startswith('0_')]
# Make 40 stims in each cell
std_stim_names = [s for s in pic_names if not s.startswith('0_') if not s.startswith('.')]#ignore .DS_store
assert len(std_stim_names) == (40 * 4)

# instructions
WELCOME_INSTR = """Welcome to the experiment. You are about to be presented with a series of images.
            
            \nPlease respond using your thumb.
            \nIf the picture shows something the Nochmani would eat, press the button on the same side as "EAT" to EAT it.
            \nIf the picture shows something the Nochmani would not eat, press the button on the same side as "DON'T EAT" to NOT EAT it.
            \nRespond as quickly and accurately as possible."""

PRAC_INSTR = """A few practice trials to get you acquainted with the experiment.
            \n
            \nReady to begin the practice trials?"""

PRAC_END_INSTR = """Good job!
            \n
            \nThe real experiment is about to begin.
            \n
            \nReady to begin?"""

RUN_INSTR = """For the next part, you will do the same thing, but switch hands.
            \n
            \nPlease move the botton box to the other hand.
            \n
            \nPlease let the experimenter know when you are ready to go on."""

BLOCK_INSTR = """Please respond using your thumb.
            \nRemember that the Nochmani love to eat sweets and bugs, but they hate eating meat and moldy things.
            \nRespond as quickly and accurately as possible."""

LOCALISER_INSTR = """Good job!
            \nYou have completed this part of the experiment.
            \nFor the next part, you do not need the button box.
            \nYou will be tapping one finger with your thumb one hand at a time.
            \nReady to begin?"""

################
# respond labels
label_spacing = " " * 36
RESP_EAT_LEFT = "EAT" + label_spacing + "DON'T EAT"
RESP_EAT_RIGHT = "DON'T EAT" + label_spacing + "EAT"
resp_eat_side = RESP_EAT_LEFT

# Let's assume we're showing each stimulus 1 time per response-side
BLOCK_LENGTH = 10 # stims per block
N_BLOCKS = len(std_stim_names) / BLOCK_LENGTH ### 160 / 10 = 16 (Half the total number of blocks = the number of blocks per response side)
N_BLOCKS_PER_COND = N_BLOCKS / 4 ### 16 / 4 = 4 blocks of each condition (approach pos etc, each with 10 trials -- 40 trials per condition, 160 trials per response side).
iN_BLOCKS_PER_COND = int(N_BLOCKS_PER_COND) ### N_BLOCKS_PER_COND changed to int type to prevent float point error. See 178 for next use of this object.
N_CATCH_PER_BLOCK = 2 # Number of catch trials in each block

############################
# Set up trial information #
############################

# create a placeholder for subject
SUBJECT = int(MR_settings['Subject number'])
resp_hand = ['left', 'right']

# counterbalance respond_side across participants
if SUBJECT % 2 == 0:
    resp_eat_side = RESP_EAT_LEFT
    start_hand = resp_hand[0]
    
else:
    resp_eat_side = RESP_EAT_RIGHT
    start_hand = resp_hand[1]

# Block labels
motiv_levels = ['approach', 'avoid']
valence_levels = ['pos', 'neg']

# Make a function to get condition label
def get_cond_label(motiv, valence):
    """ Given motivation and valence, get the condition label (e.g. 'cake')
    """
    assert motiv in ('approach', 'avoid')
    assert valence in ('pos', 'neg')

    if motiv == 'approach' and valence == 'pos':
        return 'cake'
    elif motiv == 'approach' and valence == 'neg':
        return 'insect'
    elif motiv == 'avoid' and valence == 'pos':
        return 'meat'
    elif motiv == 'avoid' and valence == 'neg':
        return 'fungus'

# Make a dictionary of stim lists
stims = {} # Holds all our stim names by condition
for hand in resp_hand:
    stims[hand] = {}
    for mot in motiv_levels:
        stims[hand][mot] = {}
        for val in valence_levels:
            cond = get_cond_label(mot, val)
            stims[hand][mot][val] = [s for s in pic_names if s.startswith(cond)]
            random.shuffle(stims[hand][mot][val])

blocks = [] # List of lists - each sublist hold trial info for 1 block
for hand in resp_hand:
    for mot in motiv_levels:
        for val in valence_levels:
            for n_block in range(iN_BLOCKS_PER_COND):
                current_block = []

                # standard trials
                for n_std_stim in range(BLOCK_LENGTH - N_CATCH_PER_BLOCK):
                    t = {}
                    t['n_block'] = n_block
                    t['catch'] = False
                    t['hand'] = hand
                    t['mot'] = mot
                    t['val'] = val
                    t['stim_name'] = stims[hand][mot][val].pop()
                    current_block.append(t)

                # add the catch trials
                for n_catch_stim in range(N_CATCH_PER_BLOCK):
                    # OM: changed "if mot is 'avoid'" to "if mot == 'avoid'" on June 27, after SyntaxWarning
                    mot_catch = 'approach' if mot == 'avoid' else 'avoid'
                    val_catch = valence_levels[n_catch_stim] # one of each
                    t = {}
                    t['n_block'] = n_block
                    t['catch'] = True
                    t['hand'] = hand
                    t['mot'] = mot_catch
                    t['val'] = val_catch
                    t['stim_name'] = stims[hand][mot_catch][val_catch].pop()
                    current_block.append(t)

                random.shuffle(current_block)
                blocks.append(current_block)

random.shuffle(blocks)

# To flatten the list of lists
import itertools
trial_info = list(itertools.chain(*blocks))

# add run (n = 4) to flattened list
# for i in range(64): # for dummy testing 
### We changed math.ceil to math.floor. Because if we used math.ceil, then the experiment was running a block at the beginning that was composed only of one trial. 
for i in range(320):
    trial_info[i]['run_number'] = (math.floor(i / 80) + 1)

    # add block order to the list
    trial_info[i]['num_block'] = (math.floor(i / 10) + 1)

# Put everything together into the TrialHandler object
trials = data.TrialHandler(trial_info, nReps=1, method='sequential')

#################################
# Set up hand localiser task info
fingers = ['index','middle','ring','pinky']
localiser_blocks = []
for finger in fingers:
    for hand in resp_hand:
        current_block = []
        t = {}
        t['finger'] = finger
        t['hand'] = hand
        current_block.append(t)

        localiser_blocks.append(current_block)

hand_localiser = list(itertools.chain(*localiser_blocks))

# Put everything together into the TrialHandler object
trials_localiser = data.TrialHandler(hand_localiser, nReps=1, method='sequential')

#####################
# Initialize clocks #
#####################
START_TIME = datetime.datetime.now().strftime('%Y-%m-%d-%H%M')

######################
# Window and Stimuli #
######################

win = visual.Window(#[1280, 800], fullscr=False, monitor='Test2-iMac',
                    [1920, 1080], fullscr=False, monitor='testMonitor',
                    color=WHITE, colorSpace=CS, allowGUI=False,
                    units="deg")

### 'alignHoriz' and 'alignVert' commented out and replaced by 'alignText', 'anchorHoriz', and 'anchorVert' since these arguments have changed since Py2. 
text_stim = visual.TextStim(win, text='--', pos = POSITION,
                            #alignHoriz='center', 
                            alignText='center', anchorHoriz='center',
                            color=BLACK, colorSpace=CS, height=.8)

response_stim = visual.TextStim(win, text='--',
                            color=BLACK, colorSpace=CS,
                            #alignHoriz='center',
                            #alignVert='bottom',  
                          
                            alignText = 'bottom', anchorVert = 'bottom',  height=.8,
                            pos=(0.0, -8.0))

std_stims = {s: visual.ImageStim(win, image=pic_dir+s)
                for s in std_stim_names}

####################################################
# Functions to present stims and collect responses #
####################################################

def show_text(text):
    """ Show text at the center of the screen.
    """
    text_stim.text = text # text_stim was defined earlier
    text_stim.draw()
    win.flip()

def show_instruction(text, key):
    show_text(text)
    event.waitKeys(keyList=[key]) # change to button on resp_box
    win.flip()

def present_trial(stim, resp_label):
    response_stim.text = resp_label
    response_stim.draw()
    stim.draw()
    win.flip()
    trial_onset = core.monotonicClock.getTime()
    return trial_onset

def present_inter_block_stim():
    # Variable inter-block duration
    show_text('+')
    min_blank_dur = 10
    max_blank_dur = 14
    ## for dummy testing
    # min_blank_dur = 1
    # max_blank_dur = 2

    blank_dur = 0
    while (blank_dur < min_blank_dur) or (blank_dur > max_blank_dur):
        blank_dur = random.uniform(min_blank_dur,max_blank_dur)
    #    print blank_dur
    #print 'Final:', blank_dur
    core.wait(blank_dur)

    # show instruction at the start of every block
    show_text(BLOCK_INSTR)
    instr_onset = core.monotonicClock.getTime()
    core.wait(4.0) # B&L presented instructions for 4.0s
    return instr_onset

def wait_for_trigger(trigger='5'):
    p = event.waitKeys(maxWait=9999,
                       keyList=trigger,
                       timeStamped=core.monotonicClock)
    return p[0][1] # Return the timestamp of the pulse

def wait_baseline(n_triggers=1):
    for n in range(n_triggers):
        wait_for_trigger()
    baseline_onset = core.monotonicClock.getTime()
    return baseline_onset

def present_hand_localiser_stim():

    # start activation block for 20s
    hand_localiser_onset = core.monotonicClock.getTime()
    core.wait(20.0)
    hand_localiser_offset = core.monotonicClock.getTime()

    return hand_localiser_onset, hand_localiser_offset

###################################
# Functions to run the experiment #
###################################

def run_exp():

     # Show an intro text during setup
    show_instruction(WELCOME_INSTR, 'space')

    # practice trials
    show_instruction(PRAC_INSTR, 'space') #
    show_instruction(BLOCK_INSTR, 'space')

    for stim in prac_stim_names:
        prac_img = visual.ImageStim(win, image = pic_dir + stim)
        response_stim.text = resp_eat_side
        prac_img.draw()
        response_stim.draw()
        win.flip()
        core.wait(2.0) #0.01/2.0

    show_instruction(PRAC_END_INSTR, 'space') 

    # show the actual trials
    #current_n_block = None
    current_run_n = None
    num_block = None

    for trial in trials:

        # Wait for 5 triggers once every run
        if trial['run_number'] != current_run_n:
            win.flip()
            # show a fixation during excess time
            show_instruction('+', 'space')    
            # Show a text asking participants to switch respond hand
            show_instruction(RUN_INSTR, 'space')
            # wait for n pulses: baseline
            baseline_onset = wait_baseline()

        # Keep track of run number
        current_run_n = trial['run_number']

        # Pause between blocks
        if trial['num_block'] != num_block:
            # Variable inter-block duration
            instr_onset = present_inter_block_stim()
            event.clearEvents()
        # Keep track of block number
        num_block = trial['num_block']

        # Show the trial
        stim = std_stims[trial['stim_name']]
        trial_onset = present_trial(stim, resp_eat_side)
        core.wait(2.0) # 0.01/2.0

        # Collect responses
        # OM: changed Jun 28 2024 to "1" and "2" for new button box
        resps = event.getKeys(keyList=['1', '2'], # 1 is on the left
                              timeStamped=core.monotonicClock)

        # Store the data
        if resps:
            trials.addData('response', resps[0][0])
            trials.addData('RT', resps[0][1])

        # Store extra data about subject and experiment
        trials.addData('Subject number', SUBJECT)
        trials.addData('n_b', int(num_block))
        trials.addData('left_side_resp_label', resp_eat_side)
        trials.addData('trial_onset', trial_onset)
        trials.addData('blk_instr_onset', instr_onset)
        trials.addData('baseline_onset', baseline_onset)

    # Show instruction to start hand localiser task
    show_instruction(LOCALISER_INSTR, 'space')

    # Start hand localiser task (8 blocks in total)
    baseline_onset = wait_baseline() # wait for trigger again

    for trial_i in trials_localiser:

        # show instruction to counterbalance starting hand/finger
        show_text('Please tap your ' + trial_i['hand'] + ' ' + trial_i['finger'] + ' finger and thumb together as fast as you can comfortably do it.\n\nYou may begin after the instruction disappears.')
        core.wait(4.0) # 1.0/4.0
        win.flip()

        hand_localiser_onset = present_hand_localiser_stim()

        # Store extra data about subject and experiment
        trials_localiser.addData('hand_localiser_onset', hand_localiser_onset) 


    # Show thanks screen
    show_text('That was it -- thanks!')

     # Save the data
     ### SD: added 'appendFile=False' and changed fileCollisionMethod to 'overwrite' instead of 'rename' so that the arguments correspond to changes in Python 3. 
    fname = '%s%s_%i' % (data_dir, START_TIME, SUBJECT)  
    trials.saveAsWideText(fname + '.csv',
                          delim=',', appendFile=False,fileCollisionMethod='overwrite')
                          
    trials_localiser.saveAsWideText(fname + '_localiser.csv',
                          delim=',', appendFile=False, fileCollisionMethod='overwrite') 
                        
    event.waitKeys(maxWait=999, keyList=['space'])
    core.quit()

#######################################################
# Run the experiment if this file is invoked directly #
#######################################################

if __name__ == '__main__':
    run_exp()
