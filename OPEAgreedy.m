function [Paperorder,Q,Qhist]=OPEAgreedy(W,P,V)
% assigngreedy allocates reviewers to papers based on keywords and using a
% greedy algorithm
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

% K: Author's Keyword Expertise Matrix
K=P'*W;

% C: Cost matrix
C=P*K;
% Set to -infinity the cost to assign a vetoed reviewer to a paper
C(V==0)=-Inf;
% Vertical replication of the cost matrix C until there are more papers
% than authors
C=kron( C,ones(ceil(size(C,2)/size(C,1)),1) );

% Prelocation of assingment solution
Paperorder=zeros(1,size(C,2));
% Inicialization of the performance measure
Q=0;

% Lopp as many times as the number of reviewers and: 
%   1) Assign at each iteration  a reviewer-paper pair with the maximum cost. 
%   2) Substitute by -infinity all the costs in the row and column
%   associated to the assigned paper and reviewer respectively. 
for ct=1:size(C,2)
     value=max(max(C));
     [x,y]=find(C==value);
     ind=randperm(length(x));
    Paperorder(y(ind(1)))=x(ind(1)); 
    Q=Q+C(x(ind(1)),y(ind(1)));
    nkeywords=C(x(ind(1)),y(ind(1)));
   try
    Qhist(nkeywords+1)=Qhist(nkeywords+1)+1; %#ok<AGROW>
   catch
        try 
     Qhist(nkeywords+1)=1;      %#ok<AGROW>
        catch
          Paperorder=-1*ones(1,size(W,2));
          Q=-1;
          Qhist=-1;
          return
        end
   end
   C(x(ind(1)),:)=-Inf;
    C(:,y(ind(1)))=-Inf;
end

still=1;
while still
    still=0;
    for ct=1:length(Paperorder)
        if Paperorder(ct)>size(W,1)
            Paperorder(ct)=Paperorder(ct)-size(W,1);
            still=1;
        end
    end
end

