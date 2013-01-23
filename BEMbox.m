function [] = BEMbox()
% Run to start the BEMbox GUI
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
% Version: 13/01/22

evalin('base','clear all; close all; clc;');
addpath('functions','gui','tdbem')

global obj
obj=tdbem;
obj.file.path=fileparts(mfilename('fullpath'));

%% GUI definitions
SCR = get(0,'Screensize');  % Get screensize.


S.gui = figure('numbertitle','off',...
              'menubar','none',...
              'units','pixels',...
              'position',[SCR(3)/2-400 ,SCR(4)/2-300 , 800, 600],...
              'name','BEMbox',...
              'resize','off',...
              'Toolbar','figure');

%S.toolbar=
          
S.plot = axes('units','pixels',...
            'position',[260 100 450 450]);
        
% Logo
img = imread(['img' filesep 'BEMbox.png']);
axes(S.plot);
image(img);
              
% Tabs             
S.tab(1) = uicontrol('style','toggle',...
                    'units','pixels',...
                    'position',[5 555 100 40],...
                    'string','BEM-Calculation');
S.tab(2) = uicontrol('style','toggle',...
                    'units','pixels',...
                    'position',[105 555 60 40],...
                    'string','About',...
                    'enable','on');
S.tab(3) = uicontrol('style','toggle',...
                    'units','pixels',...
                    'position',[165 555 60 40],...
                    'string','Quit',...
                    'Tag','quitbutton',...
                    'enable','on');
                
% Buttons
S.button(1) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[25 400 100 40],...
                    'string','load mesh',...
                    'enable','on',...
                    'callback',@button_call);
S.button(2) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[25 350 100 40],...
                    'string','load mic',...
                    'enable','off',...
                    'callback',@button_call);
S.button(3) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[25 300 100 40],...
                    'string',sprintf('load bc'),...
                    'enable','off',...
                    'callback',@button_call);
S.button(4) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[25 250 100 40],...
                    'string','set parameters',...
                    'enable','off',...
                    'callback',@button_call);
S.button(5) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[25 150 100 40],...
                    'string','start calculation',...
                    'enable','off',...
                    'callback',@button_call);
                               
% About
S.about = uicontrol('style','text',...
                 'units','pixels',...
                 'position',[50 50 700 500],...
                 'visible','off',...
                 'string',{' ','BEMbox', 'Matlab Toolbox for Time Domain Boundary Element Method calculations',...
                 ' ','bla'},...
                 'fontsize',15);
             
%% Set function calls on button click
set(S.tab(:),{'callback'},{{@tab_call,S}})
set(S.button(:),{'callback'},{{@button_call,S}})

%% Callback for tab buttons
function [] = tab_call(varargin)
[h,S] = varargin{[1,3]};  % Get calling handle ans structure.
if get(h,'val')==0  % Here the Toggle is already pressed.
    set(h,'val',1) % To keep the Tab-like functioning.
end

L = get(S.plot,'children');
switch h
    case S.tab(1)
        set(S.tab([2,3]),'val',0)
        set(S.button(:),'val',0)   
        set([S.plot;L;S.button(:)],{'visible'},{'on'})
        set(S.about,{'visible'},{'off'})
    case S.tab(2)
        set(S.tab([1,3]),'val',0)
        set(S.about,'visible','on')
        set([S.plot;L;S.button(:)],{'visible'},{'off'})  
    otherwise
        set(S.tab([1,2]),'val',0)
        quitdlg='Do you really want to quit?';
        choice = questdlg(quitdlg,'Quit BEMbox?','Yes','No','No');
        switch choice
            case 'No'
                % take no action
            case 'Yes'
                % close the application window
                close(S.gui)            
        end
end

%% Callback for tab buttons
function [] = button_call(varargin)
global obj
[h,S] = varargin{[1,3]};  % Get calling handle ans structure.

switch h
    case S.button(1)
        % Load mesh
        set(S.button,'val',0); set(S.button(1),'val',1);
               
        % Open Geometry GUI and load elements and nodes
        gui_geo
        uiwait
                
        % Create areas and surface normals at center points
        geometry
        showMesh(S.plot)
        
        % Finishing loading mesh by coloring the button
        set(S.button(1),'BackgroundColor',[0 1 0])
        % ...and enable the next step
        set(S.button(2),'enable','on')
    case S.button(2)
        % Load mic
        set(S.button,'val',0); set(S.button(2),'val',1);
        
        % Open Mic GUI and load nodes
        gui_mic
        uiwait
        
        % Finishing loading mic by coloring the button
        set(S.button(2),'BackgroundColor',[0 1 0])
        % ...and enable the next step
        set(S.button(3),'enable','on')
    case S.button(3)
        % Load bc
        set(S.button,'val',0); set(S.button(3),'val',1);
        
        % Open Boundary Condition GUI and load nodes
        gui_bc
        uiwait
        
        % Finishing loading bc by coloring the button
        set(S.button(3),'BackgroundColor',[0 1 0])
        % ...and enable the next step
        set(S.button(4),'enable','on')        
    case S.button(4)
        % Set parameters
        set(S.button,'val',0); set(S.button(4),'val',1);
       
        % Open Boundary Condition GUI and load nodes
        gui_parameters
        uiwait
        
        % Finishing setting parameters by coloring the button
        set(S.button(4),'BackgroundColor',[0 1 0])
        % ...and enable the next step
        set(S.button(5),'enable','on')        
    otherwise
        % Start calculation
        set(S.button,'val',0); set(S.button(5),'val',1);
        tic
        
        % load or create project file
        if (exist([obj.file.folder filesep obj.file.name],'file')~=0)
            disp('load')
            load ([obj.file.folder filesep obj.file.name]);
        else
            disp('create')
            obj.file.folder
            mkdir(obj.file.folder)
            mkGH 
            mkGHi
            save([obj.file.folder filesep obj.file.name])
        end
        
        % calculate pressures
        mkp
        mkpi
        
        NFFT=512;
        N=NFFT/2;
        obj.f=1./(obj.dt*NFFT*[0:NFFT/2-1]);

        p_sqz=abs(2*fft(obj.pmic(:,obj.Nt-NFFT+1:end)')./NFFT).^2;
        p0=(2e-5);
        Lpz=zeros(NFFT/2,length(p_sqz(1,:)));

        %% for polar plots      %OLAF: WIESO AUSGEBLENDET?... WIESO POLAR PLOT?
        for j = 1:NFFT/2
            Lpz(j,:)=10*log10((p_sqz(j,:))./p0^2);
            Lpz(j,(Lpz(j,:)<0))=0;
        end
          
        %% graphical output
        showResults(Lpz,S.plot)
        
        toc
end