function [randCorrs] = randomizeSeries(series)

% A function that shuffles the beta series using a function called shake.m

seriesRow = size(series,1);
seriesCol = size(series,2);

randIdx = 1:(seriesRow*seriesCol);
randIdx = reshape(randIdx,seriesRow,seriesCol);
[randIdx,~,~] = shake(randIdx,1);

randSeries = series(randIdx);

[randCorrs,~] = corr(randSeries);

randCorrs = triu(randCorrs,1);
randCorrs = randCorrs(randCorrs ~= 0)';

end
