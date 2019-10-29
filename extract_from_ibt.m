function [D, dt] = extract_from_ibt(fullname, plot_flag)
% Data as a structure + corresponding time array.
%close all; clear all; fullname='102319_JSH4.ibt'; 
 
fid=fopen(fullname,'r');
check=fread(fid,1,'int16');  %magic number 11
if check~=11 error(['Magic is not made by' int2str(check)]); end

sweep_loc(1)=fread(fid,1,'int32');
fread(fid,1,'float');  %absolute time starter
units1=fread(fid,20,'char');char(units1');
units2=fread(fid,20,'char');char(units2');
units3=fread(fid,20,'char');char(units3');

i=1;
while ~feof(fid)
    % this is going correctly:
    fseek(fid,sweep_loc(i),'bof');              % 204 bytes total for header?    
    am_i_12=fread(fid,1,'int16');               % 2 bytes: int sweep magic numbers (should be 12)
    if am_i_12~=12 error(['Magic is not made by ' int2str(am_i_12)]); end
    sweep_num=fread(fid,1,'int16');             % 2 bytes: int sweep number.  Appears to start with 0.
    n_pts=fread(fid,1,'float');                 %4 bytes: float {{NOT(int)}} number of data points in sweep
    scale=fread(fid,1,'int32');                 %4 bytes: int scale factor  %float not int.
    gain=fread(fid,1,'float');                  %4 bytes: float amplifier gain
    rate=fread(fid,1,'float');                  %4 bytes: float sampling rate, in kHz
    fread(fid,1,'float');                       %4 bytes: float recording mode – 0 = OFF;  1 = current clamp;  2 = voltage clamp    
    
    % not OK!  Or, I am unsure of what these are.
    dt=fread(fid,1,'float');            %4 bytes: float, time interval between data points -- seems to not be getting set, is always zero
    sweep_time(i)=fread(fid,1,'float');     %4 bytes: float sweep time, elapsed
    
    % This is all from the "command pulse" box.
    fread(fid,1,'int32')  ;      %4 bytes: int command pulse 1 flag
    fread(fid,1,'double')  ;     %8 bytes: float command pulse 1 value
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 1 start      
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 1 duration
    fread(fid,1,'int32')   ;     %  4 bytes: int command pulse 2 flag
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 2 value
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 2 start
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 2 duration
    fread(fid,1,'int32')    ;    %  4 bytes: int command pulse 3 flag
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 3 value
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 3 start
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 3 duration
    fread(fid,1,'int32')   ;     %  4 bytes: int command pulse 4 flag
    fread(fid,1,'double')  ;     %8 bytes: float command pulse 4 value
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 4 start
    fread(fid,1,'double')  ;     %8 bytes: float command pulse 4 duration
    fread(fid,1,'int32')   ;     %  4 bytes: int command pulse 5 flag
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 5 value
    fread(fid,1,'double')  ;     %8 bytes: float command pulse 5 start
    fread(fid,1,'double')   ;    %8 bytes: float command pulse 5 duration
    fread(fid,1,'double')   ;    %8 bytes: float DC command pulse flag
    fread(fid,1,'double')    ;   %8 bytes: float DC command pulse value
    fread(fid,1,'single')   ;     %  4 bytes: float temperature
    fread(fid,1,'double')   ;    %8 bytes: empty
    fread(fid,1,'int32')    ;    %  4 bytes: int pointer to sweep data
    
    sweep_loc(i+1)=fread(fid,1,'int32');        %  4 bytes: pointer to next sweep
    fread(fid,1,'int32');        %  4 bytes: pointer to previous sweep   --- redundant / can use for error check
    
    ami_13=fread(fid,1,'int16');  %2 bytes: int sweep data magic number, should be 13
    if ami_13~=13 error(['Magic is not made by ' int2str(ami_13)]); end
 
    % Heeeeeeere's Johnny:
    D(i).data=fread(fid,n_pts,'int16')/scale/gain/.001;   %int sweep data, 2 bytes per data point
    if ~sweep_loc(i+1)
        break  % end of traces is marked by sweep_loc of 0
    end
    i=i+1;
end

dt=.001/rate;      %assuming this is the same for all data.

 if plot_flag
     figure(10);clf;hold on;
     for i=1:size(D,2)
         plot((1:length(D(i).data))/rate, D(i).data)
         xlabel('ms');ylabel('mV');
     end
     title([int2str(i) ' sweeps'])
 end
 
fclose(fid);
end

