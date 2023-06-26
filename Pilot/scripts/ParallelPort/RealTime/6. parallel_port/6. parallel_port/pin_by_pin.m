function varargout = pin_by_pin(varargin)

%--------------------------------------
%Author: Diego Barragán Guerrero
%For more information, visit: www.matpic.com
%E-mial: diegokillemall@yahoo.com
%--------------------------------------

% Last Modified by GUIDE v2.5 23-Feb-2008 17:55:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pin_by_pin_OpeningFcn, ...
                   'gui_OutputFcn',  @pin_by_pin_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pin_by_pin is made visible.
function pin_by_pin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pin_by_pin (see VARARGIN)
%*-*-*-*-*-*-*-*-*-*-*-*-
pp=digitalio('parallel','LPT1');
handles.dato=addline(pp,0:7,'out');
putvalue(handles.dato,0);
%-*-*-*-*-*-*-*-*-*-*-**-
% Choose default command line output for pin_by_pin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pin_by_pin wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pin_by_pin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pin_2.
function pin_2_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)

putvalue(handles.dato,out);


% --- Executes on button press in pin_6.
function pin_6_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)
putvalue(handles.dato,out);

% --- Executes on button press in pin_4.
function pin_4_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)
putvalue(handles.dato,out);
% --- Executes on button press in pin_8.
function pin_8_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)
putvalue(handles.dato,out);
% --- Executes on button press in pin_3.
function pin_3_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)
putvalue(handles.dato,out);

% --- Executes on button press in pin_7.
function pin_7_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)
putvalue(handles.dato,out);
% --- Executes on button press in pin_5.
function pin_5_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)
putvalue(handles.dato,out);
% --- Executes on button press in pin_9.
function pin_9_Callback(hObject, eventdata, handles)
a=get(handles.pin_2,'Value');
b=get(handles.pin_3,'Value');
c=get(handles.pin_4,'Value');
d=get(handles.pin_5,'Value');
e=get(handles.pin_6,'Value');
f=get(handles.pin_7,'Value');
g=get(handles.pin_8,'Value');
h=get(handles.pin_9,'Value');

m=[a b c d e f g h];
out=binvec2dec(m);
set(handles.text1,'String',out)
putvalue(handles.dato,out);

