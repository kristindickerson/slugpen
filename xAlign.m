
%%% ==============================================================================
%%  Purpose: 
%     This function aligns the inner position left edge and width (x axis)
%     of all 4 plots of SlugPen
%%% ==============================================================================

function xAlign(axis_raw,...
                axis_depth, ...
                axis_accel, ...
                axis_tilt)


           %axis_raw.YLabel.Units = 'normalized';
           %axis_depth.YLabel.Units = 'normalized';
           %axis_accel.YLabel.Units = 'normalized';
           %axis_tilt.YLabel.Units = 'normalized';
            pause(1);
            axis_accel.InnerPosition(1) = axis_depth.InnerPosition(1);
            axis_accel.InnerPosition(3) = axis_depth.InnerPosition(3);
            axis_raw.InnerPosition(1) = axis_depth.InnerPosition(1);
            axis_raw.InnerPosition(3) = axis_depth.InnerPosition(3);
            axis_tilt.InnerPosition(1) = axis_depth.InnerPosition(1);
            axis_tilt.InnerPosition(3) = axis_depth.InnerPosition(3);
            pause(1);
            %axis_raw.PositionConstraint='innerposition';
            %axis_depth.PositionConstraint='innerposition';
            %axis_accel.PositionConstraint='innerposition';
            %axis_tilt.PositionConstraint='innerposition';
            pause(1);
            drawnow;
            pause(0.5)