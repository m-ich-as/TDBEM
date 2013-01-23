function showMesh(h)
% Function showMesh(Object) - Visualization of the geometry input data
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
% Center points
plot3(h,obj.mesh.centre(:,1),obj.mesh.centre(:,2),obj.mesh.centre(:,3),'og')
hold on
% Geometry
patch('Vertices',obj.mesh.nodes,'Faces',obj.mesh.elements,'FaceColor',[1 0 0], 'FaceAlpha',0.7)
% Surface normal vectors
quiver3(obj.mesh.centre(:,1),obj.mesh.centre(:,2),obj.mesh.centre(:,3),...
obj.mesh.norma(:,1),obj.mesh.norma(:,2),obj.mesh.norma(:,3))

view(45,30)
grid on
axis vis3d

fps = 60; sec=1;
for i=1:fps*sec
  camorbit(1,0);
  drawnow
end

end % showMesh
