function myRestoreButtonCallbackFcn(hobj, event, originalCallback,H)
% Responds to pressing the restore button in the axes' toolbar. 
% originalCallback is a function handle to the original callback 
%   function for this button. 
    originalCallback(hobj,event) % Evaluate original callback
    
    H.Axes.Raw.XLim = H.Axis_Limits.AxLims_Raw;