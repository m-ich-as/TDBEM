function mkGHi()      
% Function mkGHi(Object) - Make BEM matrices G and H at the imission points
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

    % Matrizen G und H erstellen für alle Zeitschritte
    progressbar         %http://www.mathworks.com/matlabcentral/fileexchange/6922-progressbar
    [eps_var,w] = gausslegendre(obj.gausspts);

    [Wi, Wj]=meshgrid(w);
    Wij=Wi.*Wj;

    % Speicherallokation
    abs_norm=zeros(obj.gausspts,obj.gausspts);
    pe=zeros([obj.gausspts obj.gausspts 3]);
    gsp=zeros(ceil(obj.ratio)*obj.mesh.Ne*obj.mic.Ni,3);
    hsp=zeros(ceil(obj.ratio)*obj.mesh.Ne*obj.mic.Ni,3);
    Hzeiger=1; %naechter freier Eintrag
    Gzeiger=1;

    %alle elements
    for nel=1:obj.mesh.Ne
        %     M=centre(nx,:);
        p1=obj.mesh.nodes(obj.mesh.elements(nel,1),:);
        p2=obj.mesh.nodes(obj.mesh.elements(nel,2),:);
        p3=obj.mesh.nodes(obj.mesh.elements(nel,3),:);
        p4=obj.mesh.nodes(obj.mesh.elements(nel,4),:);
        if p1==p4
            p4=p3+(p1-p3)/2;
        end
        pa=1/4*(p1+p2+p3+p4);
        pb=1/4*(-p1+p2+p3-p4);
        pc=1/4*(-p1-p2+p3+p4);
        pd=1/4*(p1-p2+p3-p4);
        for i=1:obj.gausspts
            for j=1:obj.gausspts
                pe(i,j,:)=pa+pb*eps_var(i)+pc*eps_var(j)+pd*eps_var(i)*eps_var(j);
                norm=cross(pb+pd*eps_var(j),pc+pd*eps_var(i));
                abs_norm(i,j)=sqrt(dot(norm,norm));
            end
        end
        el_tmp(1,1,:)=obj.mesh.norma(nel,:);
        Norm_el=repmat(el_tmp,[obj.gausspts obj.gausspts 1]);
        %alle Immissionspunkte
        for ncol=1:obj.mic.Ni
            col_tmp(1,1,:)=obj.mic.nodes(ncol,:);%centre(ncol,:);
            M_col=repmat(col_tmp,[obj.gausspts obj.gausspts 1]);
            rm=M_col-pe;% Abstand der Gausspunkte zum Mittelpunkt
            r=sqrt(dot(rm,rm,3));
            drn=-dot(rm,Norm_el,3)./r;% bei grossen Abständen kann das noch vereinfacht werden
            IH=1./r.^2.*drn.*abs_norm.*Wij;
            IG=(1./r).*abs_norm.*Wij;
            my=ceil(r./obj.c/obj.dt);
            mymin=min(min(my));
            mymx=max(max(my));
            for nmy=mymin:mymx
                is_my=my==nmy;
                gsp(Gzeiger,:)=[ncol, obj.mesh.Ne*(nmy-1)+nel, sum(sum(IG(is_my)))];
                Gzeiger=Gzeiger+1;
                hsp(Hzeiger,:)=[ncol, obj.mesh.Ne*(nmy-1)+nel, sum(sum(IH(is_my)))];
                Hzeiger=Hzeiger+1;
            end
        end
        progressbar((obj.mesh.Ne*(nel))/obj.mesh.Ne^2)
    end

    ind = find(gsp(:,1), 1, 'last');
    gsp(ind+1:end,:)=[];
    ind = find(hsp(:,1), 1, 'last');
    hsp(ind+1:end,:)=[];
    mymax=ceil(max(gsp(:,2))/obj.mesh.Ne);
    obj.mic.G= sparse(gsp(:,1),gsp(:,2),gsp(:,3),obj.mic.Ni,obj.mesh.Ne*mymax);
    obj.mic.H= sparse(hsp(:,1),hsp(:,2),hsp(:,3),obj.mic.Ni,obj.mesh.Ne*mymax);            
    obj.mic.G=mat2cell(obj.mic.G, obj.mic.Ni, obj.mesh.Ne*ones(mymax,1));
    obj.mic.H=mat2cell(obj.mic.H, obj.mic.Ni, obj.mesh.Ne*ones(mymax,1));
    obj.mic.mymaxi=mymax;
    for n=1:obj.mic.mymaxi
        if nnz(obj.mesh.G{n})>0
            obj.mic.mys=n;
            break
        end
    end
end % mkGHi