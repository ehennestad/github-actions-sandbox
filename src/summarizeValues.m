function total = summarizeValues(values)
% summarizeValues - Demo function with three info-level code issues

    total = [];
    for k = 1:numel(values)
        total = [total, values(k)]; % Grows on every iteration
    end
    if length(values) == 0 % isempty is the usual test
        total = 0 % No semicolon, so the result is printed
    end
end
