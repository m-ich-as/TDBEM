classdef tdbem < handle
% Class TDBEM - Definition of the Main Class of the 
% Toolbox for Time Domain Boundary Element Method
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
    properties
        c=340;          % default value speed of sound        
        gausspts=16;    % default value number of gauss-points
        ratio=4;        % default value allocation
        file            % file name and path
        mesh            % geometry data of elements and nodes
        mic             % geometry data of immission points
        dt=5e-004;      % time step
        Nt=512;         % number of time steps
        f               % frequency vector of result
        bc              % flux boundary conditon and time vector
        p               % calculated pressure on surface
        pmic            % calculated pressure in immission points
    end % properties  
end % class