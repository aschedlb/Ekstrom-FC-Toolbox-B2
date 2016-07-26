function analysisType = chooseROIanalysis

analysisType = [];

% GUI to choose 1 of 3 analyses
hFig = figure('units','pixels','position',[800 800 320 150],'toolbar','none','menu','none');

% Question for user
uicontrol('style','text','units','pixels','position',[0 120 300 15],'string','How would you like to define your ROI?');

% Checkboxes for analyses
check.c(1) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[10 80 300 15],'string','Average of entire AAL ROI (average)');
check.c(2) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[10 60 300 15],'string','Cube center at center of mass of AAL ROI (CoM)');
check.c(3) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[10 40 300 15],'string','Cube center at own coordinates (user)');

% OK button
uicontrol('style','pushbutton','units','pixels','position',[10 20 300 15],'string','OK','Callback',@buttonCall);

uiwait

    function buttonCall(varargin)
        
        checkedBoxes = get(check.c,'Value');
        
        if sum([checkedBoxes{:}]) == 0
            
            close(hFig)
            error('You did not select an analysis!')
            
        elseif sum([checkedBoxes{:}]) == 1
            
            if find([checkedBoxes{:}]) == 1
                analysisType = 'average';
            elseif find([checkedBoxes{:}]) == 2
                analysisType = 'CoM';
            elseif find([checkedBoxes{:}]) == 3
                analysisType = 'user';
            end
            
        elseif sum([checkedBoxes{:}]) > 1
            
            close(hFig)
            error('You checked more than one analysis!')
            
        end
        
        close(hFig)
        
    end
    
end
       