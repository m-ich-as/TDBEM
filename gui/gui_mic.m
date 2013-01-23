function [] = gui_mic()
% GUI Mic - Load nodes from immission points
%
% <BEMbox>
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License (GPL)
% as published by the Free Software Foundation, see 
% http://www.gnu.org/licenses/
%
% Authors: Michael Stütz
%          Olaf Bölke
%          Lennart Moheit
% Contact: michael.stuetz@tu-berlin.de
%          http://www.akustik.tu-berlin.de
% </BEMbox>
% Version: 13.01.21

%% GUI definitions
SCR = get(0,'Screensize');  % Get screensize.

S.gui = figure('numbertitle','off',...
              'menubar','none',...
              'units','pixels',...
              'position',[SCR(3)/2-200 ,SCR(4)/2-100 , 400, 200],...
              'name','BEMbox ~ Immission Points',...
              'resize','off');
          
S.list = uicontrol('style','listbox','units','pixels', ... 
               'position',[10 90 150 100]);
           
S.button(1) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[165 140 100 40],...
                    'string','>>> Mic-Nodes >>>',...
                    'enable','on',...
                    'callback',@get_var_mic);
S.button(2) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[100 25 100 40],...
                    'string','Select new .mat-file',...
                    'enable','on',...
                    'callback',@update_listbox);
S.button(3) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[220 25 100 40],...
                    'string','Continue',...
                    'enable','on',...
                    'callback',@send_data);
          
S.text(1) = uicontrol('style','text',...
                    'units','pixels',...
                    'position',[280 145 100 30],...
                    'string','',...
                    'enable','on');         

%% Procedures          
          
% Populate the listbox
update_listbox() 

function update_listbox(src,eventdata)
global obj
    % Load workspace vars into list box
	vars = evalin('base','who');
	set(S.list,'String',vars)
    [FileName,PathName] = uigetfile('*.mat','Select .mat-file containing mic nodes data'); % get path ...
    obj.file.micfile=[PathName filesep FileName];
    evalin('base',['load ''' obj.file.micfile '''']);
    vars = evalin('base','who');
	set(S.list,'String',vars)
    set(S.gui,'Visible','on') 
end % update_listbox

function get_var_mic(src,eventdata)
    choice = get(S.list,'String');
    index = get(S.list,'Value');
    set(S.text(1),'String',choice(index))
    [~]=check_mic()
end % get_var_mic

function status=check_mic(src,eventdata)
% Check whether mic is correctly chosen
    status=false;
    if(~isempty(get(S.text(1),'String')))
        set(S.text(1),'BackgroundColor',[0 1 0])
        status=true;
    end    
end % check_mic

function send_data(src,eventdata)
global obj
    if(check_mic==true)   
        temp=get(S.text(1),'String'); temp=temp{1};
        obj.mic.nodes=evalin('base',temp);
        evalin('base',['clear ' temp]);

        obj.mic.Ni=size(obj.mic.nodes,1);
        close(S.gui)
    else
        msgbox('Please select matrix of Mic nodes.','Wrong input data selected','error')
    end
end % send_data

end % gui_mic