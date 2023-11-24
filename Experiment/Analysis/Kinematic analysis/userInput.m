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

prompt = {'Which hard drive? (1=IIT/0=UKE)',...
            'One figure per agent with all trajectories? (1/0) YES',...
            'One figure per trial (for cutting and visual inspection)? (1/0)',...
            'Median split for confidence? (1/0)', ...
            'Normalize trajectories to 100 bins? (1/0)',...
            'Write Excel files and save mat files? (1/0)',...
            'Which decision to plot? (1/2/3/4)',...
            'Do you want to start from backup? (1/0)'};

name = 'Configuration details';
numlines=1;
defaultanswer={'1','1','0','1','1','0','2','0'};
subdetails =inputdlg(prompt,name,numlines,defaultanswer);

% Decide if you want to analyze the full data set 
% or start from backup (in case of previous crash)
if ~isempty(subdetails{8}) && str2num(subdetails{8}) == 1
    [filename, pathname, filterindex] = uigetfile(pwd,'.mat');
    load(fullfile(pathname,filename),'-regexp','^(?!subdetails$|filename$|pathname$|data_bkp)\w');
    data_bkp        = data; % 'data' is now 'data_bkp' to avoid overwriting
    file_split      = split(filename,'_');
    trial_crash_str = cell2mat(file_split(end-1));
    trialstart_num  = sscanf(trial_crash_str,'end%d'); % start at later trial
    crash = '1';
elseif ~isempty(subdetails{8}) && str2num(subdetails{8}) == 0
    trialstart_num = 1;
    crash = '0';
end

% set flags according to user input
if ~isempty(subdetails{1})
    flag_hd = str2num(subdetails{1});
end
if ~isempty(subdetails{2})
    flag_plot = str2num(subdetails{2});
end
if ~isempty(subdetails{3})
    trial_plot = str2num(subdetails{3});
end
if ~isempty(subdetails{4})
    med_split  = str2num(subdetails{4});
end
if ~isempty(subdetails{5})
    flag_bin  = str2num(subdetails{5});
end
if ~isempty(subdetails{6})
    flag_write  = str2num(subdetails{6});
end
if ~isempty(subdetails{7})
    which_Dec  = str2num(subdetails{7});
end
