function geometry()
% Function geometry(Object) - Transformation of the geometry data from
% elements and nodes to areas and surface normals on center points
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

% ... written by Hans Zais
% ... modified by Haike Brick, 21.06.02

global obj

% modelfile= [TEMPdir,'element_neu.mat'];
[R,C]=size(obj.mesh.elements);% R:rows, C:columns
Nnodes=length(obj.mesh.nodes(:,1));

Ntri=0; Nquad=0;
elemT=[]; elemQ =[];
centreT = []; centreQ = [];
normT = []; normQ = [];
normabsT = []; normabsQ = [];
xyzT = []; xyzQ = [];

% ... Erstellen der Matritzen elemT(enthält dreieckigen elements) und
% ... elemQ (enthält die rechteckigen elements der Geometrie)
if C==3
    indexT = [1:Ne]';
    indexQ = [];
    Ntri=R;
    elemT=obj.mesh.elements';
    %    save(modelfile,'elements','nodes','Ntri','Nquad');
else
    indexT = find( obj.mesh.elements(:,3) == obj.mesh.elements(:,4) );
    Ntri = length(indexT);
    for i = 1 : Ntri
        elemT(:,i) = obj.mesh.elements(indexT(i),:)';
    end
    indexQ = find( obj.mesh.elements(:,3) ~= obj.mesh.elements(:,4) );
    Nquad = length(indexQ);
    for i = 1 : Nquad
        elemQ(:,i) = obj.mesh.elements(indexQ(i),:)';
    end
end
%save(modelfile,'elements','nodes','Ntri','Nquad');  %for i=1:m

clear m n i
%--------------------------------------------------------------------------%

% ... rechteckige und dreieckige elements
% ... Defining of the matrices xxT, yyT, zzT
% ... xxT, yyT, zzT represent the x-, y-, z-coordinates of the nodes
% ... accordingly to the node-element combination given by
% ... matrix elements

if isempty(elemT) == 0
    xxT=obj.mesh.nodes(elemT);
    yyT=obj.mesh.nodes(elemT+Nnodes*ones(size(elemT)));
    zzT=obj.mesh.nodes(elemT+2*Nnodes*ones(size(elemT)));
    xyzT = zeros(3, Ntri, 3);
    xyzT(:,:,1) = xxT(1:3,:);
    clear xxT
    xyzT(:,:,2) = yyT(1:3,:);
    clear yyT
    xyzT(:,:,3) = zzT(1:3,:);
    clear zzT

    % ... Calculation of the centroids
    xm=sum(xyzT(:,:,1))/3; ym=sum(xyzT(:,:,2))/3; zm=sum(xyzT(:,:,3))/3;
    centreT = [xm; ym; zm];
    clear xm ym zm;

    a=[xyzT(2,:,1)-xyzT(1,:,1) ; xyzT(2,:,2)-xyzT(1,:,2) ; xyzT(2,:,3)-xyzT(1,:,3)];
    b=[xyzT(3,:,1)-xyzT(1,:,1) ; xyzT(3,:,2)-xyzT(1,:,2) ; xyzT(3,:,3)-xyzT(1,:,3)];

    % ... the normal vector is the cross product of a and b, divided by 2
    normT=cross(a,b) ./ 2;
    clear a b;

    % ... absolute value of the normal vectors, which represents the area of the elements:
    normabsT = sqrt(sum((normT .^ 2)));
    normT = normT ./ repmat(normabsT, [3, 1]);
end
if isempty(elemQ) == 0
    %--------------------------------------------------------%
    % ... rechteckige elements werden in 2 dreieckige elements zerlegt:
    % ... Seien n1,n2,n3,n4 die Knoten eines elementss
    % ... dann erhält man daraus folgende dreickige elements:
    % ... n1,n2,n3
    % ... n1,n3,n4:
    Tri=[elemQ(1:3, :) [elemQ(1,:); elemQ(3:4, :)]];

    % ... Defining of the matrices xxQ, yyQ, zzQ
    % ... xxQ, yyQ, zzQ represent the x-, y-, z-coordinates of the nodes
    % ... accordingly to the node-element combination given by
    % ... matrix Tri

    xxQ=obj.mesh.nodes(Tri);
    yyQ=obj.mesh.nodes(Tri+Nnodes*ones(size(Tri)));
    zzQ=obj.mesh.nodes(Tri+2*Nnodes*ones(size(Tri)));

    % ... Calculation of the centroids of each triangle
    xm=sum(xxQ)/3;
    ym=sum(yyQ)/3;
    zm=sum(zzQ)/3;

    % ... Calculation of the normal vector of each triangle as the cross product
    % ... a: vector between node(1) und node(2) of each triangle
    % ... b: vector between node(1) und node(3) of each triangle

    a=[xxQ(1,:)-xxQ(2,:); yyQ(1,:)-yyQ(2,:); zzQ(1,:)-zzQ(2,:)];
    b=[xxQ(1,:)-xxQ(3,:); yyQ(1,:)-yyQ(3,:); zzQ(1,:)-zzQ(3,:)];
    normTri=cross(a,b) ./ 2;
    clear a b xxQ yyQ zzQ;

    % ... absolute value of the normal vectors:
    normabsTri = sqrt(sum((normTri.^2)));

    % ... Calculation of the normal vectors of the rectangular elements from the normal vectors
    % ... of the triangular elements:
    normElem = normTri(:,1:Nquad) + normTri(:, Nquad+1: 2*Nquad,:);
    normabsElem = sqrt(sum((normElem.^2)));

    % ... Calculation of the centroids of the rectangular elements:
    xmElem=(xm(1:Nquad) .* normabsTri(1:Nquad) + xm(Nquad+1:2*Nquad) .* normabsTri(Nquad+1:2*Nquad)) ./ normabsElem;
    ymElem=(ym(1:Nquad) .* normabsTri(1:Nquad) + ym(Nquad+1:2*Nquad) .* normabsTri(Nquad+1:2*Nquad)) ./ normabsElem;
    zmElem=(zm(1:Nquad) .* normabsTri(1:Nquad) + zm(Nquad+1:2*Nquad) .* normabsTri(Nquad+1:2*Nquad)) ./ normabsElem;
    clear normTri normabsTri xm ym  zm;

    centreQ=[xmElem; ymElem; zmElem];
    normabsQ=normabsElem;
    normQ = normElem ./ repmat(normabsQ, [3, 1]);

    xxQ=obj.mesh.nodes(elemQ);
    yyQ=obj.mesh.nodes(elemQ+Nnodes*ones(size(elemQ)));
    zzQ=obj.mesh.nodes(elemQ+2*Nnodes*ones(size(elemQ)));
    xyzQ = zeros(4, Nquad, 3);
    xyzQ(:,:,1) = xxQ;
    xyzQ(:,:,2) = yyQ;
    xyzQ(:,:,3) = zzQ;
end

if isempty(indexT) == 0
    centre(:,indexT) = centreT;
    normabs(indexT) = normabsT;
    norma(:,indexT) = normT;
end

if isempty(indexQ) == 0
    centre(:,indexQ) = centreQ;
    normabs(indexQ) = normabsQ;
    norma(:,indexQ) = normQ;
end
obj.mesh.centre=centre';
obj.mesh.area=normabs;
obj.mesh.norma=norma';
% Micha wozu: indexT,indexQ
end % geometry