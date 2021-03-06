function [] = gui_parameters()
% GUI Parameters - Set additional parameters
%
% <BEMbox>
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License (GPL)
% as published by the Free Software Foundation, see 
% http://www.gnu.org/licenses/
%
% Authors: Michael St�tz
%          Olaf B�lke
%          Lennart Moheit
% Contact: michael.stuetz@tu-berlin.de
%          http://www.akustik.tu-berlin.de
% </BEMbox>
% Version: 13/01/22

global obj

%% GUI definitions
SCR = get(0,'Screensize');  % Get screensize.

S.gui = figure('numbertitle','off',...
              'menubar','none',...
              'units','pixels',...
              'position',[SCR(3)/2-150 ,SCR(4)/2-110 , 300, 220],...
              'name','BEMbox ~ Parameters',...
              'resize','off');
              
S.parameter(1,1) = uicontrol('style','text',...
                 'units','pixels',...
                 'position',[10 190 130 20],...
                 'visible','on',...
                 'string','Project Name',...
                 'fontsize',10);
project_name='project_01';
% if(~isempty(obj.file.folder))
%     project_name=obj.file.folder;
% end
S.parameter(1,2) = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[150 190 130 20],...
                 'visible','on',...
                 'string',project_name,...
                 'fontsize',10);
            
S.parameter(2,1) = uicontrol('style','text',...
                 'units','pixels',...
                 'position',[10 160 130 20],...
                 'visible','on',...
                 'string','Speed of sound c',...
                 'fontsize',10);             
S.parameter(2,2) = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[150 160 130 20],...
                 'visible','on',...
                 'string',obj.c,...
                 'fontsize',10);
             
S.parameter(3,1) = uicontrol('style','text',...
                 'units','pixels',...
                 'position',[10 130 130 20],...
                 'visible','on',...
                 'string','Ratio r',...
                 'fontsize',10);
S.parameter(3,2) = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[150 130 130 20],...
                 'visible','on',...
                 'string',obj.ratio,...
                 'fontsize',10);
             
S.parameter(4,1) = uicontrol('style','text',...
                 'units','pixels',...
                 'position',[10 100 130 20],...
                 'visible','on',...
                 'string','Time step dt',...
                 'fontsize',10);
S.parameter(4,2) = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[150 100 130 20],...
                 'visible','on',...
                 'string',obj.dt,...
                 'fontsize',10);
             
S.parameter(5,1) = uicontrol('style','text',...
                 'units','pixels',...
                 'position',[10 70 130 20],...
                 'visible','on',...
                 'string','No. of time steps Nt',...
                 'fontsize',10);
S.parameter(5,2) = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[150 70 130 20],...
                 'visible','on',...
                 'string',obj.Nt,...
                 'fontsize',10);              
             
S.parameter(6,1) = uicontrol('style','text',...
                 'units','pixels',...
                 'position',[10 25 130 35],...
                 'visible','on',...
                 'string','No. of Gaussian points',...
                 'fontsize',10);
S.parameter(6,2) = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[150 40 130 20],...
                 'visible','on',...
                 'string',obj.gausspts,...
                 'fontsize',10);             
             
%Buttons
S.button = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[150 10 130 20],...
                    'string','Continue',...
                    'callback',{@send_data,S});

function status=check_parameters(src,eventdata)
% Check whether parameter are correctly chosen
    status=false;
    if(~isempty(get(S.parameter(1,2),'String')) && ...
       ~isempty(get(S.parameter(2,2),'String')) && ...
       ~isempty(get(S.parameter(3,2),'String')) && ...
       ~isempty(get(S.parameter(4,2),'String')) && ...
       ~isempty(get(S.parameter(5,2),'String')) && ...
       ~isempty(get(S.parameter(6,2),'String')))
        status=true;
    end
end % check_parameters

function send_data(src,eventdata,S)
    if(check_parameters==true)   
        % Project Name
        obj.file.folder=get(S.parameter(1,2),'String');
        obj.file.name=[obj.file.folder '.mat'];
        obj.file.folder=[obj.file.path filesep 'projects' filesep obj.file.folder];

        % Speed of Sound
        obj.c=str2double(get(S.parameter(2,2),'String'));
        
        % Ratio
        obj.ratio=str2double(get(S.parameter(3,2),'String'));

        % Time step
        obj.dt=str2double(get(S.parameter(4,2),'String'));
        
        % Number of Timesteps
        obj.Nt=str2double(get(S.parameter(5,2),'String'));
        
        % Gaussian Points
        obj.gausspts=str2double(get(S.parameter(6,2),'String'));
        
        close(S.gui)
    else
        msgbox('Please select all parameters.','Wrong input data selected','error')
    end
end % send_data

end % gui_parameters