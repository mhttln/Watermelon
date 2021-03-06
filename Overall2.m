function varargout = Overall2(varargin)
% OVERALL2 MATLAB code for Overall2.fig
%      OVERALL2, by itself, creates a new OVERALL2 or raises the existing
%      singleton*.
%
%      H = OVERALL2 returns the handle to a new OVERALL2 or the handle to
%      the existing singleton*.
%
%      OVERALL2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OVERALL2.M with the given input arguments.
%
%      OVERALL2('Property','Value',...) creates a new OVERALL2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Overall2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Overall2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Overall2

% Last Modified by GUIDE v2.5 02-Feb-2012 16:10:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Overall2_OpeningFcn, ...
                   'gui_OutputFcn',  @Overall2_OutputFcn, ...
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


% --- Executes just before Overall2 is made visible.
function Overall2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Overall2 (see VARARGIN)

% Choose default command line output for Overall2
handles.output = hObject;

rstStAnalyse.dist = [];
rstStAnalyse.x = [];
rstStAnalyse.n = [];
set(handles.hist, 'UserData', rstStAnalyse);

confidence = [];
set(handles.conf, 'UserData', confidence);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Overall2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Overall2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

 
% --- Executes on button press in acvi.
function acvi_Callback(hObject, eventdata, handles)
% hObject    handle to acvi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = ...
     uigetfile({'*.avi;*.wmv;*.mpeg;*.mpg', 'Video Files(*.avi,*.wmv,*.mpeg,*.mpg)';...
                '*.*', 'All Files(*.*)'},...
               'Open a video file');

if filename
    vid = mmreader([pathname filename]); 
    for i=1:4
        fBuf= read(vid, i);
    end
    fImag = fBuf;
    posImag = get(handles.imag, 'Position');
    axisHeight = posImag(4); axisWidth = posImag(3);
    
    fImag = rgb2gray(fImag);
    newImag = imresize(fImag, [axisHeight axisWidth]);
    axes(handles.imag);
    imshow(newImag);    
    
    % Save filename and pathname
    set(handles.acvi, 'UserData', [pathname filename]);
    set(handles.imag, 'UserData', fImag);
    
    % Reset histogram data
    rstStAnalyse.dist = [];
    rstStAnalyse.x = [];
    rstStAnalyse.n = [];
    set(handles.hist, 'UserData', rstStAnalyse); 
    
    % Reset confidence data
    confidence = [];
    set(handles.conf, 'UserData', confidence);
    
    % Clear axes
    cla(handles.hist);
    cla(handles.conf);
end;

guidata(hObject, handles);



% --- Executes on button press in stan.
function stan_Callback(hObject, eventdata, handles)
% hObject    handle to stan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

posImg = get(handles.posi, 'Value');
if numel(posImg)<2
    errordlg('Please pick up a location to observe');
    return;
end

% Read parameter setting
videofile = get(handles.acvi,'UserData');
duration = uint8(get(handles.dura,'Value'));
filtersize = uint8(get(handles.fisi,'Value'));

% Retrieve saved data and run
conf = get(handles.conf, 'UserData');
rstPrev = get(handles.hist, 'UserData');
[ distance xbin nbin confidence] = st_covmat_analyse(videofile, duration,...
                filtersize, handles, conf, rstPrev.dist, rstPrev.x, rstPrev.n);
disp('Analysis stopped.');

% Save updated data
rstStAnalyse.dist = distance;
rstStAnalyse.x = xbin;
rstStAnalyse.n = nbin;
set(handles.hist, 'UserData', rstStAnalyse);
set(handles.conf, 'UserData', confidence);

%save('distance_bagleftbehind', 'distance');
guidata(hObject, handles);

% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushed_down = get(hObject, 'Value');
if pushed_down
    disp('Stopping analysis...');
else
    % Read parameter setting
    videofile = get(handles.acvi,'UserData');
    duration = get(handles.dura,'Value');
    filtersize = get(handles.fisi,'Value');

    % Retrieve saved data and run
    conf = get(handles.conf, 'UserData');
    rstPrev = get(handles.hist, 'UserData');
    [ distance xbin nbin confidence] = st_covmat_analyse(videofile, duration,...
                    filtersize, handles, conf, rstPrev.dist, rstPrev.x, rstPrev.n);
    % Save updated data
    rstStAnalyse.dist = distance;
    rstStAnalyse.x = xbin;
    rstStAnalyse.n = nbin;
    set(handles.hist, 'UserData', rstStAnalyse);
    set(handles.conf, 'UserData', confidence);
end
guidata(hObject, handles);

% --- Executes on button press in vali.
function vali_Callback(hObject, eventdata, handles)
% hObject    handle to vali (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Read parameter setting
videofile = get(handles.acvi,'UserData');
filtersize = get(handles.fisi,'Value');
HistTrained = get(handles.trhi,'Value');
[ distance xbin nbin confidence] = st_multiple_validate(videofile, ...
        filtersize, handles, HistTrained);
disp('Validation stopped.');
guidata(hObject, handles);


function fisi_Callback(hObject, eventdata, handles)
% hObject    handle to fisi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fisi as text
%        str2double(get(hObject,'String')) returns contents of fisi as a double


% --- Executes during object creation, after setting all properties.
function fisi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fisi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dura_Callback(hObject, eventdata, handles)
% hObject    handle to dura (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dura as text
%        str2double(get(hObject,'String')) returns contents of dura as a double


% --- Executes during object creation, after setting all properties.
function dura_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dura (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function posi_Callback(hObject, eventdata, handles)
% hObject    handle to posi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of posi as text
%        str2double(get(hObject,'String')) returns contents of posi as a double


% --- Executes during object creation, after setting all properties.
function posi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to posi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in piup.
function piup_Callback(hObject, eventdata, handles)
% hObject    handle to piup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fImage = get(handles.imag, 'UserData');
height = size(fImage,1); width = size(fImage,2);
hFigure = figure('Name', 'Pick up a point to observe'); 
set(hFigure,'Position',[200,200,width,height]);
imshow(fImage,'Border', 'tight');
set(hFigure, 'WindowButtonDownFcn',{@my_pickup_Callback, handles, width, height});
guidata(hObject, handles);


% --- Executes on button press in trai.
function trai_Callback(hObject, eventdata, handles)
% hObject    handle to trai (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trai


% --- Executes on button press in dete.
function dete_Callback(hObject, eventdata, handles)
% hObject    handle to dete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dete
bDete = get(hObject,'Value');
if bDete
    set(handles.norm, 'Enable', 'off');
else
    set(handles.norm, 'Enable', 'on');
end
guidata(hObject, handles);

% --- Executes on button press in norm.
function norm_Callback(hObject, eventdata, handles)
% hObject    handle to norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of norm


% --- Executes on button press in anal.
function anal_Callback(hObject, eventdata, handles)
% hObject    handle to anal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Read parameter setting
videofile = get(handles.acvi,'UserData');
filtersize = get(handles.fisi,'Value');
HistTrained = get(handles.trhi,'Value');
[ distance xbin nbin confidence] = st_multiple_analyse(videofile, ...
        filtersize, handles, HistTrained);
disp('Analysis stopped.');
guidata(hObject, handles);

% Save updated data


% --- Executes on button press in trhi.
function trhi_Callback(hObject, eventdata, handles)
% hObject    handle to trhi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TrainSeletected = get(handles.trhi, 'Value');

if TrainSeletected==1
    set(handles.trhi, 'Value', 1);
    set(handles.trai, 'Value', 0);
end
guidata(hObject, handles);


% --- Executes on button press in sthi.
function sthi_Callback(hObject, eventdata, handles)
% hObject    handle to sthi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sthi


% --- Executes on button press in btn_validate.
function btn_validate_Callback(hObject, eventdata, handles)
% hObject    handle to btn_validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Validation;
