function showResults(Lp,h)
% Function showResults(Object) - Graphical output of the pressure at one
% examplary point
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
global obj
    plot(obj.f,Lp(:,1))    
    xlabel('f [Hz]');
    ylabel('L_p [dB]');

end % showResults