function mkGH()           
% Function mkGH(Object) - Make BEM matrices G and H
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

    disp('calculating matrices of surface structure')
    % ratio - schaetzung der Einträge je Element zur Speicherallokation

    R=zeros(1,obj.mesh.Ne);
    for n=1:obj.mesh.Ne    %Innenradius jedes elementss berechnen         %OLAF: vlt besser: sqrt(abs(a*a'))
        if obj.mesh.elements(n,1)==obj.mesh.elements(n,4) % wenn Dreieck
            A=sqrt(dot(obj.mesh.nodes(obj.mesh.elements(n,2),:)-obj.mesh.nodes(obj.mesh.elements(n,1),:),obj.mesh.nodes(obj.mesh.elements(n,2),:)-obj.mesh.nodes(obj.mesh.elements(n,1),:)));
            B=sqrt(dot(obj.mesh.nodes(obj.mesh.elements(n,3),:)-obj.mesh.nodes(obj.mesh.elements(n,2),:),obj.mesh.nodes(obj.mesh.elements(n,3),:)-obj.mesh.nodes(obj.mesh.elements(n,2),:)));
            C=sqrt(dot(obj.mesh.nodes(obj.mesh.elements(n,1),:)-obj.mesh.nodes(obj.mesh.elements(n,3),:),obj.mesh.nodes(obj.mesh.elements(n,1),:)-obj.mesh.nodes(obj.mesh.elements(n,3),:)));
            R(n)=2*obj.mesh.area(n)/(A+B+C);
        else  % ansonsten Viereck
            %R=sqrt(area(n)/pi);
            R(n)=find_minR(obj.mesh.nodes(obj.mesh.elements(n,1),:),obj.mesh.nodes(obj.mesh.elements(n,2),:),obj.mesh.nodes(obj.mesh.elements(n,3),:),...
                obj.mesh.nodes(obj.mesh.elements(n,4),:),obj.mesh.centre(n,:));
        end
    end

    %%%%%% Matrizen G und H erstellen für alle Zeitschritte

    [eps_var,w] = gausslegendre(obj.gausspts);             
    [Wi, Wj]=meshgrid(w);
    Wij=Wi.*Wj;     

    % Speicherallokation
    abs_norm=zeros(obj.gausspts,obj.gausspts);
    pe=zeros([obj.gausspts obj.gausspts 3]);
    gsp=zeros(obj.ratio*obj.mesh.Ne^2,3);
    hsp=zeros(obj.ratio*obj.mesh.Ne^2,3);

    Hzeiger=1; %naechster freier Eintrag
    Gzeiger=1;
    progressbar
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
        %alle Kollokationspunkte
        for ncol=1:obj.mesh.Ne
            if ncol==nel % singular
                if R(ncol)>obj.c*obj.dt
                    Rsing=obj.c*obj.dt;
                else
                    Rsing=R(ncol);
                end
                col_tmp(1,1,:)=obj.mesh.centre(ncol,:);
                M_el=repmat(col_tmp,[obj.gausspts obj.gausspts 1]);
                rm=M_el-pe;% Abstand der Gausspunkte zum Mittelpunkt
                r=sqrt(dot(rm,rm,3));
                IG=(1./r).*abs_norm.*Wij;
                IG(r<=Rsing)=0; % diese Flaeche wurde schon analytisch integriert
                my=ceil(r./obj.c/obj.dt);
                mymx=max(max(my));
                gsp(Gzeiger,:)=[nel, nel, 2*pi*Rsing+sum(sum(IG(my==1)))];
                Gzeiger=Gzeiger+1;
                for nmy=2:mymx
                    gsp(Gzeiger,:)=[ncol, obj.mesh.Ne*(nmy-1)+nel, sum(sum(IG(my==nmy)))];
                    Gzeiger=Gzeiger+1;
                end
            else
                col_tmp(1,1,:)=obj.mesh.centre(ncol,:);
                M_el=repmat(col_tmp,[obj.gausspts obj.gausspts 1]);
                rm=M_el-pe;% Abstand der Gausspunkte zum Mittelpunkt
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
        end
        progressbar((obj.mesh.Ne*(nel))/obj.mesh.Ne^2)
    end
    % close(hwait)
    ind1 = find(gsp(:,1), 1, 'last');
    % gsp(ind+1:end,:)=[];
    ind2 = find(hsp(:,1), 1, 'last');
    % hsp(ind+1:end,:)=[];
    mymax=ceil(max(gsp(1:ind1,2))/obj.mesh.Ne);
    obj.mesh.G= sparse(gsp(1:ind1,1),gsp(1:ind1,2),gsp(1:ind1,3),obj.mesh.Ne,obj.mesh.Ne*mymax);
    obj.mic.G=''; % sinnvoll vorgeben!!
    clear gsp
    obj.mesh.H= sparse(hsp(1:ind2,1),hsp(1:ind2,2),hsp(1:ind2,3),obj.mesh.Ne,obj.mesh.Ne*mymax);
    obj.mic.G=''; % sinnvoll vorgeben!!
    clear hsp
    obj.ratio=nnz(obj.mic.G)/obj.mesh.Ne^2;
    obj.mesh.H=mat2cell(obj.mesh.H, obj.mesh.Ne, obj.mesh.Ne*ones(mymax,1));
    obj.mesh.G=mat2cell(obj.mesh.G, obj.mesh.Ne, obj.mesh.Ne*ones(mymax,1));
    obj.mesh.mymax=mymax;           
    % Warning noch aendern!!
    if obj.ratio>4
        warning([num2str(obj.ratio) ' :Average number of time steps per element to big (max=4)! Refine mesh or increase time step!'])
    end
end % mkGH