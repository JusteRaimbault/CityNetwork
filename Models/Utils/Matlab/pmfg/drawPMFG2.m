% [xyz,uniqueTri]=drawPMFG2(A,labels)
% demo on how to draw the PMFG graph in two dimensions
% A is the PMFG's adjacency matrix (output of pmfg) 
% labels (optional) are the vertex labels to display
% xyz are the vetex coordinates 
% uniqueTri is the ordered (planar embedding) list of vertices for each
% triangle in the PMFG
function [xyz,uniqueTri]=drawPMFG2(A,labels)
if  full(sum(sum(A-A')~=0))==1
    fprintf('Adjacence matrix not symmetric!\n')
end
%%%%%%%%%%%%%%%%%
N = size(A,1);
if nargin < 2
    labels = {};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2D 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find coordinates 2D
xyz = rand(N,2);
[xyz]=vertexpositions(A,2,[],xyz,A~=0,500,[0.2 2 1 10 3 0.9]);
close(200)
% final 2D figure
figure
clf
[i,j]  = find(A);
[~, p] = sort(max(i,j));
i = i(p);
j = j(p);
X = [ xyz(i,1) xyz(j,1) NaN(size(i))]';
Y = [ xyz(i,2) xyz(j,2) NaN(size(i))]';
plot(X(:),Y(:),'-b')
axis square
box on
axis tight
hold on
if ~isempty(labels)
    text(xyz(:,1),xyz(:,2),labels,'fontsize',12); 
end
set(gca,'visible','off','box','off')