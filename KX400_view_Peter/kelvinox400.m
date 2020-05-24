function kelvinox400

% GUI to view the pressure/temperature/heater readings collated by the
% Kelvinox 400 machine and saved in the VCL format
% 
% Created by: Peter Babkevich | 13.03.2019


fig = findobj('Tag','KX400_main');
if ~isempty(fig)
    handles.figure = figure(1234);
    clf
    newpos = 'n';
else
    
    handles.figure = figure(1234);
    set(handles.figure,     'Name','Kelvinox 400 system view',...
                            'NumberTitle','off',...
                            'Tag','KX400_main',...
                            'MenuBar','none', ...
                            'Toolbar','none', ...
                            'resize','off');
    newpos = 'y';
end

set(handles.figure,'units','pixels')
set(handles.figure, 'PaperPositionMode', 'manual');

if strcmpi(newpos,'y')
    mon = get(0,'MonitorPositions') + 200;        
else
    mon = get(handles.figure,'position');
end
set(handles.figure, 'Position', [mon(end,1:2) 1200 800]);


uicontrol(      'style','PushButton',...
                'string','1. Load',...
                'units','pixels',...
                'Position',[30,450,50,20],...
                'CallBack',{@convertfile},...
                'TooltipString','Load particular run',...
                'tag','KX400_go')       
            
            
uicontrol(      'style','PushButton',...
                'string','No data',...
                'units','pixels',...
                'Position',[100,450,50,20],...
                'CallBack',{@plotdata},...
                'TooltipString','Load particular run',...
                'tag','KX400_plotfile')              
            
list = {...
'Timestamp (s)',...
'pressure.P2 (bar)',...
'pressure.P1 (bar)',...
'pressure.P5 (bar)',...
'pressure.P3 (bar)',...
'pressure.P4 (bar)',...
'1Kplate.t (s)',...
'1Kplate.T (K)',...
'1Kplate.R (Ohms)',...
'Sorb.S (s)',...
'Sorb.T (K)',...
'Sorb.R (Ohms)',...
'Coldplate.t (s)',...
'Coldplate.T (K)',...
'Coldplate.R (Ohms)',...
'Still.t (s)',...
'Still.T (K)',...
'Still.R (Ohms)',...
'MC.t (s)',...
'MC.T (K)',...
'MC.R (Ohms)',...
'ch6.t (s)',...
'ch6.T (K)',...
'ch6.R (Ohms)',...
'ch7.t (s)',...
'ch7.T (K)',...
'ch7.R (Ohms)',...
'heaters.still (W)',...
'heaters.chamber (W)',...
'heaters.ivc (W)',...
'turbo.current (A)',...
'turbo.power (W)',...
'turbo.speed (Hz)',...
'turbo.motor (C)',...
'turbo.bottom (C)',...
'Time ellapsed (h)',...
};

uicontrol('Style','PopupMenu',...
                'String',list,...
                'units','pixels',...
                'Position',[20,400,150,20],...
                'CallBack',{@userdata},...
                'tag','KX400_plotx');

uicontrol('Style','PopupMenu',...
                'String',list,...
                'units','pixels',...
                'Position',[20,300,150,20],...
                'CallBack',{@userdata},...
                'tag','KX400_ploty');       
            
%% Axes legends            
uicontrol(      'style','ToggleButton',...
                'string','MC',...
                'units','pixels',...
                'Position',[600,720,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_t1')    
uicontrol(      'style','ToggleButton',...
                'string','CP',...
                'units','pixels',...
                'Position',[600,695,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_t2') 
uicontrol(      'style','ToggleButton',...
                'string','St',...
                'units','pixels',...
                'Position',[600,670,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_t3') 
uicontrol(      'style','ToggleButton',...
                'string','So',...
                'units','pixels',...
                'Position',[600,645,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_t4') 
uicontrol(      'style','ToggleButton',...
                'string','1K',...
                'units','pixels',...
                'Position',[600,620,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_t5')   
            
            
uicontrol(      'style','ToggleButton',...
                'string','P1',...
                'units','pixels',...
                'Position',[600,360,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_p1')    
uicontrol(      'style','ToggleButton',...
                'string','P2',...
                'units','pixels',...
                'Position',[600,335,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_p2') 
uicontrol(      'style','ToggleButton',...
                'string','P3',...
                'units','pixels',...
                'Position',[600,310,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_p3') 
uicontrol(      'style','ToggleButton',...
                'string','P4',...
                'units','pixels',...
                'Position',[600,285,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_p4') 
uicontrol(      'style','ToggleButton',...
                'string','P5',...
                'units','pixels',...
                'Position',[600,260,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_p5')    
            
uicontrol(      'style','ToggleButton',...
                'string','MC',...
                'units','pixels',...
                'Position',[1080,360,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_h1')    
uicontrol(      'style','ToggleButton',...
                'string','St',...
                'units','pixels',...
                'Position',[1080,335,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_h2') 
uicontrol(      'style','ToggleButton',...
                'string','So',...
                'units','pixels',...
                'Position',[1080,310,50,20],...
                'CallBack',{@legendcontrl},...
                'tag','KX400_leg_h3')          
            
%% Add plot axes
ax1 = axes('position',[0.2 0.1 0.35 0.4],...
    'yscale','lin',...
    'xscale','lin',...
    'box', 'on',...
    'tag','KX400_ax1',...
    'buttonDownFcn',[]);

ax2 = axes('position',[0.2 0.55 0.35 0.4],...
    'yscale','lin',...
    'xscale','lin',...
    'box', 'on',...
    'tag','KX400_ax2',...
    'buttonDownFcn',[]);

ax3 = axes('position',[0.6 0.1 0.35 0.4],...
    'yscale','lin',...
    'xscale','lin',...
    'box', 'on',...
    'tag','KX400_ax3',...
    'buttonDownFcn',[]);

ax4 = axes('position',[0.6 0.55 0.35 0.4],...
    'yscale','lin',...
    'xscale','lin',...
    'box', 'on',...
    'tag','KX400_ax4',...
    'buttonDownFcn',[]);


% uicontrol(      'style','PushButton',...
%                 'string','Monitor',...
%                 'units','pixels',...
%                 'Position',[100,500,50,20],...
%                 'CallBack',{@monitor},...
%                 'TooltipString','Monitor and update fridge status',...
%                 'tag','KX400_mon')            
% 
% uicontrol(      'style','PushButton',...
%                 'string','Stop',...
%                 'units','pixels',...
%                 'Position',[50,500,50,20],...
%                 'CallBack',{@stopmon},...
%                 'TooltipString','Stop monitor and update fridge status',...
%                 'tag','KX400_stopmon')  
            
uicontrol(      'style','edit',...
                'string',[],...
                'units','pixels',...
                'Position',[20,350,50,20],...
                'CallBack',{@setlimits},...
                'tag','KX400_ax4_xmin')

uicontrol(      'style','edit',...
                'string',[],...
                'units','pixels',...
                'Position',[100,350,50,20],...
                'CallBack',{@setlimits},...
                'tag','KX400_ax4_xmax')
            
uicontrol(      'style','edit',...
                'string',[],...
                'units','pixels',...
                'Position',[20,250,50,20],...
                'CallBack',{@setlimits},...
                'tag','KX400_ax4_ymin')
            
uicontrol(      'style','edit',...
                'string',[],...
                'units','pixels',...
                'Position',[100,250,50,20],...
                'CallBack',{@setlimits},...
                'tag','KX400_ax4_ymax')  
            
        
end


function stopmon(source,eventdata,handles)

data_gui = guidata(findobj('tag','KX400_main'));
data_gui.timer = false;
guidata(findobj('tag','KX400_main'),data_gui)

end

function monitor(source,eventdata,handles)

h = guihandles;
path = 'C:\Users\Peter\Documents\MATLAB\readvcl\';

% Find last .vcl file
listings = dir(path);
timestamp = [listings.datenum];
[srt ind] = sort(timestamp,'descend');

for n = 1:length(srt)
    file = listings(ind(n)).name;
    try
    if length(file) > 4
        if strcmpi(file(end-3:end),'vcl')
            break
        end
    end
    catch me
        keyboard
    end
end

% Write file paths and names
data_gui = guidata(findobj('tag','KX400_main'));
data_gui.path = path;
data_gui.file = file;
data_gui.timer = true;
guidata(findobj('tag','KX400_main'),data_gui)

t = timer('TimerFcn',@convertfile, 'Period', 10.0);
t.UserData = true;

start(t);
while get(t,'UserData')
    data=convertfile(path,file);
    plotdata(data)
    data_gui = guidata(findobj('tag','KX400_main'));
    t.UserData = data_gui.timer;
    pause(10);
end
stop(t);
delete(t);
disp('Stopped')

end

function convertfile(obj,event)

h = guihandles;
set(h.KX400_plotfile,'BackgroundColor',[0.9 0.3 0.3],'String','wait...')

% Function to convert vcl file to txt:
% system([data_gui.path 'VCL_2_ASCII_CONVERTER.exe "' data_gui.file(1:end-4) '.vcl"'])
% t = timer('TimerFcn',@mycallback, 'Period', 10.0);

% data_gui.path = 'C:\Users\babkevic\Documents\Instrumentation\Kelvinox 400\2019-03-11 Troubleshooting';
% data_gui.file = 'log 130201 155012.txt';

% Ask for user selection of a file to load
[file,path] = uigetfile('*.vcl','Select VCL file to load');
file = [file(1:end-4) '.txt'];

if path == 0
    disp('Loading file aborted')
    return
end

tic
cd(path)

% Check to see if a new vcl file has been downloaded and remake the txt
% file conversion
FileInfo_txt = dir(file);
FileInfo_vcl = dir([file(1:end-4) '.vcl']);


if exist(file, 'file')==0 || FileInfo_txt.datenum < FileInfo_vcl.datenum
    status = system(['VCL_2_ASCII_CONVERTER.exe "' file(1:end-4) '.vcl"']);
    if status == 0
        disp('File conversion successful')
    else
        disp('File conversion not successful')
        return
    end
end

data = load_kelvinox(path,file);

data.file = file;
data.path = path;

disp(['Data file loaded in ' num2str(toc,'%3.2f') ' s'])

set(h.KX400_plotfile,'BackgroundColor',[0.3 0.9 0.3],'String','2. Plot!')
set(h.KX400_main,'Name',['Kelvinox 400 system view: ' file(1:end-4) '.vcl'])

guidata(h.KX400_main,data)

end

function data = load_kelvinox(path,file)
% Load the .csv file which logs the Kelvinox dilution fridge state

curdir = cd;
disp(file)
disp('... loading dilution fridge state')

% Obsolete, slow loading code: --------------------------------------------
% % % fid = fopen([path filesep file]);
% % % tline = fgetl(fid);
% % % tline = fgetl(fid);
% % % n = 1;
% % % while ischar(tline)
% % % %     disp(tline);
% % %     tline = fgetl(fid);
% % % 
% % %     if ~isempty(tline) && ~isnumeric(tline) && length(str2num(tline)) == 62
% % %         data.recorded(n,1:62) = str2num(tline);
% % %         flag = false;
% % %     end
% % %     if ~isempty(tline) && ~isnumeric(tline) && length(str2num(tline)) == 11
% % %         % No Lakeshore was connected to log the temperatures during cool
% % %         % down
% % %         flag = true;
% % %         readin = str2num(tline);
% % %         data.recorded(n,1:62) = NaN;
% % %         data.recorded(n,1:6) = readin(1:6);
% % %         data.recorded(n,58:62) = readin(7:11);        
% % %     end
% % %     
% % %     n = n + 1;
% % % end
% % % fclose(fid);

% Read text files
inp = importdata(fullfile(path,file));

if size(inp.data,2) == 62
    flag = false;
    data.recorded = inp.data;
end
if size(inp.data,2) == 11
    flag = true;    
    data.recorded(size(inp.data,1),1:62) = NaN;
    data.recorded(:,1:6) = inp.data(:,1:6);
    data.recorded(:,58:62) = inp.data(:,7:11);
end

if flag
    disp('Warning: no Lakeshore data found in file')    
end


%% Parameterise the data measured =========================================
% data.npoint = data.recorded(:,2);

% Convert epoch into matlab timestamp -------------------------------------
% offset (serial date number for 1/1/1970)
dnOffset = datenum('01-Jan-1970 01:00:00');         % GMT -> CET
% assuming it's read in as a string originally
tstamp = num2str(data.recorded(:,1));
% convert to a number, dived by number of seconds
% per day, and add offset
dnNow = str2num(tstamp)/(24*60*60) + dnOffset;

data.timeserial = dnNow;
data.timehoursellapsed = (dnNow - dnNow(1))*24;
% -------------------------------------------------------------------------

% Pressure guages (Bar)
data.pressure.P2 = data.recorded(:,2);              % Bar
data.pressure.P1 = data.recorded(:,3);              % Bar
data.pressure.P5 = data.recorded(:,4);              % Bar
data.pressure.P3 = data.recorded(:,5)*1e-3;         % Bar
data.pressure.P4 = data.recorded(:,6)*1e-3;         % Bar

% 1K plate readings
data.diag.Kplate.t = data.recorded(:,7);            % time (s)
data.diag.Kplate.T = data.recorded(:,8);            % temperature (K)
data.diag.Kplate.R = data.recorded(:,9);            % resistance (Ohms)

% Sorb readings
data.diag.Sorb.t = data.recorded(:,10);             % time (s)
data.diag.Sorb.T = data.recorded(:,11);             % temperature (K)
data.diag.Sorb.R = data.recorded(:,12);             % resistance (Ohms)

% Cold plate readings
data.diag.Coldplate.t = data.recorded(:,13);        % time (s)
data.diag.Coldplate.T = data.recorded(:,14);        % temperature (K)
data.diag.Coldplate.R = data.recorded(:,15);        % resistance (Ohms)

% Still readings
data.diag.Still.t = data.recorded(:,16);            % time (s)
data.diag.Still.T = data.recorded(:,17);            % temperature (K)
data.diag.Still.R = data.recorded(:,18);            % resistance (Ohms)

% Mixing chamber readings
data.diag.MC.t = data.recorded(:,19);               % time (s)
data.diag.MC.T = data.recorded(:,20);               % temperature (K)
data.diag.MC.R = data.recorded(:,21);               % resistance (Ohms)

% Channel 6
data.diag.ch6.t = data.recorded(:,22);               % time (s)
data.diag.ch6.T = data.recorded(:,23);               % temperature (K)
data.diag.ch6.R = data.recorded(:,24);               % resistance (Ohms)

% Channel 7
data.diag.ch7.t = data.recorded(:,25);               % time (s)
data.diag.ch7.T = data.recorded(:,26);               % temperature (K)
data.diag.ch7.R = data.recorded(:,27);               % resistance (Ohms)

% Heaters
data.heaters.still = data.recorded(:,55);           % Still heater (W)
data.heaters.chamber = data.recorded(:,56);         % Chamber heater (W)
data.heaters.ivc = data.recorded(:,57);             % IVC heater (W)

% State of the turbo pump
data.turbo.current = data.recorded(:,58);           % current (A)
data.turbo.power = data.recorded(:,59);             % power (W)
data.turbo.speed = data.recorded(:,60);             % speed (Hz)
data.turbo.motor = data.recorded(:,61);             % motor (C)
data.turbo.bottom = data.recorded(:,62);            % bottom (C)    

% Time ellapsed since start of recording
data.recorded(:,63) = data.timehoursellapsed;

cd(curdir)
end

function plotdata(obj,event)

h = guihandles(findobj('tag','KX400_main'));
data = guidata(h.KX400_main);

figure(h.KX400_main)

opt = 2;

if opt == 1
    % Display dd-mm|HH:MM on the x-axis
    xd = data.timeserial;
else
    % Display the hours ellapsed since the start of the log file
    xd = data.timehoursellapsed;
end

ax1 = h.KX400_ax1;
ax2 = h.KX400_ax2;
ax3 = h.KX400_ax3;
ax4 = h.KX400_ax4;

h1 = plot(ax1,  xd,data.pressure.P1,...
                xd,data.pressure.P2,...
                xd,data.pressure.P3,...
                xd,data.pressure.P4,...
                xd,data.pressure.P5,...
                'tag','KX400_pressure');
if opt == 1, datetick(ax1,'x','dd-mm|HH:MM'), end
% legend(h1,'P1','P2','P3','P4','P5')

ylabel(ax1,'Pressure (bar)')

h2 = plot(ax2,  xd,data.diag.MC.T,...
                xd,data.diag.Coldplate.T,...
                xd,data.diag.Still.T,...
                xd,data.diag.Sorb.T,...
                xd,data.diag.Kplate.T,...
                'tag','KX400_temp');
if opt == 1, datetick(ax2,'x','dd-mm|HH:MM'), end
ylabel(ax2,'Temperature (K)')
% legend(h2,'MC','CP','St','So','1K')
set(h2(1),'linewidth',2)

h3 = plot(ax3,  xd,data.heaters.chamber*1000,...
                xd,data.heaters.still*1000,...
                xd,data.heaters.ivc*1000,...
                'tag','KX400_heater');
if opt == 1, datetick(ax3,'x','dd-mm|HH:MM'), end
ylabel(ax3,'Heaters (mW)')
% legend(h3,'MC','St','So')

if opt == 1
    set(ax1,'xtick',floor(min(data.timeserial)):1/24:ceil(max(data.timeserial)))
    set(ax2,'xtick',floor(min(data.timeserial)):1/24:ceil(max(data.timeserial)))
    set(ax3,'xtick',floor(min(data.timeserial)):1/24:ceil(max(data.timeserial)))

    datetick(ax1,'x','dd-mm|HH:MM','keepticks')
    datetick(ax2,'x','dd-mm|HH:MM','keepticks')
    datetick(ax3,'x','dd-mm|HH:MM','keepticks')
end

set(ax1,'tag','KX400_ax1')
set(ax2,'tag','KX400_ax2')
set(ax3,'tag','KX400_ax3')
set(ax4,'tag','KX400_ax4')

set([ax1 ax2 ax3],'xlim',[min(xd) max(xd)])
set([ax1 ax2],'ylim',[0 1])
set(ax2,'XAxisLocation','top')

dragzoom([ax1 ax2 ax3])

linkaxes([ax1 ax2 ax3],'x')
grid(ax1,'on')
grid(ax2,'on')
grid(ax3,'on')

if opt == 1
    set(ax1,'XTickLabelRotation',45)
    set(ax2,'XTickLabelRotation',45)
    set(ax3,'XTickLabelRotation',45)
end

set(h.KX400_main,'Name',['Kelvinox 400 system view: ' data.file(1:end-4) '.vcl'])

% Make legends
set(h.KX400_leg_t1,'BackgroundColor',get(h1(1),'color'),'value',0)
set(h.KX400_leg_t2,'BackgroundColor',get(h1(2),'color'),'value',0)
set(h.KX400_leg_t3,'BackgroundColor',get(h1(3),'color'),'value',0)
set(h.KX400_leg_t4,'BackgroundColor',get(h1(4),'color'),'value',0)
set(h.KX400_leg_t5,'BackgroundColor',get(h1(5),'color'),'value',0)

set(h.KX400_leg_p1,'BackgroundColor',get(h2(1),'color'),'value',0)
set(h.KX400_leg_p2,'BackgroundColor',get(h2(2),'color'),'value',0)
set(h.KX400_leg_p3,'BackgroundColor',get(h2(3),'color'),'value',0)
set(h.KX400_leg_p4,'BackgroundColor',get(h2(4),'color'),'value',0)
set(h.KX400_leg_p5,'BackgroundColor',get(h2(5),'color'),'value',0)

set(h.KX400_leg_h1,'BackgroundColor',get(h3(1),'color'),'value',0)
set(h.KX400_leg_h2,'BackgroundColor',get(h3(2),'color'),'value',0)
set(h.KX400_leg_h3,'BackgroundColor',get(h3(3),'color'),'value',0)

end

function userdata(obj,event)

h = guihandles;
data = guidata(h.KX400_main);

list = get(h.KX400_plotx,'string');


indx = get(h.KX400_plotx,'Value');
indy = get(h.KX400_ploty,'Value');


if indx > 27
    indx = indx + 27;
end
if indy > 27
    indy = indy + 27;
end

ax1 = h.KX400_ax1;
ax2 = h.KX400_ax2;
ax3 = h.KX400_ax3;
ax4 = h.KX400_ax4;

linkaxes([ax1 ax2 ax3],'x')

if indx == 1
    hp = plot(ax4,  data.timeserial,data.recorded(:,indy));
    datetick(ax4,'x','dd-mm|HH:MM')
    datetick(ax4,'x','dd-mm|HH:MM','keepticks')
elseif indy == 1
    hp = plot(ax4,  data.recorded(:,indx),data.timeserial);
else
    hp = plot(ax4,  data.recorded(:,indx),data.recorded(:,indy));
end
set(ax4,'XAxisLocation','top')
set(ax4,'tag','KX400_ax4')
grid(ax4,'on')

dragzoom([ax1 ax2 ax3 ax4])    

if indx > 27
    xlabel(ax4,list{indx-27})
else
    xlabel(ax4,list{indx})
end
if indy > 27
    ylabel(ax4,list{indy-27})
else
    ylabel(ax4,list{indy})
end

xl = xlim(ax4);
yl = ylim(ax4);

set(h.KX400_ax4_xmin,'String',num2str(xl(1)));
set(h.KX400_ax4_xmax,'String',num2str(xl(2)));
set(h.KX400_ax4_ymin,'String',num2str(yl(1)));
set(h.KX400_ax4_ymax,'String',num2str(yl(2)));

set(h.KX400_main,'Name',['Kelvinox 400 system view: ' data.file(1:end-4) '.vcl'])

end

function setlimits(obj,event)
h = guihandles;

ax4 = h.KX400_ax4;

axes(ax4)

xl(1) = str2double(get(h.KX400_ax4_xmin,'String'));
xl(2) = str2double(get(h.KX400_ax4_xmax,'String'));

yl(1) = str2double(get(h.KX400_ax4_ymin,'String'));
yl(2) = str2double(get(h.KX400_ax4_ymax,'String'));

xlim(ax4,xl)
ylim(ax4,yl)

end

function legendcontrl(obj,event)
h = guihandles;

nocol = [0.8 0.8 0.8];

if ~get(h.KX400_leg_t1,'value') && strcmpi(event.Source.Tag,'KX400_leg_t1')
    set(h.KX400_temp(5),'visible','on')
    set(h.KX400_leg_t1,'BackgroundColor',get(h.KX400_temp(5),'color'))
elseif get(h.KX400_leg_t1,'value') && strcmpi(event.Source.Tag,'KX400_leg_t1')
    set(h.KX400_temp(5),'visible','off')
    set(h.KX400_leg_t1,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_t2,'value') && strcmpi(event.Source.Tag,'KX400_leg_t2')
    set(h.KX400_temp(4),'visible','on')
    set(h.KX400_leg_t2,'BackgroundColor',get(h.KX400_temp(4),'color'))
elseif get(h.KX400_leg_t2,'value') && strcmpi(event.Source.Tag,'KX400_leg_t2')
    set(h.KX400_temp(4),'visible','off')
    set(h.KX400_leg_t2,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_t3,'value') && strcmpi(event.Source.Tag,'KX400_leg_t3')
    set(h.KX400_temp(3),'visible','on')
    set(h.KX400_leg_t3,'BackgroundColor',get(h.KX400_temp(3),'color'))
elseif get(h.KX400_leg_t3,'value') && strcmpi(event.Source.Tag,'KX400_leg_t3')
    set(h.KX400_temp(3),'visible','off')
    set(h.KX400_leg_t3,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_t4,'value') && strcmpi(event.Source.Tag,'KX400_leg_t4')
    set(h.KX400_temp(2),'visible','on')
    set(h.KX400_leg_t4,'BackgroundColor',get(h.KX400_temp(2),'color'))
elseif get(h.KX400_leg_t4,'value') && strcmpi(event.Source.Tag,'KX400_leg_t4')
    set(h.KX400_temp(2),'visible','off')
    set(h.KX400_leg_t4,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_t5,'value') && strcmpi(event.Source.Tag,'KX400_leg_t5')
    set(h.KX400_temp(1),'visible','on')
    set(h.KX400_leg_t5,'BackgroundColor',get(h.KX400_temp(1),'color'))
elseif get(h.KX400_leg_t5,'value') && strcmpi(event.Source.Tag,'KX400_leg_t5')
    set(h.KX400_temp(1),'visible','off')
    set(h.KX400_leg_t5,'BackgroundColor',nocol)
end


if ~get(h.KX400_leg_p1,'value') && strcmpi(event.Source.Tag,'KX400_leg_p1')
    set(h.KX400_pressure(5),'visible','on')
    set(h.KX400_leg_p1,'BackgroundColor',get(h.KX400_pressure(5),'color'))
elseif get(h.KX400_leg_p1,'value') && strcmpi(event.Source.Tag,'KX400_leg_p1')
    set(h.KX400_pressure(5),'visible','off')
    set(h.KX400_leg_p1,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_p2,'value') && strcmpi(event.Source.Tag,'KX400_leg_p2')
    set(h.KX400_pressure(4),'visible','on')
    set(h.KX400_leg_p2,'BackgroundColor',get(h.KX400_pressure(4),'color'))
elseif get(h.KX400_leg_p2,'value') && strcmpi(event.Source.Tag,'KX400_leg_p2')
    set(h.KX400_pressure(4),'visible','off')
    set(h.KX400_leg_p2,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_p3,'value') && strcmpi(event.Source.Tag,'KX400_leg_p3')
    set(h.KX400_pressure(3),'visible','on')
    set(h.KX400_leg_p3,'BackgroundColor',get(h.KX400_pressure(3),'color'))
elseif get(h.KX400_leg_p3,'value') && strcmpi(event.Source.Tag,'KX400_leg_p3')
    set(h.KX400_pressure(3),'visible','off')
    set(h.KX400_leg_p3,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_p4,'value') && strcmpi(event.Source.Tag,'KX400_leg_p4')
    set(h.KX400_pressure(2),'visible','on')
    set(h.KX400_leg_p4,'BackgroundColor',get(h.KX400_pressure(2),'color'))
elseif get(h.KX400_leg_p4,'value') && strcmpi(event.Source.Tag,'KX400_leg_p4')
    set(h.KX400_pressure(2),'visible','off')
    set(h.KX400_leg_p4,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_p5,'value') && strcmpi(event.Source.Tag,'KX400_leg_p5')
    set(h.KX400_pressure(1),'visible','on')
    set(h.KX400_leg_p5,'BackgroundColor',get(h.KX400_pressure(1),'color'))
elseif get(h.KX400_leg_p5,'value') && strcmpi(event.Source.Tag,'KX400_leg_p5')
    set(h.KX400_pressure(1),'visible','off')
    set(h.KX400_leg_p5,'BackgroundColor',nocol)
end


if ~get(h.KX400_leg_h1,'value') && strcmpi(event.Source.Tag,'KX400_leg_h1')
    set(h.KX400_heater(3),'visible','on')
    set(h.KX400_leg_h1,'BackgroundColor',get(h.KX400_heater(3),'color'))
elseif get(h.KX400_leg_h1,'value') && strcmpi(event.Source.Tag,'KX400_leg_h1')
    set(h.KX400_heater(3),'visible','off')
    set(h.KX400_leg_h1,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_h2,'value') && strcmpi(event.Source.Tag,'KX400_leg_h2')
    set(h.KX400_heater(2),'visible','on')
    set(h.KX400_leg_h2,'BackgroundColor',get(h.KX400_heater(2),'color'))
elseif get(h.KX400_leg_h2,'value') && strcmpi(event.Source.Tag,'KX400_leg_h2')
    set(h.KX400_heater(2),'visible','off')
    set(h.KX400_leg_h2,'BackgroundColor',nocol)
end
if ~get(h.KX400_leg_h3,'value') && strcmpi(event.Source.Tag,'KX400_leg_h3')
    set(h.KX400_heater(1),'visible','on')
    set(h.KX400_leg_h3,'BackgroundColor',get(h.KX400_heater(1),'color'))
elseif get(h.KX400_leg_h3,'value') && strcmpi(event.Source.Tag,'KX400_leg_h3')
    set(h.KX400_heater(1),'visible','off')
    set(h.KX400_leg_h3,'BackgroundColor',nocol)
end
end


