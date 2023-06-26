function varargout = daqhelp(varargin)
%DAQHELP Display Data Acquisition Toolbox help.
%
%    DAQHELP provides an overview of Data Acquisition Toolbox
%    functions with a brief description of each function.
%
%    DAQHELP('NAME') provides on-line help for the function, NAME.
%
%    OUT = DAQHELP('NAME') returns the help text in string, OUT.
%
%    Example:
%       daqhelp
%       daqhelp('getDevices')
%       out = daqhelp('inputSingleScan');
%
%    Copyright 1998-2016 The MathWorks, Inc.
%    $Revision: 1.13.2.12 $  $Date: 2008/06/16 16:34:23 $

% There can be a maximum of 1 input argument
if nargin > 1
    error(message('MATLAB:narginchk:tooManyInputs'));
end

if nargout > 1
    error(message('MATLAB:nargoutchk:tooManyOutputs'));    
end

daqroot = [toolboxdir('daq') filesep 'daq'];

switch nargin
    case 0
        % No input parameters, display help overview from Contents.m
        helpPath = daqroot;
        
    case 1
        % The input argument has to be a string or character vector
        userInput = varargin{1};
        if ~daq.internal.isScalarStringOrCharVector(userInput)
            error('daq:daqhelp:argcheck', 'The input argument must be a string.');
        end
        
        userInput = char(userInput);
        
        switch lower(userInput)
            % Set the prefixes according to the user input
            case {'session','daqhelp', 'daqreset','reset',...
                    'getdevices','getvendors','createsession'}
                helpPath = ['daq.' userInput];
            case {'daq.getdevices', 'daq.getvendors', 'daq.createsession'...
                    'daq.reset', 'supportpackageinstaller'}
                helpPath = userInput;
            otherwise
                % If the user input is a function is within the Session class
                sessionMethods = methods('daq.Session');
                sessionMethodsIndex = strcmpi(userInput,sessionMethods);
                if any(sessionMethodsIndex)
                    helpPath = ['daq.Session.' sessionMethods{sessionMethodsIndex}];
                else
                    % Parameter is not recognized. Show help overview
                    fprintf('%s\n\n',getString(message('daq:general:daqhelpUnrecognizedParameter',userInput)))
                    helpPath = daqroot;
                end
        end
end

% Set the output parameters if requested
if nargout==1
    varargout{1} = help(helpPath);
else
    help(helpPath);
end

end