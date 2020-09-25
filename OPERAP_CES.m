function [PaperOrder,Q,Qhist]=OPERAP_CES(E,V,varargin)
% [PaperOrder,Q,Qhist]=OPERAP_CES(E,V)  allocates reviewers to papers based
% based on the Expertise Matrix E and Veto Matrix V. The allocation is
% performed by the Expert System introduced in SEction 4 in [1].
%
% The inputs are: 
%   - E. Expertise matrix where E(i,j) quantifies the expertise of 
% reviewer j in the domain of the paper i. 
%   - V is a binary Veto matris such that if V(i,j)=1 then reviewer j is
% not allowed to review paper i.  
%
% The ourpurs of the function are:
%   - PaperOrder is a set of indexes such that PaperORder(:,i) are the
%       indexes of the paper assigned to i-th author for reviewing.
%   - Q is the quality index of the assignment. Q is the total number of
%       times that the authors have used keywords in their own submissions
%       which are also present in the paper they were assigned to review.
%   - Qhist is the histogram with the author's expertise score on the paper
%       they have been assigned to review. Qhist(i) is the number of times
%       that authors have been assigned to review a paper for which they
%       have an expertise score of i-1. Expertise score for an author is
%       the number of times they have used in their own publications
%       keywords which are also present in the paper they have been
%       assigned to review. Examples: i) an expertise score of 0 means that the
%       author has not used in his on publications any of the keywords
%       presenet in the paper that he/she has been assigned to review, ii)
%       an expertise score of 2 meand that the author has used 2 times in
%       his/her own publications a word which is also present in the paper
%       they have been assigned to revie.
%
%   [PaperOrder,Q,Qhist]=OPERAP_CES(E,V,Npaper) assigns Npapers to each 
%   reviewer. 
%
%   Note: in the paper [1]. the assignment solution is given in terms of a
%   binary Matrix "A". PaperOrder(i) is the column index in row i where a 1 
%   is located. In other words: A(i,PaperOrder(i))=1.
%
%  v2.0  September 2020. Miguel Castano Arranz, miguel.castano@ltu.se
%                        Department of Operation and Maintenance,
%                        Lulea University, Sweden
%  [1]: "Automatic assignment of reviewers in peer reviewed conferences",
% subbmitted to Epert Systems (September 2020)


% Cost matrix for minimization obtained by combining negative E and adding
% Infinity cost to the vetoed reviews represented in V
C=-E;
C(V==0)=Inf;
E(V==0)=0;

% Obtain from the inputs the number of papers which will be assigned to
% each reviewer
if nargin==2
    npapers=1;
elseif nargin==3
    npapers=varargin{1};
end


% loop to resolve the OPERAP-CES (see Section 4.1 in {1]) as many times as
% the number of papers assigned to each reviewer. The veto matrix is 
% changed between iterations in order to prevent papers to be assigned 
% twice to the same reviewer (see Section 6.2 in [1]). 
for n=1:npapers
   % index to randomize the order of the author set
    authorRandIndx=randperm(size(E,2)); 
   % binary flag to indicate that more authors have to be assigned by 
   % resolving more Assignment Problems (APs)
    moreauthors=1;   
    % counter with where to start assigning auhors in iterations of
    % subsequent APs
    startauthors=1;
    % number of authors left to assign a paper
    nauthorsleft=size(C,2);
    % total number of papers
    m=size(C,1);
    % counter with the nubmer of APs that has been resolved
    ctproblems=1;
    %loop for resolve each of the APs. It runs as long as there are more
    %reviewers to assign
    while moreauthors==1
        % if there are more authors (reviewerS) left than papers, then we assign all
        % the papers resulting in one paper for each reviewer
        if m<nauthorsleft
            [Csol{ctproblems},Tsol(ctproblems)]=...
                hungarian(C(:,authorRandIndx(startauthors:startauthors+m-1))); %#ok<AGROW>
            startauthors=startauthors+m;
            nauthorsleft=size(C,2)-startauthors+1;
            % if there are less authors(left) than papers, we have to
            % create "dummy" authors by padding columns on the cost matrix
            % with 0's until the cost matrix is square
        else
            [Csol{ctproblems},Tsol(ctproblems)]= ...
                hungarian([C(:,authorRandIndx(startauthors:end)),...
                zeros(size(E,1),size(E,1)-length(authorRandIndx(startauthors:end))) ]); %#ok<AGROW>
            aux=Csol{ctproblems};
            aux=aux(1:nauthorsleft);
            Csol{ctproblems}=aux; %#ok<AGROW>
            moreauthors=0;
        end
        % increase the counter with the nubmer of APs which have been
        % solved
        ctproblems=ctproblems+1;
    end
    
    % Csol is or each column, the selected row. That is, for each author,
    % the selected paper.
    
    PaperForAuthoraux=[];
    for ct=1:length(Csol)
        if ct~=length(Csol)
            PaperForAuthoraux=[PaperForAuthoraux,Csol{ct}];   %#ok<AGROW>
        else
            PaperForAuthoraux=[PaperForAuthoraux,Csol{end}];  %#ok<AGROW>
        end
    end
    [~,I]=sort(authorRandIndx);
    PaperOrder=PaperForAuthoraux(I);
    for ct=1:length(PaperOrder)
        nkeywords=E(PaperOrder(ct),ct);
        try
            Qhist(nkeywords+1)=Qhist(nkeywords+1)+1; %#ok<AGROW>
        catch
            Qhist(nkeywords+1)=1;      %#ok<AGROW>
        end
    end
    
    Q=-sum(Tsol);
    
    PaperOrderAux(n,:)=PaperOrder; %#ok<AGROW>
    QAux(n)=Q; %#ok<AGROW>
    QhistAux{n}=Qhist;   %#ok<AGROW>
  
    for ct=1:length(PaperOrder)
    V(PaperOrder(ct),ct)=0;
    end
    C(V==0)=Inf;
end

%%
PaperOrder=PaperOrderAux;
Q=sum(QAux);
nhist=cellfun('length',QhistAux);
Qhist=zeros(npapers,max(nhist));
for ct=1:npapers
    Qhist(ct,:)=[QhistAux{ct},zeros(1,max(nhist)-length(QhistAux{ct}))];
end
Qhist=sum(Qhist,1);


