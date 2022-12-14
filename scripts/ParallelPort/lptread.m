function value=lptread(port)
% LPTREAD read from port
%
% Description:
% IOCTL call to porttalk.sys kernel mode driver (required) by Craig Peacock
%
% Installation:
% See http://groups.yahoo.com/group/psychtoolbox/message/4825
% http://www.logix4u.net/parallelport1.htm is a good parallel port reference
%
% Usage:
% value = lptread(port)
%
% Arguments:
% port - double Port address (e.g., 889 = 0x1 + 0x378 for status register of LPT1
% on many machines, which corresponds to pins 10, 11, 12, 13, and 15 of a DB25
% parallel port -- note pin 11 is hardware inverted!)
%
% Examples:
% val = lptread(1+hex2dec(0x378));
%
% Author: Erik Flister, UCSD, 2006. Adapted from Andreas Widmann.