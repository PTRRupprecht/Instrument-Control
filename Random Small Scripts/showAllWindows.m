function showAllWindows()

A = findall(0,'Type','figure');
for j = 1:length(A)
    if strcmp(get(A(j),'Visible'),'on')
        figure(A(j));
    end
end

end