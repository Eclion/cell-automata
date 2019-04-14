# Cell AutoMata

## Instructions to start the program

To use this program, you either need Matlab or Octave installed on your computer.

Once installed, open the file UI.m file and run the program.

Please note that running the simulations on Octave is slower than on Matlab.


## Instructions to use the program

Before running a simulation, you can change the following parameters:
* the minimum number of living neighbor cells needed for a living cell to survive (rule i) )
* the maximum number of living neighbor cells needed for a living cell to survive (rule iii) )
* the number of living neighbor cells needed for an empty/dead cell to become a living cell (rule iv) )
* the maximum number of living neighbor cells which will prevent a live cell from moving (rule v) )
* "Save 2D dish snapshot" will save a 2D representation of the dish as an image at the steps presents in the "Snaphot steps" parameter. E cells are green while M cells are red.
* "Snapshot steps" represents the steps where a snapshot of the dish is needed.
* "Number of steps" is the number of steps a simulation will go through.
* "Initial number of cell" is the number of cell before any treatment.
* "Percentages of surviving cells" is a number from 0 to 100.
* "Dish size" is the size of the square dish.
* "Dish height" is the height of the dish.

Once the parameters are set, you can run the simulations by clicking on the button "Run simulations". A "Simulations" folder will be created to save data related to the simulations.
