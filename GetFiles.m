%%% ==============================================================================
%%  Purpose: 
%     This function collects the input file for SlugPen
%  
%%   Last edit:
%      07/19/2023 - Kristin Dickerson, UCSC
%%% ==============================================================================

function    [f, NoTherm, ...
             NumSensUsed,...
             filename] ...
             = GetFiles(figure_Main, ...
              H, ...
              edit_NumberofTherm)


    %% Open GUI to select filename
        [filename, pathname] = uigetfile({'*.raw';'*.mat'},'Pick a raw data probe output file');
        figure(figure_Main)

    %% Validate the file/path
        if isequal(filename,0)||isequal(pathname,0)
            uialert(figure_Main, 'File not found or not valid',...
                'Error finding file');
            H.Error=1;
            return
        end

            f=fullfile(pathname,filename);
        
            % See if it's a mat file or a raw file
            [~,fn,ext]=fileparts(filename);
                % Get the first line and confirm default header start
                fid = fopen(f,'r');
                if fid<0
                    uialert(figure_Main, 'Unable to open selected file','Error');
                    H.Error=1;
                    return
                else
                    line = fgetl(fid);
                    if isempty(line)||~strcmp(line(1),'$')
                        fclose(fid);
                        disp('Invalid File Format');
                        H.Error=1;
                        return
                    else
                        % Read in Header Here (TO DO) --> don't understand this. It just makes line equal to the 12th line. Why the loop? - KD
                        for n=1:12
                            line = fgetl(fid);
                        end
                
                        % Determining NUMBER OF THERMISTORS - KD
                            % Option 1 (allow user to manually input number of thermistors
                                %H.Fileinfo.No_Thermistors.Value = NoTherm; % Set the No_Thermistors in H.Fileinfo Structure
                            % Option 2 (Mike's):
                                % Read second line and determine number of thermistors 
                                % There are 11 columns of timing, acceleration, etc.
                                % Add 1 for bottom water sensor
                                line         = strtrim(fgetl(fid)); %--> don't understand this. Now it just makes line equal to the 13th line. What was the point of the loop above?
                                ncols        = length(find(isspace(line)));
                                nThermistors = ncols-11+1;
                                H.Fileinfo.No_Thermistors.Value = nThermistors;  % Set the No_Thermistors in H.Fileinfo Structure
                                NoTherm = nThermistors;
                                NumSensUsed = NoTherm;
                                edit_NumberofTherm.Value = num2str(nThermistors);

                        % Fill properties that create vectors of zeros or NaNs the size of the number of thermistors (called foo in Mike's code)
                        All_Zeros = zeros(1,H.Fileinfo.No_Thermistors.Value);
                        All_NaN = All_Zeros/0;
                    end
                end
                fclose(fid);


