function newStepCells = undergoFate(x,y,z,cells, newStepCells,survivalRules,birthRules,maxToMove)
%determine the fate of the cell at position x,y,z, in function of the previous state for the birth/survival rule, but also in function of its current state, to see if it can move or not

nz=size(cells,3);
dz=max(1,z-1):min(nz,z+1);

tmpNeighbors(:,:) = calculateNeighbors(x,y,cells);
neighbors = tmpNeighbors(:,1)+tmpNeighbors(:,2);

if(cells(x,y,z)==0) %if there is no cell at grid(x,y), then check if a new one can live
    if (any(sum(neighbors(dz)) == birthRules))
        newStepCells(x,y,z)=1;% an epithelial cell is born
    end
elseif(cells(x,y,z)~=0)%else %if there is a cell at grid(x,y)
    if (~any(sum(neighbors(dz))-1 == survivalRules)) % '-1' because the current cell is living
        newStepCells(x,y,z) = 0;
    elseif (sum(neighbors(dz))-1 <=maxToMove)%movement of the cells
        availableNeighborPositions=listAvailableNeighborPositions(cells,newStepCells,x,y,z);
        rp=rand();%random number for the direction of the movement.
        availableNeighborPositionCount=size(availableNeighborPositions,1);
        if(availableNeighborPositionCount~=0)
            index=round(rp*(availableNeighborPositionCount-1))+1;
            nextPosition=availableNeighborPositions(index,:);
            newStepCells(nextPosition(1),nextPosition(2),nextPosition(3)) = 1;
            newStepCells(x,y,z) = 0;
        else
            newStepCells(x,y,z) = 1;
        end
    else
        newStepCells(x,y,z) = cells(x,y,z);
    end
end
end