%  calculates the PMFG graph from a matrix of weights W (typically a similarity measure, e.g. correlations) 
%  PMFG = doPMFG(W) returns the palnar maximally filtered  graph (PMFG)   
%  PMFG is a sparse matrix with PMFG(i,j)=W(i,j) if the edge i-j is present
%  and PMFG(i,j)=0 if not
%  W must be sparse, real, square and symmetric
%
%  Tomaso Aste
%  UCL Computer Science
%
%  This function uses "matlab_bgl" package from 
%  http://www.mathworks.com/matlabcentral/fileexchange/10922
%  and
%  http://www.stanford.edu/~Edgleich/programs/matlab_bgl/
%  which must be installed
%--------------------------------------------------------------------------
% Please refer to:
%
% T. Aste, T. Di Matteo and S. T. Hyde, 
% Complex Networks on Hyperbolic Surfaces, 
% Physica A 346 (2005) 20-26. 
%
% M. Tumminello, T. Aste, T. Di Matteo, R.N. Mantegna, 
% A tool for filtering information in complex systems, 
% Proceedings of the National Academy of Sciences of the United States 
% of America (PNAS) 102 (2005) 10421-10426. 
%
% in your published research.
%--------------------------------------------------------------------------
function PMFG = pmfg(W)
if size(W,1)~=size(W,2)
    fprintf('W must be square \n');
    PMFG =[];
    return
end
if ~isreal(W)
    fprintf('W must be real \n');
    PMFG =[];
    return
end
if any(any(W-W'))
    fprintf('W must be symmeric \n');
    PMFG =[];
    return
end
if ~issparse(W)
    W = sparse(W);
end
N = size(W,1);
if N == 1
    PMFG = sparse(1);
    return
end
[i,j,w] = find(sparse(W));
kk = find(i < j);
ijw= [i(kk),j(kk),w(kk)];
ijw = -sortrows(-ijw,3); %make a sorted list of edges (largest first)
PMFG = sparse(N,N);
clu(1:N)=[1:N];
for ii =1:min(6,size(ijw,1)) % the first 6 edges from the list can be always inserted
    PMFG(ijw(ii,1),ijw(ii,2)) = ijw(ii,3);
    PMFG(ijw(ii,2),ijw(ii,1)) = ijw(ii,3);
    m=max(clu)+1;
    clu( clu==clu(ijw(ii,1)) )=m; %assign cluster index
    clu( clu==clu(ijw(ii,2)) )=m;    
end
E = 6; % number of edges in PMFG at this stage
PMFG1 = PMFG;
while( E < 3*(N-2) ) % continue while all edges for a maximal planar graph are inserted
    ii = ii+1;
    PMFG1(ijw(ii,1),ijw(ii,2))=ijw(ii,3); % try to insert the next edge from the sorted list
    PMFG1(ijw(ii,2),ijw(ii,1))=ijw(ii,3); % insert its reciprocal
    if clu(ijw(ii,1))~=clu(ijw(ii,2)) % is the new link is between different clusters?
         PMFG = PMFG1; % Yes: insert the edge in PMFG
         E = E+1;
         m=max(clu)+1;
         clu( clu==clu(ijw(ii,1)) )=m;
         clu( clu==clu(ijw(ii,2)) )=m;
    else % NO: the new link is within the same cluster
        k = find(clu==clu(ijw(ii,1)));
        if boyer_myrvold_planarity_test(PMFG1(k,k)~=0) % is the resulting graph planar?
            PMFG = PMFG1; % Yes: insert the edge in PMFG
            E = E+1;
        else
            PMFG1 = PMFG; % No: discard the edge
        end
    end
    if ~mod(ii,1000); 
        fprintf('Build PMFG: %d    :   %2.2f per-cent done, clusters %d\n',ii,E/(3*(N-2))*100,length(unique(clu)));
        if ii > (N*(N-1)/2)
            fprintf('PMFG not found \n')
            return
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% to plot, you can use 
% drawPMFG2(PMFG) % 2D
% or 
% drawPMFG3(PMFG) % 3D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%