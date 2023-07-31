%%% =======================================================================
%%  Purpose
%     This function FILTERS the raw temperature data. Filtering method by
%     Mike Hutnak, ROQ
%
%%   Last edit
%      07/19/2023 - Kristin Dickerson, UCSC
%%% =======================================================================

function [Tcln, ...
          decimateddata,...
          Record] ...
            = Filter(figure_Main, ...
            ErrorFlag,...
            edit_MedianFilter,...
            edit_MeanFilter,...
            edit_DecimateFilter,...
            datauniquetimes, ...
            Traw, ...
            NoTherm)

     % This is Mike's filtering. We need this until we see what raw data 
     % the new probe is producing. Can remove this filtering or modify it
     % once we know more.
     % ----------------------------------------------------------------
            wlmedian = edit_MedianFilter.Value;
            wlmean = edit_MeanFilter.Value;
            wldec = edit_DecimateFilter.Value;

             if rem(wlmean,2)~=0
                uialert(figure_Main, 'Mean window length must be even number',...
                'Filter Error');
                ErrorFlag=1;
                return
             end

         %% Pull data from structure
         timeNumU   =  datauniquetimes.TIMENUMU ;
         pwrU       =  datauniquetimes.PWRU ;
         tiltU      =  datauniquetimes.TILTU ;
         gU         =  datauniquetimes.GU ;
         zU         =  datauniquetimes.ZU ;
         TrawU      =  datauniquetimes.TRAWU ;
       
        
        %% RAW DATA %%
        % ==========
            Tallf1    = Traw;
            b         = Tallf1<=0; % I changed this variable from a to b so that the variable a above remains the same (bc is used later)-KD
            Tallf1(b) = NaN;
            
       %% FILTER DATA %
       % ============
            % % Despike by taking running median
            for i = 1:NoTherm
                eval(['Tallf2(',int2str(i),',:)=movmedian(Tallf1(',int2str(i),',:),wlmedian);'])
            end
            % % Smooth by taking running mean
            for i = 1:NoTherm
                eval(['Tallf2(',int2str(i),',:)=rbmmed(Tallf2(',int2str(i),',:),wlmean);'])
            end

            % Assign median filtered values to matrix Tcln (CLEAN)
            Tcln = Tallf2;

            % Flip time
            timeNumU = timeNumU';
            
            
       %% DECIMATED DATA
       % ===============
            
            % DECIMATED RAW DATA
            % ------------------
            n=1:wldec:length(Traw(1,:));
            TdecRaw=Traw(:,n);
            

            % DECIMATED FILTERED
            % ------------------
            % Decimate and assign values to matrix Tdec (DECIMATED)
            n=1:wldec:length(Tcln(1,:));
            Tdec=Tcln(:,n);

            % DECIMATED TIME
            % ---------------
            timeDec=timeNumU(n);
        
      
       %% Create Record Counter
        Record       = 1:1:length(timeNumU);


        %% ASSIGN DECIMATED DATA

        n          = 1:wldec:length(TrawU);
        Time_dec   = timeDec;
        Record_dec = Record(n);
        G_dec      = gU(n);
        Tilt_dec   = tiltU(n);
        Power_dec  = pwrU(n);
        Depth_dec  = zU(n);

        %% Save decimated data in structure for access
        decimateddata = struct('TDecRaw', TdecRaw, 'TDecFiltered',Tdec, ...
            'TimeDec', Time_dec, 'RecordDec', Record_dec, 'GDec', G_dec, ...
            'TiltDec', Tilt_dec, 'PowerDec', Power_dec, 'DepthDec', Depth_dec);

