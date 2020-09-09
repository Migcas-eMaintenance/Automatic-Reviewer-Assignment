function [PaperOrder,Q,Qhist]=OPEAconvex(W,P,V,varargin)
% assignreviewers allocates reviewers to papers based on keywords using the
% OPEA
%
% [PaperOrder,Q,Qhist]=assignreviewers(W,P,V) returns a set of indexes
% named PaperOrder, such that PaperORder(i) is the index of the paper
% assigned to reviewer i.
%
% [PaperOrder,Q,Qhist]=assignreviewers(W,P,V,npapers) assigns the number
% of papers "npapers" to each reviewer.
%
% The inputs to the function are:
%   - W: Authorship matrix. If the j-th author is an author of the i-th
%       paper, then W(i,j)=1. Otherwise W(i,j)=0.
%   - P: Paper/Keyword Matrix. Binary matrix such that P(i,j)= 1 if
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


K=P'*W;
C=P*K;
Chat=-C;
C(V==0)=0;
Chat(V==0)=Inf;
if nargin==3
    npapers=1;
elseif nargin==4
    npapers=varargin{1};
end

for n=1:npapers
    authorRandIndx=randperm(size(W,2));
    
    moreauthors=1;
    startauthors=1;
    nauthorsleft=size(Chat,2);
    m=size(Chat,1);
    
    ctproblems=1;
    while moreauthors==1
        if m<nauthorsleft
            [Csol{ctproblems},Tsol(ctproblems)]=...
                hungarian(Chat(:,authorRandIndx(startauthors:startauthors+m-1))); %#ok<AGROW>
            startauthors=startauthors+m;
            nauthorsleft=size(Chat,2)-startauthors+1;
        else
            [Csol{ctproblems},Tsol(ctproblems)]= ...
                hungarian([Chat(:,authorRandIndx(startauthors:end)),...
                zeros(size(C,1),size(C,1)-length(authorRandIndx(startauthors:end))) ]); %#ok<AGROW>
            aux=Csol{ctproblems};
            aux=aux(1:nauthorsleft);
            Csol{ctproblems}=aux; %#ok<AGROW>
            moreauthors=0;
        end
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
        nkeywords=C(PaperOrder(ct),ct);
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
    Chat(V==0)=Inf;
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


