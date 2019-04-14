function UI()

close all
clear

global workFolder;
workFolder=pwd;

global isMatlab;

try
    eval('graphics_toolkit qt;');
catch error
    isMatlab=true;
end


f = createMainFigure();

handles = createStaticUI(f);

% get config file values
numberOfSimulations = getFromConfigOrDefault('NB_SIMULATIONS',1);
numberOfSteps = getFromConfigOrDefault('NB_STEPS',20);
initialNumberOfCells = getFromConfigOrDefault('INIT_NB_CELLS',28500);
snapshotSteps = getFromConfigOrDefault('SNAPSHOT_STEPS', []);
dishSize = getFromConfigOrDefault('DISH_SIZE',300);
dishHeight = getFromConfigOrDefault('DISH_HEIGHT',4);
minSurvival = getFromConfigOrDefault('MIN_SURVIVAL',2);
maxSurvival = getFromConfigOrDefault('MAX_SURVIVAL',3);
minBirth = getFromConfigOrDefault('MIN_BIRTH',3);
maxBirth = getFromConfigOrDefault('MAX_BIRTH',3);
percentageSurvival = getFromConfigOrDefault('PERCENTAGE_SURVIVAL', []);
enableSnapshots = strcmp(getFromConfigOrDefault('SAVE_SNAPSHOTS', 'OFF'), 'ON');

handles2 = createRulesUI(handles);
handles3 = createGraphicParamsUI(handles2, enableSnapshots, snapshotSteps);
handles4 = createSimulationParamsUI(handles3, numberOfSimulations, numberOfSteps, initialNumberOfCells, percentageSurvival);
handles5 = createDishParamsUI(handles4, dishSize);

guidata (f, handles5)

set(handles5.minimumSurvival,'string',minSurvival);
set(handles5.maximumSurvival,'string',maxSurvival);
set(handles5.minimumBirth,'string',minBirth);
set(handles5.maximumBirth,'string',maxBirth);
set(handles5.dishHeight,'string',dishHeight);
guidata (f, handles5)

end


% ----------------------- UI GENERATION ---------------------------

function f = createMainFigure()
screensize = get(0, 'screensize');

height = 600;
width = 1300;

f = figure('position', [(screensize(3)-width)/2 (screensize(4)-height)/2 width height], 'color', get(0, 'defaultuicontrolbackgroundcolor'), 'toolbar', 'none', 'menubar', 'none', 'name', 'Cell AutoMata', 'numbertitle', 'off');
end

function handles = createStaticUI(f)

handles.panel = uipanel('parent',f, 'title', 'Simulation Properties', 'position', [0.01 0.01 0.59 0.98]);

handles.rulePanel = uipanel('parent', handles.panel, 'title', 'Rules', 'position', [0.01 0.50 0.98 0.49]);

handles.graphicPanel = uipanel('parent', handles.panel, 'title', 'Graphic Parameters', 'position', [0.01 0.01 0.32 0.48]);

handles.simulationPanel = uipanel('parent', handles.panel, 'title', 'Simulation Parameters', 'position', [0.34 0.01 0.32 0.48]);

handles.dishPanel = uipanel('parent', handles.panel, 'title', 'Dish Parameters', 'position', [0.67 0.21 0.32 0.28]);

handles.runButton = uicontrol('parent', handles.panel, 'style', 'pushbutton', 'units', 'normalized', 'string', 'Run simulations', 'callback', @runSimulationButton_Callback, 'position', [0.67 0.01 0.32 0.20]);


handles.curvesPlot = axes('parent', f, 'position', [0.62 0.21 0.36 0.77]);
handles.progressText = uicontrol('parent', f, 'style', 'text', 'units', 'normalized', 'position', [0.62 0.01 0.36 0.16], 'string', '', 'fontunits', 'normalized', 'fontsize',0.15, 'horizontalalignment', 'center');

end

function handles = createRulesUI(handles)

lineSize = 0.10;

% ----- first rule ----------------------
minSurvLineY = 0.85;
handles.minSurvPart1 = uicontrol('parent',handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 minSurvLineY 0.18 lineSize], 'string', 'i)   Any cell with < ', 'fontsize',10, 'horizontalalignment', 'left');
handles.minimumSurvival = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.20 minSurvLineY 0.09 lineSize], 'string', '2', 'fontsize',10, 'horizontalalignment', 'center', 'callback', @minimumSurvival_Callback);
handles.minSurvPart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.31 minSurvLineY 0.5 lineSize], 'string', 'live neighbors dies, caused by under-population.', 'fontsize',10, 'horizontalalignment', 'left');

% ----- second rule ----------------------
survivalLineY = 0.70;
handles.survivalPart1 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 survivalLineY 0.18 lineSize], 'string', 'ii)  Any cell with ', 'fontsize',10, 'horizontalalignment', 'left');
handles.survival = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.20 survivalLineY 0.09 lineSize], 'string', {'2 to 3'}, 'fontsize',10, 'horizontalalignment', 'center');
handles.survivalPart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.31 survivalLineY 0.5 lineSize], 'string', 'live neighbors lives on the next generation.', 'fontsize',10, 'horizontalalignment', 'left');


% ----- third rule ----------------------
maxSurvLineY = 0.55;
handles.maxSurvPart1 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 maxSurvLineY 0.18 lineSize], 'string', 'iii) Any cell with > ', 'fontsize',10, 'horizontalalignment', 'left');
handles.maximumSurvival = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.20 maxSurvLineY 0.09 lineSize], 'string', '3', 'fontsize',10, 'horizontalalignment', 'center', 'callback', @maximumSurvival_Callback);
handles.maxSurvPart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.31 maxSurvLineY 0.5 lineSize], 'string', 'live neighbors dies, caused by overcrowding.', 'fontsize',10, 'horizontalalignment', 'left');


% ----- fourth rule ----------------------
birthLineY = 0.40;
handles.birthPart1 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 birthLineY 0.27 lineSize], 'string', 'iv)  Any dead/empty cell with', 'fontsize',10, 'horizontalalignment', 'left');
handles.minimumBirth = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.28 birthLineY 0.05 lineSize], 'string', '3', 'fontsize',10, 'horizontalalignment', 'center', 'callback', @minimumBirth_Callback);
handles.birthPart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.34 birthLineY 0.02 lineSize], 'string', 'to', 'fontsize',10, 'horizontalalignment', 'left');
handles.maximumBirth = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.37 birthLineY 0.05 lineSize], 'string', '3', 'fontsize',10, 'horizontalalignment', 'center', 'callback', @maximumBirth_Callback);
handles.birthPart5 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.43 birthLineY 0.55 lineSize], 'string', 'live neighbors becomes live cell as by reproduction.', 'fontsize',10, 'horizontalalignment', 'left');

% ----- fifth rule ----------------------

moveLineY = 0.25;
handles.movePart1 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.01 moveLineY 0.18 lineSize], 'string', 'v) Any cell with < ', 'fontsize',10, 'horizontalalignment', 'left');
handles.maxToMove = uicontrol ('parent', handles.rulePanel, 'style', 'edit', 'units', 'normalized', 'position', [0.20 moveLineY 0.09 lineSize], 'string', '3', 'fontsize',10, 'horizontalalignment', 'center', 'callback', @maxToMove_Callback);
handles.movePart3 = uicontrol ('parent', handles.rulePanel, 'style', 'text', 'units', 'normalized', 'position', [0.31 moveLineY 0.7 lineSize], 'string', 'live neighbors is able to move randomly to an empty cell on the next generation.', 'fontsize',10, 'horizontalalignment', 'left');

end
function handles = createGraphicParamsUI(handles, enableSnapshots, snapshotSteps)

handles.dishSnapshots = uicontrol ('parent', handles.graphicPanel, 'style', 'checkbox', 'units', 'normalized', 'position', [0.03 0.75 0.96 0.15], 'string', 'Save 2D dish snapshots', 'fontsize',10, 'value', enableSnapshots, 'horizontalalignment', 'left');

lineY = 0.35;
handles.snapshotStepsText = uicontrol ('parent', handles.graphicPanel, 'style', 'text', 'units', 'normalized', 'position', [0.03 lineY 0.42 0.15], 'string', 'Snapshot steps:', 'fontsize',10, 'horizontalalignment', 'left');

handles.snapshotSteps = uicontrol ('parent', handles.graphicPanel, 'style', 'edit', 'units', 'normalized', 'position', [0.48 lineY 0.50 0.15], 'string', num2str(snapshotSteps), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @snapshotSteps_Callback);

end
function handles = createSimulationParamsUI(handles, numberOfSimulations, numberOfSteps, initialNumberOfCells, percentageSurvival)
boxX = 0.70;
textWidth = boxX - 0.03;
boxWidth = 1 - boxX - 0.02;
height = 0.15;

firstLineY = 0.75;
handles.numberOfSimulationsText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 firstLineY textWidth height], 'string', 'Number of simulations:', 'fontsize',10, 'horizontalalignment', 'left');

handles.numberOfSimulations = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX firstLineY boxWidth height], 'string', num2str(numberOfSimulations), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @numberOfSimulations_Callback);


secondLineY = 0.55;
handles.numberOfStepsText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 secondLineY textWidth height], 'string', 'Number of steps:', 'fontsize',10, 'horizontalalignment', 'left');

handles.numberOfSteps = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX secondLineY boxWidth height], 'string', num2str(numberOfSteps), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @numberOfSteps_Callback);

thirdLineY = 0.35;
handles.initialNumberOfCellsText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 thirdLineY textWidth height], 'string', 'Initial number of cells:', 'fontsize',10, 'horizontalalignment', 'left');

handles.initialNumberOfCells = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX thirdLineY boxWidth height], 'string', num2str(initialNumberOfCells), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @initialNumberOfCells_Callback);

fourthLineY = 0.15;
handles.percentageSurvivalText = uicontrol ('parent', handles.simulationPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 fourthLineY textWidth height], 'string', '% of surviving cells [0-100]:', 'fontsize',10, 'horizontalalignment', 'left');

handles.percentageSurvival = uicontrol ('parent', handles.simulationPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX fourthLineY boxWidth height], 'string', num2str(percentageSurvival), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @percentageSurvival_Callback);
end
function handles = createDishParamsUI(handles, dishSize)
boxX = 0.70;
textWidth = boxX - 0.03;
boxWidth = 1 - boxX - 0.02;
height = 0.20;

firstLineY = 0.60;
handles.dishSizeText = uicontrol ('parent', handles.dishPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 firstLineY textWidth height], 'string', 'Dish size:', 'fontsize',10, 'horizontalalignment', 'left');

handles.dishSize = uicontrol ('parent', handles.dishPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX firstLineY boxWidth height], 'string', num2str(dishSize), 'fontsize',10, 'horizontalalignment', 'center', 'callback', @dishSize_Callback);


secondLineY = 0.30;
handles.dishHeightText = uicontrol ('parent', handles.dishPanel, 'style', 'text', 'units', 'normalized', 'position', [0.02 secondLineY textWidth height], 'string', 'Dish height:', 'fontsize',10, 'horizontalalignment', 'left');

handles.dishHeight = uicontrol ('parent', handles.dishPanel, 'style', 'edit', 'units', 'normalized', 'position', [boxX secondLineY boxWidth height], 'fontsize',10, 'horizontalalignment', 'center', 'callback', @dishHeight_Callback);
end

% ------------------------- METHODS ---------------------------

function [ bool ] = iscorrectnumber(value)
if isnan(value)
    bool = false;
elseif isempty(value)
    bool = false;
elseif ~strcmp(num2str(size(value)), num2str([1 1]))
    bool = false;
else
    bool = true;
end

end

function [ bool ] = iscorrectnumberarray(value)
if isnan(value)
    bool = false;
elseif ~isvector(value)
    bool = false;
else
    bool = true;
end

end

function [ value ] = getFromConfigOrDefault(name, defaultValue)
value = defaultValue;
if exist('config.ini', 'file')
    fileID = fopen('config.ini', 'r');
    lines = strsplit(fscanf(fileID, '%s'),{':', ';'});
    for i = 1:length(lines)/2
        currentArg = char(lines((i-1)*2+1));
        if (strcmp(currentArg,name))
            value = char(lines(i*2));
        elseif (strcmp(currentArg, 'END'))
            break;
        end
    end
end

end

function [ string ] = numberArray2String(numbers)
string = regexprep(num2str(numbers), '\s*', ', ');

end

function [ string ] = bool2OnOff(bool)
if(bool)
    string='ON';
else
    string='OFF';
end

end


% ------------------------- CALLBACKS ---------------------------

function numberOfSimulations_Callback(hObject, init)

handles = guidata (hObject);

numberOfSimulations = str2num(get(hObject, 'string'));

if ~iscorrectnumber(numberOfSimulations)
    set(hObject, 'string', '1');
    errordlg('The number of simulations to execute must be a number', 'Error');
elseif numberOfSimulations < 1
    set(hObject, 'string', '1');
    errordlg('The number of simulations to execute must be superior to 0', 'Error');
else
    set(hObject, 'string', num2str(numberOfSimulations));
end

guidata(hObject, handles)

end


function numberOfSteps_Callback(hObject, init)

handles = guidata (hObject);

numberOfSteps = str2num(get(hObject, 'string'));

if ~iscorrectnumber(numberOfSteps)
    set(hObject, 'string', '1');
    errordlg('The number of steps of each simulations must be a number', 'Error');
elseif numberOfSteps < 1
    set(hObject, 'string', '1');
    errordlg('The number of steps of each simulations to execute must be superior to 0', 'Error');
else
    set(hObject, 'string', num2str(numberOfSteps));
end

guidata(hObject, handles)
end


function initialNumberOfCells_Callback(hObject, init)

handles = guidata (hObject);

initialNumberOfCells = str2num(get(hObject, 'string'));
if ~iscorrectnumber(initialNumberOfCells)
    set(hObject, 'string', '0');
    errordlg('The initial number of cells of the dish must be a number', 'Error');
else
    set(hObject, 'string', num2str(initialNumberOfCells));
end
guidata(hObject, handles)

end

function snapshotSteps_Callback(hObject, init)

handles = guidata (hObject);

snapshotSteps = str2num(get(hObject, 'string'));

if ~iscorrectnumberarray(snapshotSteps)
    set(hObject, 'string', '');
    errordlg('The steps when a snapshot will be made must be a comma separated array of numbers', 'Error');
else
    set(hObject, 'string', num2str(snapshotSteps));
end

guidata(hObject, handles)

end

function percentageSurvival_Callback(hObject, init)

handles = guidata (hObject);

percentageSurvival = str2num(get(hObject, 'string'));

if ~iscorrectnumber(percentageSurvival)
    set(hObject, 'string', '');
    errordlg('The percentage of survival cells at start must be a numbers', 'Error');
else
    set(hObject, 'string', num2str(percentageSurvival));
end

guidata(hObject, handles)

end


function dishSize_Callback(hObject, init)

handles = guidata (hObject);

dishSize = str2num(get(hObject, 'string'));

if ~iscorrectnumber(dishSize)
    set(hObject, 'string', '1');
    errordlg('The size of the dish must be a number', 'Error');
elseif dishSize < 1
    set(hObject, 'string', '1');
    errordlg('The size of the dish must be superior to 0', 'Error');
else
    set(hObject, 'string', num2str(dishSize));
end

guidata(hObject, handles)

end


function dishHeight_Callback(hObject, init)

handles = guidata (hObject);

dishHeight = str2num(get(hObject, 'string'));

if ~iscorrectnumber(dishHeight)
    set(hObject, 'string', '1');
    errordlg('The height of the dish must be a number', 'Error');
elseif dishHeight < 1
    set(hObject, 'string', '1');
    errordlg('The height of the dish must be superior to 0', 'Error');
else
    set(hObject, 'string', num2str(dishHeight));
end

guidata(hObject, handles)

end



function minimumBirth_Callback(hObject, init)

handles = guidata (hObject);

maximumBirth = str2num(get(handles.maximumBirth, 'string'));
minimumBirth = str2num(get(hObject, 'string'));

if ~iscorrectnumber(minimumBirth)
    set(hObject, 'string', '0');
    errordlg('The minimum number of living neighbor cell required for a cell to be born from division must be a number.', 'Error');
    minimumBirth = 0;
elseif minimumBirth > maximumBirth
    set(hObject, 'string', num2str(maximumBirth));
    errordlg('The minimum number of living neighbor cell required for a cell to be born from division must be inferior or equal to the maximum.', 'Error');
    minimumBirth = maximumBirth;
else
    set(hObject, 'string', num2str(minimumBirth));
end

guidata(hObject, handles)

end


function maximumBirth_Callback(hObject, init)

handles = guidata (hObject);

maximumBirth = str2num(get(hObject, 'string'));
minimumBirth = str2num(get(handles.minimumBirth, 'string'));

if ~iscorrectnumber(maximumBirth)
    set(hObject, 'string', num2str(0));
    errordlg('The maximum number of living neighbor cell required for a cell to be born from division must be a number.', 'Error');
    maximumBirth = 0;
elseif maximumBirth < minimumBirth
    set(hObject, 'string', num2str(minimumBirth));
    errordlg('The maximum number of living neighbor cell required for a cell to be born from division must be superior or equal to the minimum.', 'Error');
    maximumBirth = minimumBirth;
else
    set(hObject, 'string', num2str(maximumBirth));
end

guidata(hObject, handles)

end


function minimumSurvival_Callback(hObject, init)

handles = guidata (hObject);

maximumSurvival = str2num(get(handles.maximumSurvival, 'string'));
minimumSurvival = str2num(get(hObject, 'string'));

if ~iscorrectnumber(minimumSurvival)
    set(hObject, 'string', '0');
    errordlg('The minimum number of living neighbor cell required for a living cell to survive must be a number.', 'Error');
    minimumSurvival = 0;
elseif minimumSurvival > maximumSurvival
    set(hObject, 'string', num2str(maximumSurvival));
    errordlg('The minimum number of living neighbor cell required for a living cell to survive must be inferior or equal to the maximum.', 'Error');
    minimumSurvival = maximumSurvival;
else
    set(hObject, 'string', num2str(minimumSurvival));
end

set(handles.survival, 'string', char(strcat(num2str(minimumSurvival), {' to '}, num2str(maximumSurvival))));

guidata(hObject, handles)

end


function maximumSurvival_Callback(hObject, init)

handles = guidata (hObject);

maximumSurvival = str2num(get(hObject, 'string'));
minimumSurvival = str2num(get(handles.minimumSurvival, 'string'));

if ~iscorrectnumber(maximumSurvival)
    set(hObject, 'string', num2str(0));
    errordlg('The maximum number of living neighbor cell required for a living cell to survive must be a number.', 'Error');
    maximumSurvival = 0;
elseif maximumSurvival < minimumSurvival
    set(hObject, 'string', num2str(minimumSurvival));
    errordlg('The maximum number of living neighbor cell required for a living cell to survive must be superior or equal to the minimum.', 'Error');
    maximumSurvival = minimumSurvival;
else
    set(hObject, 'string', num2str(maximumSurvival));
end

set(handles.survival, 'string', char(strcat(num2str(minimumSurvival), {' to '}, num2str(maximumSurvival))));

guidata(hObject, handles)

end

function maxToMove_Callback(hObject, init)

handles = guidata (hObject);

maxToMove = str2num(get(hObject, 'string'));

if ~iscorrectnumber(maxToMove)
    set(hObject, 'string', num2str(0));
    errordlg('The maximum number of living neighbor cell required for a living cell to move must be a number.', 'Error');
    maxToMove = 0;
else
    set(hObject, 'string', num2str(maxToMove));
end

set(handles.maxToMove, 'string', num2str(maxToMove));

guidata(hObject, handles)

end

% -------------------- BUTTONS CALLBACKS -----------------------


function runSimulationButton_Callback(obj, init)

global workFolder;
rootFolder = strcat(workFolder, '/Simulations/');
date = datestr(now, 'yyyy-mm-dd_HHMMSS');
dataFolder = strcat(rootFolder,date, '/');

handles = guidata(obj);

mkdir(rootFolder);
mkdir(dataFolder);
startSimulations(dataFolder, handles);
end


% ------------------- MODEL METHOD -----------------------------

function startSimulations(rootFolder, handles)

batchStart=tic;

% is this var really useful? we could disable it if snapshotSteps is empty
enableSnapshots = get(handles.dishSnapshots, 'Value');

nbSteps = str2num(get(handles.numberOfSteps, 'string'));
dishSize = str2num(get(handles.dishSize, 'string'));
dishHeight = str2num(get(handles.dishHeight, 'string'));
initNbCells = str2num(get(handles.initialNumberOfCells, 'string'));
survivalPercentage = str2num(get(handles.percentageSurvival, 'string'));
snapshotSteps = [];
if(enableSnapshots)
    snapshotSteps = str2num(get(handles.snapshotSteps, 'string'));
end
nbSimulations = str2num(get(handles.numberOfSimulations, 'string'));
minSurvival = str2num(get(handles.minimumSurvival, 'string'));
maxSurvival = str2num(get(handles.maximumSurvival, 'string'));
survival = minSurvival:maxSurvival;
minBirth = str2num(get(handles.minimumBirth, 'string'));
maxBirth = str2num(get(handles.maximumBirth, 'string'));
birth = minBirth:maxBirth;

% TODO rule maxToMove
maxToMove=2;
    
runSimulationBatch(handles, rootFolder, survivalPercentage, dishSize, dishHeight, initNbCells, nbSimulations, nbSteps, survival, birth, enableSnapshots, snapshotSteps, maxToMove);


disp('End of the simulations.')
toc(batchStart)
end
