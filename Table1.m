%% 
% Code to run the case study in "Automatic assignment of reviewers in 
% peer reviewed conferences", subbmitted to Epert Systems (May2020)
%
% This code is divided in the following sections: 
%   1.- Parsing the Author Index from the conference CDC2019
%   2.- Parsing the Keyword Index from the conference CDC2019
%   3.- Calling to the function which assigns reviewers to papers
%   4.- Calling to the function which reports the results in a text file
%
%  v1.0  May 2020. Miguel Castano Arranz, miguel.castano@ltu.se
%                 Division of Operation and Maintenance, 
%                 Lulea University of Technology, Sweden 

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
V=((W*W')*W)==0;

%% 2.- Pre-processing of the data
% Remove inexpert authors and isolated reviewers
[W,V,authorSet]=removeinexpert(W,P,V,authorSet);
[W,P,V,paperSet]=removeisolated(W,P,V,paperSet);



% This code can be used instead in step 3 to run 100 iterations and extract 
% some statistics. 
clear PaperOrderLP QLP QhistLP PaperOrderGreedy QGreedy QhistGreedy
ctiterations=1;
 niterations=100;
 for ct=1:niterations
     [PaperOrderLP(ct,:),QLP(ct),QhistLP{ct}]=OPEAconvex(W,P,V);
     [PaperOrderGreedy(ct,:),QGreedy(ct),QhistGreedy{ct}]=OPEAgreedy(W,P,V);
     sprintf('%d iterations left',400-ctiterations)
     ctiterations=ctiterations+1;
 end
 
 %%
 for ct=find(QGreedy==-1)
    [PaperOrderGreedy(ct,:),QGreedy(ct),QhistGreedy{ct}]=OPEAgreedy(W,P,V);
 end
 % 5.- Calculate some analytics
statLP=calculatestats(PaperOrderLP,W,P,QLP,QhistLP);
statGreedy=calculatestats(PaperOrderGreedy,W,P,QGreedy,QhistGreedy);

clear PaperOrderLPSQ QLPSQ QhistLPSQ PaperOrderGreedySQ QGreedySQ QhistGreedySQ
for ct=1:niterations
    raux=randperm(size(W,2));
    r(ct,:)=raux(1:size(W,1));
    [PaperOrderLPSQ(ct,:),QLPSQ(ct),QhistLPSQ{ct}]=OPEAconvex(W(:,r(ct,:)),P,V(:,r(ct,:)));
    [PaperOrderGreedySQ(ct,:),QGreedySQ(ct),QhistGreedySQ{ct}]=OPEAgreedy(W(:,r(ct,:)),P,V(:,r(ct,:)));
     sprintf('%d iterations left',300-ctiterations)
     ctiterations=ctiterations+1;
end

%%
while ~isempty(find(QGreedySQ==-1))
 for ct=find(QGreedySQ==-1)
    raux=randperm(size(W,2));
    r(ct,:)=raux(1:size(W,1));
   [PaperOrderGreedySQ(ct,:),QGreedySQ(ct),QhistGreedySQ{ct}]=OPEAgreedy(W(:,r(ct,:)),P,V(:,r(ct,:)));
 end
end

statLPSQ=calculatestats(PaperOrderLPSQ,W,P,QLPSQ,QhistLPSQ);
statGreedySQ=calculatestats(PaperOrderGreedySQ,W,P,QGreedySQ,QhistGreedySQ);
%%
clear PaperOrderLP2SQ QLP2SQ QhistLP2SQ PaperOrderGreedy2SQ QGreedy2SQ QhistGreedy2SQ
for ct=1:niterations
    raux=randperm(size(W,2));
    r2(ct,:)=raux(1:2*size(W,1));
    [PaperOrderLP2SQ(ct,:),QLP2SQ(ct),QhistLP2SQ{ct}]=OPEAconvex(W(:,r2(ct,:)),P,V(:,r2(ct,:)));
    [PaperOrderGreedy2SQ(ct,:),QGreedy2SQ(ct),QhistGreedy2SQ{ct}]=OPEAgreedy(W(:,r2(ct,:)),P,V(:,r2(ct,:)));
      sprintf('%d iterations left',400-ctiterations)
     ctiterations=ctiterations+1;
end

%%
while ~isempty(find(QGreedy2SQ==-1))
 for ct=find(QGreedy2SQ==-1)
    raux=randperm(size(W,2));
    r2(ct,:)=raux(1:2*size(W,1));
   [PaperOrderGreedy2SQ(ct,:),QGreedy2SQ(ct),QhistGreedy2SQ{ct}]=OPEAgreedy(W(:,r2(ct,:)),P,V(:,r2(ct,:)));
 end
end

statLP2SQ=calculatestats(PaperOrderLP2SQ,W,P,QLP2SQ,QhistLP2SQ);
statGreedy2SQ=calculatestats(PaperOrderGreedy2SQ,W,P,QGreedy2SQ,QhistGreedy2SQ);

 %%
 
 clear PaperOrderLPless QLPless QhistLPless PaperOrderGreedyless QGreedyless QhistGreedyless
for ct=1:niterations
    raux=randperm(size(W,2));
    rless(ct,:)=raux(1:331);
    [PaperOrderLPless(ct,:),QLPless(ct),QhistLPless{ct}]=OPEAconvex(W(:,rless(ct,:)),P,V(:,rless(ct,:)));
    [PaperOrderGreedyless(ct,:),QGreedyless(ct),QhistGreedyless{ct}]=OPEAgreedy(W(:,rless(ct,:)),P,V(:,rless(ct,:)));
      sprintf('%d iterations left',400-ctiterations)
     ctiterations=ctiterations+1;
end

while ~isempty(find(QGreedyless==-1))
 for ct=find(QGreedyless==-1)
    raux=randperm(size(W,2));
    rless(ct,:)=raux(1:331);
   [PaperOrderGreedyless(ct,:),QGreedyless(ct),QhistGreedyless{ct}]=OPEAgreedy(W(:,rless(ct,:)),P,V(:,rless(ct,:)));
 end
end

statLPless=calculatestats(PaperOrderLPless,W,P,QLP2SQ,QhistLPless);
statGreedyless=calculatestats(PaperOrderGreedyless,W,P,QGreedy2SQ,QhistGreedyless);
 %%
 
 % creating temporarry variables to avoid long code
 mG=statGreedy.papers.reviewsperpaper.mean;
 mLP= statLP.papers.reviewsperpaper.mean; 
 mGSQ=statGreedySQ.papers.reviewsperpaper.mean;
 mLPSQ= statLPSQ.papers.reviewsperpaper.mean; 
 mG2SQ=statGreedy2SQ.papers.reviewsperpaper.mean;
 mLP2SQ= statLP2SQ.papers.reviewsperpaper.mean;
  mGless=statGreedyless.papers.reviewsperpaper.mean;
 mLPless= statLPless.papers.reviewsperpaper.mean;
str=['\begin{tabular}{|c|c|c|c|c|c|c|c|c|}    indicator & LP (Case 1)  & Greedy (Case 1) & LP (Case 2)  & Greedy (Case 2) & LP (Case 3)  & Greedy (Case 3) & LP (Case 4)  & Greedy (Case 4)\\',...
    '$\sum_{i=1}^{100} Q_i$ ~(mean) & ', num2str(round(mean(QLP))), '&' , num2str(round(mean(QGreedy))),'& ', num2str(round(mean(QLPSQ))), '&' , num2str(round(mean(QGreedySQ))),'& ', num2str(round(mean(QLP2SQ))), '&' , num2str(round(mean(QGreedy2SQ))),'& ', num2str(round(mean(QLPless))), '&' , num2str(round(mean(QGreedyless))),'\\',... 
    '$\max_{i=\{1,\dots 100\}} Q_i$ ~(maximum) & ', num2str(max(QLP)), '&' , num2str(max(QGreedy)),'& ', num2str(max(QLPSQ)), '&' , num2str(max(QGreedySQ)),'& ', num2str(max(QLP2SQ)), '&' , num2str(max(QGreedy2SQ)),'& ', num2str(max(QLPless)), '&' , num2str(max(QGreedyless)),' \\',...
    '$\min_{i=\{1,\dots 100\}} Q_i$ ~(minimum) & ', num2str(min(QLP)), '&' , num2str(min(QGreedy)),' & ', num2str(min(QLPSQ)), '&' , num2str(min(QGreedySQ)),' & ', num2str(min(QLP2SQ)), '&' , num2str(min(QGreedy2SQ)),'& ', num2str(min(QLPless)), '&' , num2str(min(QGreedyless)),' \\',...
    '$\sum_{i=1}^{100} \hat{Q}_i$ ~(mean) & ', num2str(round(mean(QLP)/size(W,2),2)), '&' , num2str(round(mean(QGreedy)/size(W,2),2)),'& ', num2str(round(mean(QLPSQ)/size(W,1),2)), '&' , num2str(round(mean(QGreedySQ)/size(W,1),2)), '&', num2str(round(mean(QLP2SQ)/(2*size(W,1)),2)),'&',num2str(round(mean(QGreedy2SQ)/(2*size(W,1)),2)), '&', num2str(round(mean(QLPless)/331,2)),'&',num2str(round(mean(QGreedyless)/331,2)),' \\',...
    '$\max_{i=\{1,\dots 100\}} \hat{Q}_i$ ~(maximum) & ', num2str(round(max(QLP)/size(W,2),2)), '&' , num2str(round(max(QGreedy)/size(W,2),2)),'& ', num2str(round(max(QLPSQ)/size(W,1),2)), '&' , num2str(round(max(QGreedySQ)/size(W,1),2)),'&', num2str(round(max(QLP2SQ)/(2*size(W,1)),2)),'&',num2str(round(max(QGreedy2SQ)/(2*size(W,1)),2)),'&', num2str(round(max(QLPless)/331,2)),'&',num2str(round(max(QGreedyless)/331,2)),' \\',...
    '$\min_{i=\{1,\dots 100\}} \hat{Q}_i$ ~(minimum) & ', num2str(round(min(QLP)/size(W,2),2)), '&' , num2str(round(min(QGreedy)/size(W,2),2)),'& ', num2str(round(min(QLPSQ)/size(W,1),2)), '&' , num2str(round(min(QGreedySQ)/size(W,1),2)),'&', num2str(round(min(QLP2SQ)/(2*size(W,1)),2)),'&',num2str(round(min(QGreedy2SQ)/(2*size(W,1)),2)),'&', num2str(round(min(QLPless)/331,2)),'&',num2str(round(min(QGreedyless)/331,2)),' \\',...
    'Average reviewers without expertise & ', num2str(statLP.authors.inexpertassignment.mean),'~(', num2str(round(statLP.authors.inexpertassignment.mean*100/size(W,2),1)) , '\%)&', num2str(statGreedy.authors.inexpertassignment.mean),'~(', num2str(round(statGreedy.authors.inexpertassignment.mean*100/size(W,2),1)) , ' \%)&',...
          num2str(statLPSQ.authors.inexpertassignment.mean),'~(', num2str(round(statLPSQ.authors.inexpertassignment.mean*100/size(W,1),1)) , '\%)&', num2str(statGreedySQ.authors.inexpertassignment.mean),'~(', num2str(round(statGreedySQ.authors.inexpertassignment.mean*100/size(W,1),1)),'\%)&',...
          num2str(statLP2SQ.authors.inexpertassignment.mean),'~(', num2str(round(statLP2SQ.authors.inexpertassignment.mean*100/(2*size(W,1)),1)) , '\%)&', num2str(statGreedy2SQ.authors.inexpertassignment.mean),'~(', num2str(round(statGreedy2SQ.authors.inexpertassignment.mean*100/(2*size(W,1)),1)),'\%)&', ...
          num2str(statLPless.authors.inexpertassignment.mean),'~(', num2str(round(statLPless.authors.inexpertassignment.mean*100/331)) , '\%)&', num2str(statGreedyless.authors.inexpertassignment.mean),'~(', num2str(round(statGreedyless.authors.inexpertassignment.mean*100/331)),  '\%) \\',...
     'Average number of papers with 0 reviewers &',num2str( mLP(1)),'~(',num2str( round(mLP(1)*100/size(W,1),1)) , '\%)&',num2str( mG(1)) ,'~(', num2str( round(mG(1)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPSQ(1)),'~(',num2str( round(mLPSQ(1)*100/size(W,1),1)) , '\%)&',num2str( mGSQ(1)) ,'~(', num2str( round(mGSQ(1)*100/size(W,1),1)),  '\%)&',...
        num2str( mLP2SQ(1)),'~(',num2str( round(mLP2SQ(1)*100/size(W,1),1)) , '\%)&',num2str( mG2SQ(1)) ,'~(', num2str( round(mG2SQ(1)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPless(1)),'~(',num2str( round(mLPless(1)*100/size(W,1),1)) , '\%)&',num2str( mGless(1)) ,'~(', num2str( round(mGless(1)*100/size(W,1),1)),  '\%)\\',...
    'Average number of papers with 1 reviewers &',num2str( mLP(2)),'~(',num2str( round(mLP(2)*100/size(W,1),1)) , '\%)&',num2str( mG(2)) ,'~(', num2str( round(mG(2)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPSQ(2)),'~(',num2str( round(mLPSQ(2)*100/size(W,1),1)) , '\%)&',num2str( mGSQ(2)) ,'~(', num2str( round(mGSQ(2)*100/size(W,1),1)),  '\%)&',...
        num2str( mLP2SQ(2)),'~(',num2str( round(mLP2SQ(2)*100/size(W,1),1)) , '\%)&',num2str( mG2SQ(2)) ,'~(', num2str( round(mG2SQ(2)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPless(2)),'~(',num2str( round(mLPless(2)*100/size(W,1),1)) , '\%)&',num2str( mGless(2)) ,'~(', num2str( round(mGless(2)*100/size(W,1),1)),  '\%)\\',...    
    'Average number of papers with 2 reviewers &',num2str( mLP(3)),'~(',num2str( round(mLP(3)*100/size(W,1),1)) , '\%)&',num2str( mG(3)) ,'~(', num2str( round(mG(3)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPSQ(3)),'~(',num2str( round(mLPSQ(3)*100/size(W,1),1)) , '\%)&',num2str( mGSQ(3)) ,'~(', num2str( round(mGSQ(3)*100/size(W,1),1)),  '\%)&',...
        num2str( mLP2SQ(3)),'~(',num2str( round(mLP2SQ(3)*100/size(W,1),1)) , '\%)&',num2str( mG2SQ(3)) ,'~(', num2str( round(mG2SQ(3)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPless(3)),'~(',num2str( round(mLPless(3)*100/size(W,1),1)) , '\%)&',num2str( mGless(3)) ,'~(', num2str( round(mGless(3)*100/size(W,1),1)),  '\%)\\',...
    'Average number of papers with 3 reviewers &',num2str( mLP(4)),'~(',num2str( round(mLP(4)*100/size(W,1),1)) , '\%)&',num2str( mG(4)) ,'~(', num2str( round(mG(4)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPSQ(4)),'~(',num2str( round(mLPSQ(4)*100/size(W,1),1)) , '\%)&',num2str( mGSQ(4)) ,'~(', num2str( round(mGSQ(4)*100/size(W,1),1)),  '\%)&',...
        num2str( mLP2SQ(4)),'~(',num2str( round(mLP2SQ(4)*100/size(W,1),1)) , '\%)&',num2str( mG2SQ(4)) ,'~(', num2str( round(mG2SQ(4)*100/size(W,1),1)),  '\%)&',...
        num2str( mLPless(4)),'~(',num2str( round(mLPless(4)*100/size(W,1),1)) , '\%)&',num2str( mGless(4)) ,'~(', num2str( round(mGless(4)*100/size(W,1),1)),  '\%)\\',...
     ' \end{tabular}'];
