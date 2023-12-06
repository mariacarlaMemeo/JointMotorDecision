% -------------------------------------------------------------------------
% Get input from the user or use default values
% -------------------------------------------------------------------------

% Add option to start from later trial (but without starting from backup)
% but make sure NOT to write/save anything -> this would be useful if you
% just want to inspect/check a certain trial

% These are the options for the user:
% flag_hd: retrieve data from which hard drive? [1/0] -> 1=IIT; 0=UKE 
% flag_plot: 1 plot per agent with all trajectories ("exploratory plots")? [1/0]
% trial_plot: 1 plot per trial (for cutting and visual inspection)? [1/0]
% med_split: median split for confidence? [1/0]
% flag_bin : normalize trajectories to 100 bins? [1/0]
% flag_write: write Excel files and save mat files? [1/0]
% which_Dec: select which decision to plot: 1=1st, 2=2nd, 3=coll., 4=1st&2nd
% Do you want to start from backup? [1/0]

prompt = {'Which hard drive? (1=IIT / 0=UKE)',...
          'One figure per agent with all trajectories? (1/0)',...
          'One figure per trial (for cutting and visual inspection)? (1/0)',...
          'Median split for confidence? (1/0)', ...
          'Normalize trajectories to 100 bins? (1/0)',...
          'Save Excel files and mat files? (1/0)',...
          'Which decision to plot? (1/2/3)',...
          'Start from backup? (1/0)',...
          'Which trial number to start with? (1-160) ONLY TO CHECK'};

name = 'Configuration details';
numlines = 1;
defaultanswer = {'1','1','0','1','1','0','2','0','1'};
subdetails = inputdlg(prompt,name,numlines,defaultanswer);

% (8) Decide if you want to analyze the full data set [crash=0]
% or start from backup, in case of previous crash or exit [crash=1]
if ~isempty(subdetails{8}) && str2double(subdetails{8}) == 1
    [filename, pathname, filterindex] = uigetfile(pwd,'.mat');
    load(fullfile(pathname,filename),'-regexp','^(?!subdetails$|filename$|pathname$|data_bkp)\w');
    data_bkp        = data; % 'data' is now 'data_bkp' to avoid overwriting
    file_split      = split(filename,'_');
    trial_crash_str = cell2mat(file_split(end-1));
    trialstart_num  = sscanf(trial_crash_str,'end%d'); % start at later trial
    crash = '1';
elseif ~isempty(subdetails{8}) && str2double(subdetails{8}) == 0
    trialstart_num = 1;
    crash = '0';
end

% set flags according to user input
if ~isempty(subdetails{1}) % (1) which hard drive?
    flag_hd         = str2double(subdetails{1});
end
if ~isempty(subdetails{2}) % (2) create average plots?
    flag_plot       = str2double(subdetails{2});
end
if ~isempty(subdetails{3}) % (3) plot trial by trial?
    trial_plot      = str2double(subdetails{3});
end
if ~isempty(subdetails{4}) % (4) do median split?
    med_split       = str2double(subdetails{4});
end
if ~isempty(subdetails{5}) % (5) do binning?
    flag_bin        = str2double(subdetails{5});
end
if ~isempty(subdetails{6}) % (6) save Excel and mat files?
    flag_write      = str2double(subdetails{6});
end
if ~isempty(subdetails{7}) % (7) which decision to plot?
    which_Dec      = str2double(subdetails{7});
end
% (9) start at later trial (~=1) for debugging/checking purposes?
% If you want to start from later trial, change trial_num here
% BUT: only if you do not start from backup file - in this case,
% trial_num is defined based on the backup file (see above, (8))
debug = 0;
if ~isempty(subdetails{9}) && str2double(subdetails{9})~=1 && str2double(subdetails{8})==0
    trialstart_num = str2double(subdetails{9});
    debug = 1; % start from later trial only to debug/check
end

% % If you set trial_num to a later trial just to check something (and not
% % because you are starting from a backup), then in this case do not save
% % the final Excel and mat files, and do not plot the averages
% if trialstart_num ~= 1 && str2double(crash)==0
%     flag_write = 0; flag_plot = 0;
% end