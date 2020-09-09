function [PaperOrder,Q,Qhist]=OPEA_CES(W,P,V,varargin)
% assignreviewers allocates reviewers to papers based on keywords using the
% OPEA-CES method
%
% [PaperOrder,Q,Qhist]=OPEA_CES(W,P,V) returns a set of indexes
% named PaperOrder, such that PaperORder(i) is the index of the paper
% assigned to reviewer i.
%
% [PaperOrder,Q,Qhist]=OPEA_CES(W,P,V,npapers) assigns the number
% of papers "npapers" to each reviewer.
%
% The inputs to the function are:
%   - W: Authorship matrix. If the j-th author is an author of the i-th
%       paper, then W(i,j)=1. Otherwise W(i,j)=0.
%   - P: Keyword/Paper Matrix. Binary matrix such that P(i,j)= 1 if
%       the j-th kweyword is present in the i-th paper. P(i,j)=0 otherwise.
%   - V: Veto Matrix. If V(i,j)=0 then the j-th author is vetoed to review
%   the i-th paper. This can be used for example to reflect conflicts of
%   interest. 
%   - author: cell array with the names of all the authors
%   - npapers: number of papers to assign to reviewers (default 1)
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
%   Note: in the paper "Automatic assignment of reviewers in  peer reviewed
%   conferences" the assignment solution is given in terms of a binary
%   Matrix "A". PaperOrder(i) is the column index in row i where a 1 is
%   located. In other words: A(i,PaperOrder(i))=1.
%
%  v1.0  May 2020. Miguel Castano Arranz, miguel.castano@ltu.se
%                 Department of Operation and Maintenance,
%                 Lulea University, Sweden

% Author's Keyword Expertise Matrix
K=P'*W;

% Author's Paper Expertise Matrix
E=P*K;

% Cost matrix for minimization obtained by combining negative E and adding
% Infinity cost to the vetoed reviews represented in V
C=-E;
C(V==0)=Inf;

E(V==0)=0;

% Obtain from the inputs the number of papers which will be assigned to
% each reviewer
if nargin==3
    npapers=1;
elseif nargin==4
    npapers=varargin{1};
end


% loop to resolve OPEA-CES as many times as the number of papers assigned
% to each reviewer. The veto matrix is changed between iterations in order
% to prevent papers to be assigned twice to the same reviewer. 
for n=1:npapers
    % index to randomize the order of the author set
    authorRandIndx=randperm(size(W,2)); 
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
    
    % Csol is the for each column, the selected row. That is, for each author,
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


