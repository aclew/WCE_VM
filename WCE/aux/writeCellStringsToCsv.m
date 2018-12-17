function writeCellStringsToCsv(cellarray,filename)
% function writeCellStringsToCsv(cellarray,filename)
%
% Writes a cell array with cells consisting of strings and numbers into a 
% .csv file.

fid = fopen(filename,'w','n');

for k = 1:size(cellarray,1)
    for j = 1:size(cellarray,2)
        if(ischar(cellarray{k,j}))
            fprintf(fid,cellarray{k,j});
        else
            fprintf(fid,num2str(cellarray{k,j}));
        end
        if(j < size(cellarray,2))
            fprintf(fid,',');
        else
            fprintf(fid,'\n');
        end
    end    
end

fclose(fid);

