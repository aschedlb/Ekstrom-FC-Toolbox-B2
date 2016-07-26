function [configuration,comparison] = chooseGraph

configuration = [];
comparison = [];

% Create drop-down menu
hFig = figure('units','pixels','position',[800 800 320 150],'toolbar','none','menu','none');

uicontrol('style','text','units','pixels','position',[0 120 300 15],'string','How would you like to plot your ROI?');
popup.d(1) = uicontrol('parent',hFig,'style','popup','units','pixels','position',[10 80 300 15],'string',{'Circle','3D Brain Space','Gephi','BrainNet Viewer'});
popup.d(2) = uicontrol('parent',hFig,'style','popup','units','pixels','position',[10 50 300 15],'string',{'Individual','Difference'});

% OK button
uicontrol('style','pushbutton','units','pixels','position',[10 20 300 15],'string','OK','Callback',@buttonCall);
uiwait

    function buttonCall(varargin)
        
        dropDown = get(popup.d,'Value');
        
        if dropDown{1} == 1
            configuration = 'circle';
        elseif dropDown{1} == 2
            configuration = '3D';
        elseif dropDown{1} == 3
            configuration = 'Gephi';
        elseif dropDown{1} == 4
            configuration = 'BrainNet Viewer';
        end
        
        if dropDown{2} == 1
            comparison = 'individual';
        else
            comparison = 'difference';
        end
        
        close(hFig)
        
    end

end