function varargout = port_parallel(varargin)
%--------------------------------------
%Author: Diego Barragán Guerrero
%Web Site: www.matpic.com
%E-mial: diegokillemall@yahoo.com
%--------------------------------------
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @port_parallel_OpeningFcn, ...
                   'gui_OutputFcn',  @port_parallel_OutputFcn, ...
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


% --- Executes just before port_parallel is made visible.
function port_parallel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to port_parallel (see VARARGIN)
handles.ada=0;
[x,map]=imread('db25.gif','gif');
%Representamos imagen en figura, con su mapa de colores
image(x),colormap(map),axis off,hold on


% Choose default command line output for port_parallel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes port_parallel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = port_parallel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function dato_out_Callback(hObject, eventdata, handles)
% hObject    handle to dato_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dato_out as text
%        str2double(get(hObject,'String')) returns contents of dato_out as a double
handles.ada=get(hObject,'String');
handles.ada=str2double(handles.ada);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dato_out_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dato_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in enviar.
function enviar_Callback(hObject, eventdata, handles)

if handles.ada>255|| handles.ada<0 || isnan(handles.ada) 
    errordlg('Value out of range','ERROR');
    set(handles.dato_out,'String','0');
    handles.ada=0;
end
diego=digitalio('parallel','LPT1');
dato=addline(diego,0:7,'out');
putvalue(dato,handles.ada);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dato_in_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dato_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recibir.
function recibir_Callback(hObject, eventdata, handles)
% hObject    handle to recibir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
judas=digitalio('parallel','LPT1');
dato2=addline(judas,8:12,'in');
dato3=getvalue(dato2);
dato4=16*dato3(1)+8*dato3(2)+4*dato3(3)+2*dato3(4)+1*~dato3(5);
set(handles.dato_in,'String',dato4);
guidata(hObject, handles);


% --- Executes on button press in pin_pin.
function pin_pin_Callback(hObject, eventdata, handles)
% hObject    handle to pin_pin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pin_by_pin
%close(port_parallel)

