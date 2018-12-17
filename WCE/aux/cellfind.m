function y = cellfind(cellarray,string,type)
%function y = cellfind(cellarray,string,type)
if nargin <3
    type = 'partial';
end

if(strcmp(type,'partial'))
    y = find(~cellfun(@isempty,strfind(cellarray,string)));
else
    y = find(strcmp(cellarray,string));
end