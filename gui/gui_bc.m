function [] = gui_bc()
% GUI Geometry - Load geometry data with elements and nodes
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
              'name','BEMbox ~ Boundary Conditions',...
              'resize','off');
          
S.list = uicontrol('style','listbox','units','pixels', ... 
               'position',[10 90 150 100]);
           
S.button(1) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[165 140 100 40],...
                    'string','>>> q flux vector>>>',...
                    'enable','on',...
                    'callback',@get_var_elements);
S.button(2) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[165 100 100 40],...
                    'string','>>> t time vector >>>',...
                    'enable','on',...
                    'callback',@get_var_nodes);
S.button(3) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[100 25 100 40],...
                    'string','Select new .mat-file',...
                    'enable','on',...
                    'callback',@update_listbox);
S.button(4) = uicontrol('style','push',...
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
S.text(2) = uicontrol('style','text',...
                    'units','pixels',...
                    'position',[280 105 100 30],...
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
    [FileName,PathName] = uigetfile('*.mat','Select .mat-file containing boundary condition data'); % get path ...
    obj.file.bcfile=[PathName filesep FileName];
    evalin('base',['load ''' obj.file.bcfile '''']);
    vars = evalin('base','who');
	set(S.list,'String',vars)
    set(S.gui,'Visible','on') 
end % update_listbox

function get_var_elements(src,eventdata)
    choice = get(S.list,'String');
    index = get(S.list,'Value');
    set(S.text(1),'String',choice(index))
    [~]=check_bc()
end % get_var_elements

function get_var_nodes(src,eventdata)
    choice = get(S.list,'String');
    index = get(S.list,'Value');
    set(S.text(2),'String',choice(index))
    [~]=check_bc()
end % get_var_nodes
    
function status=check_bc(src,eventdata)
% Check whether q and t are correctly chosen
    status=false;
    if(~isempty(get(S.text(1),'String')))
        set(S.text(1),'BackgroundColor',[0 1 0])
    end    
    if(~isempty(get(S.text(2),'String')))
        set(S.text(2),'BackgroundColor',[0 1 0])
    end
    if(isequal(get(S.text(1),'String'),get(S.text(2),'String')))
        set(S.text(1),'BackgroundColor',[1 0 0])
        set(S.text(2),'BackgroundColor',[1 0 0])
        status=false;
    elseif(~isempty(get(S.text(1),'String')) && ~isempty(get(S.text(2),'String')))
        status=true;
    end
end % check_bc

function send_data(src,eventdata)
global obj
    if(check_bc==true)   
        temp=get(S.text(1),'String'); temp=temp{1};
        obj.bc.q=evalin('base',temp);
        evalin('base',['clear ' temp]);
        temp=get(S.text(2),'String'); temp=temp{1};
        obj.bc.t=evalin('base',temp);
        evalin('base',['clear ' temp]);
        close(S.gui)
    else
        msgbox('You have to choose two different vectors for q und t.','Wrong input data selected','error')
    end
end % send_data

end % gui_bc