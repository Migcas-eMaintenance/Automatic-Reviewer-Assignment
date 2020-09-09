function stat=calculatestats(PaperOrder,W,P,Q,Qhist)
% calculatestats calculates useful statistics for a set of solutions to
% the reviewer assignment problem (RAP). 
%
% stat=calculatestats(PaperOrder,W,P,Q,Qhist) returns a structure named
% stats with different statistics. 
% The inputs are: 
%   - PaperOrder: is a matrix where each row is a solution for the RAP.
%   PaperOrder(i,j) is the index of the paper that reviewer j receives in
%   solution i. 
% The output is a structure with the following fields. 
%   - stast.authors is a structure with statistics related to the authors
%   - stats.authors.inexpertassignment.mean is them mean number of authors
% assigned to papers for which they have no expertise
%   - stats.papers is a structure with statistics related to the papers
%   - stats.papers.reviewsperpaper.count is a matrix were the i-th row is
% related to the i-th row of PaperOrder. PaperOrder(i,j) is the number of
% papers in assignment i which have j-1 reviewers assigned. 
%   - stats.papers.reviewsperpaper.mean is the mean across all the assignments
% of stats.papers.reviewsperpaper.count. That is, the i-th element is the 
% average number of papers accross all assignments which receive i-1
% reviewers. 

for ct=1:length(Qhist)
    ninexpert(ct)=Qhist{ct}(1);
end
stat.authors.inexpertassignment.mean=mean(ninexpert);

maxreviewers=ceil(size(W,2)/size(W,1));
stat.papers.reviewsperpaer.count=zeros(1,maxreviewers+1);
for ct=1:size(PaperOrder)
stat.papers.reviewsperpaer.count(ct,:)=reviewsperpaper(PaperOrder(ct,:),size(W,1),maxreviewers);
end

stat.papers.reviewsperpaper.mean=mean(stat.papers.reviewsperpaer.count);

function ctreviews=reviewsperpaper(PaperOrder,npapers,maxreviews)
% reviewsperpaper returns a hsitogram vector for the number of reviews per
% paper
ctreviews=zeros(1,maxreviews+1);
for ct=1:npapers
    ind=find(PaperOrder==ct);
    ctreviews(length(ind)+1)= ctreviews(length(ind)+1)+1;
end