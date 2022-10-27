%% VERSION 1

% initialize access to the inpoutx64 low-level I/O driver
config_io;

% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;
if( cogent.io.status ~= 0 )
    error('inp/outp installation failed');
end


% write a value to the default LPT1 printer output port (at 0x378)
out_address = hex2dec('B010');
io64(cogent.io.ioObj,out_address,1);

% read back the value written to the printer port above
datum=inp(address);

% Stop the acquisition
io64(cogent.io.ioObj,out_address,0);
WaitSecs(0.005)
io64(cogent.io.ioObj,out_address,2);
% Stop the acquisition


%% Faster version
%create an instance of the io64 object
config_io

% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;
if( cogent.io.status ~= 0 )
    error('inp/outp installation failed');
end

% let's try sending the value=1 to the parallel printer's output port (LPT1)
out_address = hex2dec('B010');          %LPT3 output port address
inp_address = 1 + hex2dec('B010');       %LPT3 input port address



data_out=10;                                 %sample data value
io64(cogent.io.ioObj,out_address,data_out);   %output command

data_in=io64(cogent.io.ioObj,add.inp_address_startSubj2)
data_in=io64(cogent.io.ioObj,add.inp_address);


%
% when finished with the io64 object it can be discarded via
% 'clear all', 'clear mex', 'clear io64' or 'clear functions' command.


%%
