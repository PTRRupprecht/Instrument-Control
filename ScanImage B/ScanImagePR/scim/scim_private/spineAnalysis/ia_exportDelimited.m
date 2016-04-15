function ia_exportDelimited(hObject, fullname, delimiter)

f = fopen(fullname, 'w');
if f == -1
    fprintf(2, 'stackBrowser: Failed to open file ''%s'' - %s\n', fullname, lasterr);
    errordlg(sprintf('Failed to open file: %s - %s', fullname, lasterr));
end

%Print a small header.
fprintf(f, 'Version: 1\r\n');
fprintf(f, 'Stack Browser Annotation Data\r\n');
fprintf(f, 'Exported - %s\r\n', datestr(datevec(now)));
fprintf(f, 'Type%sX [inital]%sX [final]%sY [initial]%sY [final]%sZ [initial]%sZ [final]%sTag%sText%sAutoID%sUserID%sCorrelationID%sPersistence\r\n', ...
    delimiter, delimiter, delimiter, delimiter, delimiter, delimiter, delimiter, delimiter, delimiter, delimiter, delimiter, delimiter);

annotations = getLocal(progmanager, hObject, 'annotations');

for i = 1 : length(annotations)
    annotations(i).class = 1;
    switch (annotations(i).class)
        case 1
            c = 'stable';
        case 2
            c = 'loss';
        case 3
            c = 'gain';
        case 4
            c = 'transient';
    end
    
    fprintf(f, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\r\n', annotations(i).type, delimiter, num2str(annotations(i).x(1)), delimiter, ...
        num2str(annotations(i).x(2)), delimiter, num2str(annotations(i).y(1)), delimiter, num2str(annotations(i).y(2)), delimiter, ...
        num2str(annotations(i).z(1)), delimiter, num2str(annotations(i).z(2)), delimiter, annotations(i).tag, delimiter, ...
        annotations(i).text, delimiter, num2str(annotations(i).autoID), delimiter, annotations(i).userID, delimiter, num2str(annotations(i).correlationID), delimiter, c);
end
setLocal(progmanager, hObject, 'annotations', annotations);

fclose(f);

return;