# TimetableR
Timetable scheduling problem is a constraint satisfaction problem around scheduling resources. It can be a tedious and frustrating job due to the NP-hard nature of the problem. This repository contains an implementation of a [solution](https://www.academia.edu/download/56355803/52a46bee76a6395818da5984aacdb4e7568b.pdf) to the problem using genetic algorithms in R. 

## Constraints
The timetable satisfies the following conditions:
- All lectures should take place exactly once
- Group *g* can attend only one class at one
time
- Instructor *i* can teach only one class at one
time
- In room *r* only one class can be taught at one
time

## Usage

- #### Method 1
    - Create `csv` files for each of the following
       - Available time slots
       - Available rooms
       - Requirements of the form (Course, Professor, Room1, Room2, Slot1, Slot2) including the header (refer [this](https://github.com/chiefsan/TimetableR/blob/master/initialData.csv))
- #### Method 2
    - Modify the code in the method `main` by commenting and uncommenting the necessary lines to read input from the terminal

## License
[MIT](https://github.com/chiefsan/TimetableR/blob/master/LICENSE)
