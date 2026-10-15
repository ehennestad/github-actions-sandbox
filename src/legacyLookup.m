function value = legacyLookup(values)
% legacyLookup - Demo function with two warning-level code issues

    defaultValue = 0; % Assigned but never used
    value = max(values);
    eval('disp(value)'); % eval instead of a direct call
end
