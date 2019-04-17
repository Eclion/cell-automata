function runSimulationBatch(handles, rootFolder, survivalPercentage, dishSize, dishHeight, initNbCells, nbSimulations, nbSteps, survival, birth, movePercentage, enableSnapshots, snapshotSteps, maxToMove)

backupConfig(rootFolder, survivalPercentage, dishSize, dishHeight, initNbCells, nbSimulations, nbSteps, survival, birth, movePercentage, enableSnapshots, snapshotSteps, maxToMove);

colors = 'brg';

if(isstruct(handles))
    axes(handles.curvesPlot);
    cla reset;
end
    
curvesData = zeros(nbSimulations,nbSteps+1);

    pts = zeros(nbSimulations,nbSteps+1);
        
    snapshotFolder = strcat(rootFolder, '/snapshots/');
    
    data = zeros(2,nbSimulations);
    mPercents = zeros(nbSimulations,nbSteps+1);
    for i = 1:nbSimulations
        
        if(isstruct(handles))
            set(handles.progressText, 'string', strcat('Current simulation: ', num2str(i), '/', num2str(nbSimulations)));
            drawnow;
        end
        
        [a,b,c]=simulateCancer(enableSnapshots, dishSize,dishHeight,initNbCells,snapshotSteps,survivalPercentage/100,survival, birth,movePercentage,snapshotFolder,nbSteps,maxToMove);
        
        data(1,i) = a;
        data(2,i) = b(nbSteps+1)/min(b);
        
        pts(i,:) = b;
        
        if(isstruct(handles))
            plot(0:nbSteps,b(:), 'Color',colors(1), 'LineWidth',5);hold on;
            drawnow;
        end
        
        mPercents(i,:)=c;
    end
    curvesData(:,:) = pts;
    
    % save of the workspace's data(ratio/simu, growth rate /simu) and pts(nb of cells per steps / simu) variables
    save(strcat(rootFolder, 'cells.mat'), 'data', 'pts', 'mPercents');


saveFigure(rootFolder, colors, curvesData);

if(isstruct(handles))
    set(handles.progressText, 'string', strcat(num2str(nbSimulations), ' done.'));
    drawnow;
end

end


function saveFigure(rootFolder, colors, points)

global isMatlab;
if(isMatlab)
    f=figure('visible', 'off');
else
    f=figure();
end

plot(0:(length(points)-1),points(:), 'Color','g', 'LineWidth',5);hold on;
xlabel('Time (in steps)')
ylabel('Number of cells')
saveas(f,strcat(rootFolder, '/curves.png'));
close(f);

end

function backupConfig(rootFolder, survivalPercentage, dishSize, dishHeight, initNbCells, nbSimulations, nbSteps, survival, birth, movePercentage, enableSnapshots, snapshotSteps, maxToMove)

backupFileID = fopen(strcat(rootFolder, 'config.ini'), 'wt');


fprintf(backupFileID, 'SAVE_SNAPSHOTS : %d;\n', enableSnapshots);
fprintf(backupFileID, 'MAX_BIRTH : %d;\n', max(birth));
fprintf(backupFileID, 'MIN_BIRTH : %d;\n', min(birth));
fprintf(backupFileID, 'MIN_SURVIVAL : %d;\n', min(survival));
fprintf(backupFileID, 'MAX_SURVIVAL : %d;\n', max(survival));
fprintf(backupFileID, 'NB_STEPS : %d;\n', nbSteps);
fprintf(backupFileID, 'MAX_TO_MOVE : %d;\n', maxToMove);
fprintf(backupFileID, 'PERCENTAGE_SURVIVAL : %s;\n', mat2str(survivalPercentage));
fprintf(backupFileID, 'PERCENTAGE_MOVEMENT : %s;\n', mat2str(movePercentage));

if(~isempty(snapshotSteps))
    fprintf(backupFileID, 'SNAPSHOT_STEPS : %s;\n', mat2str(snapshotSteps));
end


fprintf(backupFileID, 'DISH_SIZE : %d;\n', dishSize);
fprintf(backupFileID, 'DISH_HEIGHT : %d;\n', dishHeight);
fprintf(backupFileID, 'NB_SIMULATIONS : %d;\n', nbSimulations);
fprintf(backupFileID, 'INIT_NB_CELLS : %d;\n', initNbCells);

fprintf(backupFileID, 'END;');
fclose(backupFileID);

end
