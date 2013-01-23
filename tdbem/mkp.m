function mkp()
% Function mkp(Object) - Calculate pressure on the surface
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

    disp('calculate pressure on surface')
    obj.p=zeros(size(obj.bc.q));            

    EYE=sparse(1:obj.mesh.Ne,1:obj.mesh.Ne,1);

    %A=-inverse(2*pi*EYE+obj.mesh.H{1}); %Factorize needed http://www.mathworks.com/matlabcentral/fileexchange/24119
    A=-inv(2*pi*EYE+obj.mesh.H{1});

    %OLAF: Diese Inverse schneller?... QR Zerlegung?...
    %A=-inv(2*pi*EYE+H{1});

    % progressbar            
    obj.p(:,1)=A*(obj.mesh.G{1}*obj.bc.q(:,1));
    for i=2:obj.Nt
        for my=2:min([obj.mesh.mymax i])
            if i==my
                obj.p(:,i)=obj.p(:,i)+obj.mesh.H{my}*((my)*obj.p(:,i-my+1))+ obj.mesh.G{my}*obj.bc.q(:,i-my+1);
            else
                obj.p(:,i)=obj.p(:,i)+obj.mesh.H{my}*((my)*obj.p(:,i-my+1)-(my-1)*obj.p(:,i-my))+ obj.mesh.G{my}*obj.bc.q(:,i-my+1);
            end
        end
        my=1;    %letzter Zeitschritt
        obj.p(:,i)=A*(obj.p(:,i)+obj.mesh.G{my}*obj.bc.q(:,i));
        %     progressbar(i/Nt)
    end
end % mkp