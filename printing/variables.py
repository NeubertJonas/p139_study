"""This file contains all variables for the add_labels.py script.

Changes to this file are required when the unlabeled reference PDFs have changed.

"""
# pylint: disable=C0103


# Get user input for participant ID, day, and date

ID_1 = input("Enter the first participant ID: P139")
ID_1 = "P139"+ID_1
ID_2 = input("Enter the second participant ID: P139")
ID_2 = "P139"+ID_2

while ID_1 == ID_2:
    print("Error! The participant IDs must be different.")
    ID_2 = input("Enter the second participant ID: P139")
    ID_2 = "P139"+ID_2


day = ""
while day != "1" and day != "2":
    day = input("First or second acute testing day? [1/2]: ")

    if day != "1" and day != "2":
        print("Invalid input. Please enter 1 or 2.")

    if day == "1":
        day = "A1"
        break

    elif day == "2":
        day = "A3"
        break


date = input("Enter the date (e.g., 19.04.1943): ")
print("")
output = "print_"+ID_1+"+"+ID_2+"_"+day+".pdf"


# Define page ranges
# Enter page numbers for IOS and handout
# The rest uses the default portrait header

ios = [2, 7, 17, 19, 26, 30, 33]
handout = [34]
portrait = list(range(0, 35))
portrait = [x for x in portrait if x not in ios and x not in handout]


# Define temporary file names

portrait_tmp = "tmp_portrait.pdf"
ios_tmp = "tmp_ios.pdf"
handout_tmp = "tmp_handout.pdf"
couple_tmp = "tmp_couple.pdf"

# Define reference PDFs which contain unlabelled headers

per_participant = "print_per_participant_TD_v4.pdf"
per_day = "print_per_testing_day_v2.pdf"
