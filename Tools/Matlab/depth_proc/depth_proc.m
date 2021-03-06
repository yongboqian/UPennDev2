% function res = depth_proc(data, meta, ui)
% 
% INPUT 
%  - data 
%  - meta 
%  - ui (user input) See uisetting.m
%    
% OUTPUT 
%  - res (result)
%
% by Bhoram Lee 
function [res, meta] = depth_proc(data, meta, ui)

if isempty(data)
    return
end

switch ui.runningMode 
    case 1, % logging 
        logDepthData(data, meta);
    case 2, 
     %   [res, meta] = detectPlanes6(data, meta, ui); % large plane settings
        [res, meta] = detectPlanes7(data, meta, ui); % rough terrain settings
end
    
end