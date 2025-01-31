from pathlib import Path
import json
import pandas as pd


## Add the "IntendedFor" field to fmap files.

bids_dir = Path.home() / "proj" / "SSH" / "BIDS_dataset"

# Get all subject IDs
participants_filepath = bids_dir / "participants.tsv"
participants = pd.read_csv (participants_filepath, sep = '\t')
# Subset by handedness?
participants_sub = participants.query('group.str.contains("L")')

subjects = participants_sub['participant_id'].tolist()

# Or, manually specify subjects:
# subjects = [
#     "sub-155"
# ]

for subject in subjects:
    # - Find the subject's fmap folder
    fmap_dir = bids_dir / subject / "fmap"

    # - Find the four json files in the fmap folder
    nochmani_jsons = list(fmap_dir.glob("*nochmani*.json"))
    tap_jsons = list(fmap_dir.glob("*tap*.json"))


    intended_for_nochmani = [
        f'func/{subject}_task-nochmani_run-01_bold.nii',
        f'func/{subject}_task-nochmani_run-02_bold.nii',
        f'func/{subject}_task-nochmani_run-03_bold.nii',
        f'func/{subject}_task-nochmani_run-04_bold.nii'
    ]
    intended_for_tap = [
        f'func/{subject}_task-tap_bold.nii'
    ]

    for filename in nochmani_jsons:
        with open(filename) as f:
            data = json.load(f)
            data.update({"IntendedFor":intended_for_nochmani})
            with open(filename, 'w') as outfile:
                json.dump(data, outfile,indent=2,sort_keys=True)

    for filename in tap_jsons:
        with open(filename) as f:
            data = json.load(f)
            data.update({"IntendedFor":intended_for_tap})
            with open(filename, 'w') as outfile:
                json.dump(data, outfile,indent=2,sort_keys=True)




