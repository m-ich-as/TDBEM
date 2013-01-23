function mkpi()
% Function mkpi(Object) - Calculate pressure at the immission points
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

    disp('calculate pressure in immission points')

    obj.pmic=zeros(obj.mic.Ni,obj.Nt);  % Platzhalter für Druck

    %   Zeitschritte berechnen
    %   ersten Zeitschritt i=1 berechnen
    i=1;j=1;
    obj.pmic(:,i)=-1./(4*pi).*(obj.mic.H{i-j+1}*obj.p(:,j)+obj.mic.G{i-j+1}*obj.bc.q(:,j)); % Achtung Minus neu
    progressbar % Create figure and set starting time
    for i=2:obj.Nt
        if i<=obj.mic.mymaxi
            j=1;
            obj.pmic(:,i)=obj.mic.H{i-j+1}*i*obj.p(:,1)+obj.mic.G{i-j+1}*obj.bc.q(:,1);
            for j=2:(i-1)
                obj.pmic(:,i)=obj.pmic(:,i)+obj.mic.H{i-j+1}*((i-j+1)*obj.p(:,j)-(i-j)*obj.p(:,j-1))+ obj.mic.G{i-j+1}*obj.bc.q(:,j);
            end
            j=i;    %letzter Zeitschritt
            obj.pmic(:,i)=-1./(4*pi).*(obj.pmic(:,i)+obj.mic.H{i-j+1}*obj.p(:,j)+obj.mic.G{i-j+1}*obj.bc.q(:,j));
        else
            for my=obj.mic.mymaxi:-1:2
                obj.pmic(:,i)=obj.pmic(:,i)+obj.mic.H{my}*((my)*obj.p(:,i-my+1)-(my-1)*obj.p(:,i-my))+ obj.mic.G{my}*obj.bc.q(:,i-my+1);
            end
            my=1;    %letzter Zeitschritt
            obj.pmic(:,i)=-1./(4*pi).*(obj.pmic(:,i)+obj.mic.H{my}*obj.p(:,j)+obj.mic.G{my}*obj.bc.q(:,j));
        end
        progressbar(i/obj.Nt) % Update figure
    end
end % mkpi
  