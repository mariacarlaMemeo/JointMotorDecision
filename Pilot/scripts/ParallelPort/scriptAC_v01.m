%% VERSION 1

% initialize access to the inpoutx64 low-level I/O driver
config_io;

% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end


% write a value to the default LPT1 printer output port (at 0x378)
address = hex2dec('378');
byte = 1;
outp(address,byte);

% read back the value written to the printer port above
datum=inp(address);


%% Faster version
%create an instance of the io64 object
config_io

% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;
if( cogent.io.status ~= 0 )
    error('inp/outp installation failed');
end

% let's try sending the value=1 to the parallel printer's output port (LPT1)
address = hex2dec('B010');          %standard LPT1 output port address
data_out=1;                                 %sample data value
io64(cogent.io.ioObj,address,data_out);   %output command


for i = 1:10
% now, let's read that value back into MATLAB
data_in(i)=io64(cogent.io.ioObj,address);
pause(1)
i = i+1;
end
%
% when finished with the io64 object it can be discarded via
% 'clear all', 'clear mex', 'clear io64' or 'clear functions' command.