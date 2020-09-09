% Code to run the case study in [1]
%
% This code is divided in the following sections: 
%   1.- Obtain the data needed to resolve the assignment 
%   2.- Calling to the function which assigns reviewers to papers
%   3.- Calling to the function which reports the results in a text file
%
%  v1.0  May 2020. Miguel Castano Arranz, miguel.castano@ltu.se
%                 Division of Operation and Maintenance, 
%                 Lulea University of Technology, Sweden 
%
% [1]: "Automatic assignment of reviewers in peer reviewed conferences",
% subbmitted to Epert Systems (May2020)


%% 1.- Obtain the data needed to resolve the assignment: 
% 1.a) Call to the script parseCDC2019 which parses the program 
% from the conference CDC 2019. After executing parseCDC2019, the following
% variables are obtained:
%   - authorSet: cell array with the names of all the authors
%   - papernSet: cell array with the ID of each paper
%   - kwSet: cell array with all the keywords
%   - W: Authorship matrix. If author{j} is an author of paper{i}, then
%       W(i,j)=1. Otherwise W(i,j)=0. 
%   - P: Paper/Keyword Matrix. Binary matrix such that P(i,j)= 1 if 
%       keyword{j} is present in paper{i}. P(i,j)=0 otherwise.
parseCDC2019;

% 1.b) The Veto Matrix is initialized in such way that 
% authors cannot review their own paper neither papers of their co-authors
% see [1].
V=((W*W')*W)==0; 

%% 2.- Pre-processing of the data
% Remove inexpert authors (see [1])
[W,V,authorSet]=removeinexpert(W,P,V,authorSet);
% Remove isolated papers (see [1])
[W,P,V,paperSet]=removeisolated(W,P,V,paperSet);

%% 3.- Runs an optimization scheme to assign reviewers
% Call to the assignreviewers function which runs convex RAP-OPER
[PaperOrder,Q,Qhist]=OPEAconvex(W,P,V);
% Alternatively you can use the greedy RAP-OPER as baseline
%[PaperOrder,Q,Qhist]=OPEAgreedy(W,P,V);

% If you want to assign more than one paper to each reviewer, you can call
% the OPEAconvex function with an extra input argument, e.g.: 
%[PaperOrder,Q,Qhist]=OPEAconvex(W,P,V,2); % to assign 2 papers per reviewer
%[PaperOrder,Q,Qhist]=OPEAconvex(W,P,V,3); % to assign 3 papers per reviewer



%% 
% 4.-Call to the function for printing the result in a text file
printAssignment(authorSet,paperSet,kwSEet,W,P,PaperOrder,...
'AssignmentResult.txt');