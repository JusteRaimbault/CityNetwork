% [xyz]=vertexpositions(A,d)
% find the coordinates to display a network defined by the NxN adjacency matrix A
% d is the space dimensionality (2 or 3 normally)

% [xyz]=vertexpositions(A,d,vertexList)
% vertexList is the oriented list of vertices -if d=3 and if the network embedding is known it should be empty otherwise

% [xyz]=vertexpositions(A,d,vertexList,xyz)
% xyz previous vetex coordinates - incermental 

% [xyz]=vertexpositions(A,d,vertexList,xyz,dx)
% dx NxN matrix of desired distances between the connected vertices

% [xyz]=vertexpositions(A,d,vertexList,xyz,dx,maxLoop)
% maxLoop number of relaxation loops 

% [xyz]=vertexpositions(A,d,vertexList,xyz,dx,maxLoop,parameters)
% parameters 1x5 scalars for the dynamical relaxation

function [xyz]=vertexpositions(A,d,vertexList,xyz,dx,maxLoop,parameters,vis)
N = size(A,1);
if nargin < 8
    vis = 1; % visulaization on
    if nargin < 7
        parameters=[1 1 1 1 1 0.9]; % default parameters
        if nargin < 6
            maxLoop = 100;
            if nargin < 5
                dx = A~=0; % rest length = 1
                if nargin < 4
                    xyz = rand(N,d); % start from random positions
                    if nargin < 3 % if embedding (3D only) is unknown 
                        vertexList = []; % leave vertexList empty
                    end
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rescale parameters
kh   = parameters(1)*0.00001;
qr   = parameters(2)*0.01;
pres = parameters(3)*0.01;
grav = parameters(4)*0.001;
expon= parameters(5);
damping= parameters(6);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find coordinates 
v = zeros(N,d);
[i,j]  = find(A);
[~, p] = sort(max(i,j));
i = i(p);
j = j(p);
tic
t=0;
nor = zeros(N,d);
while (t<maxLoop)
    t=t+1;
    for h=1:N
        c = xyz(h,:);
        if~isempty(vertexList) 
            k = find(~isnan(vertexList(h,:))); 
            rx = zeros(length(k),d);
        end
        for n=1:d 
            r(:,n) = [c(n)-xyz(:,n)]; 
            if~isempty(vertexList), rx(:,n) = xyz(vertexList(h,k),n)-c(n);end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% compute forces %%%%%%
        % pressure (3D only) if embedding is provided
        f=zeros(1,d);
        if ~isempty(vertexList) && d==3 %if embedding (3D only) is unknown
            %pressure
            %% compute normals to vertex
            nx=sum(cross(rx(1:(end-1),:),rx(2:end,:)),1);
            nx = nx/sum(nx.^2)^.5;
            nor(h,:)=nx;
            f = pres*nor(h,:);
        end
        % coulomb repulsion
        d2 = sum(r.^2,2);
        fr = r./repmat(d2,1,d);
        fr(isnan(fr))=0;
        f = qr*sum(fr)+f;
        % non-linear spring attraction with rest length
        d1 = sqrt(d2(A(h,:)~=0));
        dd = dx(h,A(h,:)~=0)';
        f = f - kh*sum(r(A(h,:)~=0,:)./repmat(d1,1,d).*repmat(sign(d1-dd),1,d).*repmat(abs(d1-dd).^expon,1,d),1);
        % gravity
        f = f-grav*xyz(h,:)/sqrt(sum(xyz(h,:).^2));
        %%%%%% new veocity %%%%%%
        v(h,:) = v(h,:)*damping + f;
        %%%%%% new position %%%%%%
        xyz(h,:) = c + v(h,:);
        xyz(h,isnan(xyz(h,:)))=rand(1,sum(isnan(xyz(h,:))));
    end
    if (d==2 || d==3) && vis==1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %visualize relaxation
        figure(100*d)
        clf
        X = [ xyz(i,1) xyz(j,1) NaN(size(i))]';
        Y = [ xyz(i,2) xyz(j,2) NaN(size(i))]';
        if d==2
           plot(X(:),Y(:))
        else
            Z = [ xyz(i,3) xyz(j,3) NaN(size(i))]';
            plot3(X(:),Y(:),Z(:))
            view(3); 
            camproj perspective; 
        end       
        axis square
        box on
        axis tight
    end
end

