% [xyz,uniqueTri]=drawPMFG3(A,labels)
% demo on how to draw the PMFG graph in three dimensions
% A is the PMFG's adjacency matrix (output of pmfg) 
% labels (optional) are the vertex labels to display
% xyz are the vetex coordinates 
% uniqueTri is the ordered (planar embedding) list of vertices for each
% triangle in the PMFG
function [xyz,uniqueTri]=drawPMFG3(A,labels)
if  full(sum(sum(A-A')~=0))==1
    fprintf('Adjacence matrix not symmetric!\n')
end
%%%%%%%%%%%%%%%%%
N = size(A,1);
if nargin < 2
    labels = {};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D represetation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the embedding
[is_planar , ~, EI]=boyer_myrvold_planarity_test(A);
if is_planar==0
    fprintf('the graph is not planar, it cannot be a PMFG!\n')
    return
end
n_n = sum(A~=0,2);
vertexList = nan(N,max(n_n));
triangleList = []; 
for i=1:N
    vv = EI.edge_order(EI.vp(i):(EI.vp(i+1)-1))';
    vertexList(i,1:length(vv)) = vv;
    k = 1:(length(vv)-1);
    triangleList=[triangleList;repmat(i,length(vv)-1,1),vv(k)',vv(k+1)';i vv(end) vv(1)]; 
end
[~,ia,ic] = unique(sort(triangleList')','rows');
uniqueTri = triangleList(ia,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find coordinates 3D
[xyz]=vertexpositions(A,3,vertexList,rand(N,3),A~=0,800,[0.2 2 2 10 3 0.9]);
close(300)
% final 3D figure
figure
col = colormap('jet'); 
col = col+0.5; %makes it whiter
clf
set(gcf,'Renderer','OpenGL');
p = patch('Faces',uniqueTri,'Vertices',xyz);
set(p,'FaceColor',[0 1 1],'FaceAlpha',0.5);
set(p,'EdgeColor',[0 1 1]*.4,'LineWidth',1,'EdgeAlpha',1);
view(3); 
axis square
box on
axis tight
hold on
if ~isempty(labels)
    text(xyz(:,1),xyz(:,2),xyz(:,3),labels,'fontsize',12); 
end
m = max(n_n)-min(n_n);
mm=min(n_n);
nc = size(col,1);
vert_cdata = col(ceil((n_n-mm)/m*(nc-1))+1,:);
set(p,'EdgeColor',[0 0 0],'LineWidth',1,'EdgeAlpha',1);
set(p,'FaceColor','interp','FaceVertexCData',vert_cdata,'FaceAlpha',0.4)
view(3)
axis square
box on
axis tight
camproj perspective; 
set(gca,'visible','off','box','off')
camlight left;
lighting flat
material metal 
set(p,'FaceLighting','flat','AmbientStrength',.8,'DiffuseStrength',.8,'SpecularStrength',.9,'SpecularExponent',19,'BackFaceLighting','unlit')

