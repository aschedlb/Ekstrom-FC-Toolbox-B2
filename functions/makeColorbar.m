function makeColorbar(degreeRange,cmap,cbarTitle,allTitles)

global resultsDir

figure
axis off
set(gca,'XTickLabel',[],'YTickLabel',[])

nCbar = numel(degreeRange);

colorbarLabels = cell(1,nCbar+1); %allocation

for iCbar = 1:nCbar+1

        if (iCbar == 1)
            colorbarLabels{iCbar} = ' ';
        elseif (iCbar == 2)
            colorbarLabels{iCbar} = num2str(min(degreeRange));
        elseif (iCbar == nCbar+1)
            colorbarLabels{iCbar} = num2str(max(degreeRange));
        else
            colorbarLabels{iCbar} = ' ';
        end

end

colormap(cmap)
caxis([min(degreeRange) max(degreeRange)+1]);
colorHandle = colorbar('YTick',min(degreeRange):max(degreeRange)+1,...
    'YTickLabel',colorbarLabels,'FontSize',20,'Location','west');
title(colorHandle,cbarTitle,'FontSize',20)

screen2eps([resultsDir,'Colorbar_',allTitles{1}])

end