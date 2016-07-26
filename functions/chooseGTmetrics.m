
function [localMetrics,globalMetrics,modifyMetrics] = chooseGTmetrics

localMetrics = {'ND';'BC';'PC'};
globalMetrics = {'DEN';'MOD'};
modifyMetrics = [];

% GUI
hFig = figure('units','pixels','position',[800 500 300 300],'toolbar','none','menu','none');

% Question for user
uicontrol('style','text','units','pixels','position',[0 260 300 15],'string','Which Graph Theory metrics are you interested in?');

% Checkboxes for analyses
uicontrol('style','text','units','pixels','position',[0 230 300 15],'string','Local');
check.c1(1) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[15 210 300 15],'string','Node Degree');
check.c1(2) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[15 190 300 15],'string','Betweenness Centrality');
check.c1(3) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[15 170 300 15],'string','Participation Coefficient');
uicontrol('style','text','units','pixels','position',[0 140 300 15],'string','Global');
check.c2(1) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[15 120 300 15],'string','Density');
check.c2(2) = uicontrol('parent',hFig,'style','checkbox','units','pixels','position',[15 100 300 15],'string','Modularity');


% Dropdown box for normalization or zscore
uicontrol('style','text','units','pixels','position',[15 70 300 15],'string','How would you like modify the metrics?');
popup.d(1) = uicontrol('parent',hFig,'style','popup','units','pixels','position',[15 50 270 15],'string',{'None','Normalize','Zscore'});

% OK button
uicontrol('style','pushbutton','units','pixels','position',[15 20 270 15],'string','OK','Callback',@buttonCall);

uiwait

    function buttonCall(varargin)
        
        checkedBoxes1 = get(check.c1,'Value');
        checkedBoxes2 = get(check.c2,'Value');
        
        if (sum([checkedBoxes1{:}]) == 0) && (sum([checkedBoxes2{:}]) == 0)
            close(hFig)
            error('You did not select a metric!')
        end
        
        if sum([checkedBoxes1{:}]) == 0
            localMetrics = [];
        else
            localMetrics(find(~[checkedBoxes1{:}])) = [];
        end
            
        if sum([checkedBoxes2{:}]) == 0
            globalMetrics = [];
        else
            globalMetrics(find(~[checkedBoxes2{:}])) = [];
        end
        
        dropDown = get(popup.d,'Value');
         
        if dropDown == 1
            modifyMetrics = 'none';
        elseif dropDown == 2
            modifyMetrics = 'normalize';
        elseif dropDown == 3
            modifyMetrics = 'zscore';
        end
        
        close(hFig)
        
    end

end
