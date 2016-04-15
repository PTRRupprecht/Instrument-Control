 function scanimageB()
%SCANIMAGE4 Starts ScanImage application and its GUI(s)

import scanimage.*

hSI = SI4();
hSICtl = SI4Controller(hSI); %#ok<NASGU>

assignin('base','hSI',hSI);
assignin('base','hSICtl',hSI.hController{1});

hSI.initialize();

end

