function [datestr] = savedate

foo = clock;

year = num2str(foo(1) - 2000);
month = num2str(foo(2));
day = num2str(foo(3));

datestr = [month,'_',day,'_',year];

end