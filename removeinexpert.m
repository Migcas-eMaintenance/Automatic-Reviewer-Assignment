function [W,V,author]=removeinexpert(W,P,V,author)
% Removes from the problem authors without expertise in reviewing any
% conference paper. 
% Inputs: 
%   - W: Authorship matrix. If the j-th author is an author of the i-th 
%       paper, then W(i,j)=1. Otherwise W(i,j)=0. 
%   - P: Paper/Keyword Matrix. Binary matrix such that P(i,j)= 1 if 
%       the j-th kweyword is present in the i-th paper. P(i,j)=0 otherwise.
%   - V: Veto binary matrix. If V(i,j)=0 then the j-th author is vetoed 
%       to review the i-th paper. 
%   - author: cell array with the names of all the authors 
%
% Outputs: The outputs are modified versions of the inputs where the
% inexpert authors are removed

%  v1.0  May 2020. Miguel Castano Arranz, miguel.castano@ltu.se
%                 Division of Operation and Maintenance, 
%                 Lulea University of Technology, Sweden 

K=P'*W;
C=P*K;
C(V==0)=0;
inexpertindex=find(sum(C)==0);
W(:,inexpertindex)=[];
V(:,inexpertindex)=[];
author(inexpertindex)=[];
