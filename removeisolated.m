function [W,P,V,papers]=removeisolated(W,P,V,papers)
% Removes from the problem isolated papers. 
% Inputs: 
%   - W: Authorship matrix. If the j-th author is an author of the i-th 
%       paper, then W(i,j)=1. Otherwise W(i,j)=0. 
%   - P: Paper/Keyword Matrix. Binary matrix such that P(i,j)= 1 if 
%       the j-th kweyword is present in the i-th paper. P(i,j)=0 otherwise.
%   - V: Veto binary matrix. If V(i,j)=0 then the
%       j-th author is veteoed to review the i-th paper. 
%   - papers: cell array with the names/identities of the papers
% Outputs: The outputs are modified versions of the inputs where the
% inexpert authors are removed

%  v1.0  May 2020. Miguel Castano Arranz, miguel.castano@ltu.se
%                 Division of Operation and Maintenance, 
%                 Lulea University of Technology, Sweden 

K=P'*W;
C=P*K;
C(V==0)=0;
isolatedindex=find(sum(C)==0);
W(isolatedindex,:)=[];
P(isolatedindex,:)=[];
V(isolatedindex,:)=[];
papers(isolatedindex)=[];