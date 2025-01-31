
## Getting Started:
<br/> 

### Mac OS

#### Confirm that you have Python 3 installed
Open a terminal window and type:
```
which python3
```
If `python3` is installed, you will see something like this:
```
$ which python3
/usr/bin/python3
```

If nothing is returned then you will need to install the most recent version of Python3 either via a package manager like [Homebrew](https://brew.sh/) (recommended) or by downloading an installer from the Python website:  https://www.python.org/downloads/.
<br/>  
 

#### Updating `pip`
To update the Python package manager `pip`, please type the following:  
```
python3 -m pip install --user --upgrade pip
```

To confirm that `pip` is installed, you can type:
```
python3 -m pip --version
```
<br/>

#### Setting up a virtual environment using `venv`

```
# change directories to the root of this project
cd nochmani_fmri
```

```
# create an environment named `env`
python3 -m venv env
```

```
# activate the environment
source env/bin/activate
```

```
# ensure that you have the latest pip in the virtual environment  
pip install --upgrade pip
```

```
# install the required packages
pip install -r requirements.txt
```

```
# deactivate the environment
deactivate
```
</br>

#### Activating and deactivating the environment
```
# change directories to the root of this project 
# (if you are not already there)
cd nochmani_fmri
```

```
# activate the environment
source env/bin/activate
```

```
# do your work :-) 
```

```
# deactivate the environment
deactivate
```
<br/>

## build/installation results

| CPU | OS | Python |  Result |
|-|-|-|-|
| `x86_64` | `MacOS 12.6.7` | `3.9.6`  | `PASS` |
<br/>  

An attempt was made to install on an M1-based (arm64) Mac, but the  
OpenCV portion of the `pip install` process failed.  

Folks have had success installing OpenCV on an M1 Mac though:  
https://opencv.org/blog/2021/07/26/opencv-python-for-apples-m1-chip-a-detective-story-with-a-happy-ending/


---

# Set-up On Windows:

## Step 1. 
### Download and Install Python 3.11 through the official website: https://www.python.org/downloads/

## Step 2. 
### Open Windows Powershell 

The first command prompt should be: 
```
python -m pip install
```
(pip is typically downloaded along with Python automatically) 
If you want, before entering the first command prompt, you may run simply python and if the result includes details about the version of python etc., then you know that you have successfully installed python. 
 
## Step 3. 
### Creating the Virtual Environment (venv)
The next thing you want to do is set up a virtual environment where you can install all the necessary python packages that allow you to run the script. 

The prompt for beginning to set up a venv in Windows Powershell is pip install virtualenv
This should give you the following result:

```
Collecting virtualenv
  Using cached virtualenv-20.23.1-py3-none-any.whl (3.3 MB)
Collecting distlib<1,>=0.3.6 (from virtualenv)
  Using cached distlib-0.3.6-py2.py3-none-any.whl (468 kB)
Collecting filelock<4,>=3.12 (from virtualenv)
  Using cached filelock-3.12.2-py3-none-any.whl (10 kB)
Collecting platformdirs<4,>=3.5.1 (from virtualenv)
  Using cached platformdirs-3.8.0-py3-none-any.whl (16 kB)
Installing collected packages: distlib, platformdirs, filelock, virtualenv
Successfully installed distlib-0.3.6 filelock-3.12.2 platformdirs-3.8.0 virtualenv-20.23.1
```


Once you have installed the venv function through pip, you can begin using it to set up a venv that is specific to your project/script. 

In order to set up a venv, first change the directory of the command prompt to the folder within which you want to create your project folder. For example, in a folder that you may choose to call ‘Projects’ you can create another folder called ‘Script1’. This latter folder is the one in which your script and data should be located. Alternatively, if you already have your script and data in a folder, you can simply create a venv in that specific folder by using its path directory. 

So your first step is to change the directory to the general folder where your script’s folder is located. You can do this by the following prompt: 
```
cd  <insert full path copied from folder>
```
After executing your cd command, the beginning of your command prompt should display the path you copied. For example: 

If I put in the following command:

```
PS C:\WINDOWS\system32> cd  C:\Users\dalal\Desktop\Nochmani
```

My result should be an empty command line that is now in the directory I entered above: 
```
C:\Users\dalal\Desktop\Nochmani>
```

In this new directory, to create the venv, you  will now enter the following command prompt: 
```
python -m venv C:\...<insert full path to the folder which you want your venv to be and where you will add your script and data>
```
This should cause the folder you chose to be populated with a Scripts folder and a pyvenv file. 

## Step 4. 
### Activating the venv

Once you have setup your venv, you will need to activate it. You can do this by entering the following command prompt: 

```
<name of venv folder you chose earlier>\Scripts\activate
```
This will have activated your venv! 

The next step is to install psychopy, the package into your virtual environment using the following command: 
```
pip install psychopy
```
# Steps to download git repo on Windows:

## Step 1. 
### Download and Install Python 3.11 through the official website: https://www.python.org/downloads/

## Step 2. 
### Open Windows Powershell (not as admin)

The first command prompt should be: 
```
python -m pip install
```

(pip is typically downloaded along with Python automatically) 
If you want, before entering the first command prompt, you may run simply python and if the result includes details about the version of python etc., then you know that you have successfully installed python. 

## Step 3.  
### Download git repo 

Once you open the git repo ‘nochmani’, you should see a drop down option on the green button ‘code’.  When you click the dropdown, you will see an option to copy the link to the repo. This is the link you should find (you can also just copy it from here): 
```
https://github.com/kep82CU/nochmani.git
```
Once you’ve copied the link, in Powershell, type the following command (make sure your directory is the place where you want the project folder, i.e. the main folder where all the .py and data files for the experiment are,  to be located):

```
git clone https://github.com/kep82CU/nochmani.git   (the link above)
```

This should create a folder called ‘nochmani’ in the directory that you specified. The folder will contain some files, but since at this step you have downloaded the main branch of the git repo (which does not contain the new 2023 .py script and only contains the 2018 script), you want to open a different branch (dev branch). 

In order to open the dev branch, type the following command into Powershell:
```
git checkout dev
```

And now, the same folder ‘nochmani’ should look different, that is, it should contain the new python script (2023) and other relevant files and folders. 

## Step 4. 
### Creating the Virtual Environment (venv)

The next thing you want to do is set up a virtual environment where you can install all the necessary python packages using the requirements.txt file in the nochmani folder that allows you to run the script. 

In order to set up a venv, first change the directory of the command prompt to the nochmani folder.  In this new directory (it is essential that you are in the correct directory), to create the venv, you  will now enter the following command prompt: 

```
python -m venv venv
```
This should cause the folder you chose to be populated with a folder called venv. 

## Step 4. 
### Activating the venv

Once you have setup your venv, you will need to activate it. You can do this by entering the following command prompt: 

```
<name of venv folder you chose earlier>\Scripts\activate
```
This will have activated your venv! (You should see a green ‘venv’ before your directory in all the cmd prompts in Powershell)

The next step is to install all the packages relevant to the experiment through the requirements.txt file. 

## Step 5. 
### Running the experiment 

To collect all the necessary packages type the following command into your powershell command prompt (make sure your venv is still activated and that you are in the appropriate directory):
```
pip install -r requirements.txt
```
The result of entering this command should be a very long series of code describing the packages being installed. 

Now, before you run the .py script, you need to edit the data_dir and pic_dir objects in the script.  You can do this by opening the .py script in the application ‘Notepad’. And looking for where the objects data_dir and pic_dir are located. They will look something like the following: 
```
data_dir = os.path.expanduser('C:/Users/guest1/Desktop/nochmani/data/')
pic_dir = os.path.expanduser('C:/Users/guest1/Desktop/nochmani/image_stimuli/')
```
Replace what is contain within the parentheses with the directory on your computer. You can do this by opening the ‘data’ and ‘image_stimuli’ folders that are located in the nochmani folder you downloaded from the git repo and copying their path directories and pasting them into the parenthese—make sure to switch the \ to /  . 

Once you have made this change to the script, press save and run the script in the venv in Powershell by entering the following command: 
```
python nochmani_fmri_July2023.py  #(which is the name of the script currently and .py; however, since the name may change just remember to type python <script name>.py)
```

That’s it! Hope it worked! 


