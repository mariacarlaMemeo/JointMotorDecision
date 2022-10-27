function out = daqmem(varargin)
%  This function is no longer supported on any platform as of R2016a.
%  Use the <a href="matlab:web(fullfile(docroot, 'daq/transition-your-code-to-session-based-interface.html'))">session-based interface</a>.

try
daq.internal.errorIfLegacyInterfaceUnavailable('daqmem')
catch e
    throwAsCaller(e);
end