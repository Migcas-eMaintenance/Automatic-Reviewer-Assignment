function printAssignment(author,papernames,kwname,W,P,PaperForAuthor,fname)
% Prints in a text file the Assignment Resulsing from using the function
% "assignreviewers". 
% The inputs to the function are: 
%   - author: is a 1-dimensional cell-array with the author set. Each 
%       element of the cell-array is the name of an author. 
%   - papernames: is a 1-dimensional cell-array with the paper set. Each
%       element of the cell-array is the name or identifier of a paper.
%   - kwname: is a 1-dimensional cell-array with the keyword set. Each
%       element of the cell-array is a keyword.
%   - W: Authorship matrix. If the j-th author is an author of the i-th 
%       paper, then W(i,j)=1. Otherwise W(i,j)=0. 
%   - P: Paper/Keyword Matrix. Binary matrix such that P(i,j)= 1 if 
%       the j-th kweyword is present in the i-th paper. P(i,j)=0 otherwise.
%   - PaperForAuthor: is the assignment result, which is obtained from the 
%       function assignreviewers.m. PaperForAuthor is a set of indexes such
%       that PaperForAuthor(:,i) are the indexes of the papersassigned to i-th 
%       author for reviewing.
%   - fname: is a string with the file name to print the result. 
%
%  v1.0  May 2020. Miguel Casta?o Arranz, miguel.castano@ltu.se
%                 Department of Operation and Maintenance, 
%                 Lulea University, Sweden 
%  printoptions.author='index' prints the index of the author instead of
%  the name. 
%  

K=P'*W;
ctstr=1;
n=length(author);
str=cell(3*n,1);
for ct=1:n
    if isempty(kwname(K(:,ct)>0))
        str{ctstr}=[author{ct},': ' 'author with no keywords'];
    else
        [index,~]=find(K(:,ct)>0);
        value=K(index,ct);
        kwarray={};
        for ct2=1:length(value)
            if value(ct2)>1
                kwarray{ct2}=[kwname{index(ct2)}, '(',num2str(value(ct2)), ')'];
            else
                kwarray{ct2}= kwname{index(ct2)};
            end
        end
        %str{ctstr}=[author{ct},': ',...
        %    cell2txt(kwname(K(:,ct)>0),', ')];
        str{ctstr}=['Author ID: ' num2str(author{ct}),', Author Keywords: ',...
            cell2txt(kwarray,', ')];
    end
    
    
    ctstr=ctstr+1;
    for ctpaper=1:size(PaperForAuthor,1)
    if isempty(find(P(PaperForAuthor(ctpaper,ct),:), 1))
        str{ctstr}=['Paper ID: ', papernames{PaperForAuthor(ctpaper,ct)}, ...
            '; Paper keywords: ', 'no keywords'];
    else
        str{ctstr}=['Paper ID: ', papernames{PaperForAuthor(ctpaper,ct)},...
            '; Paper keywords: ', ...
            cell2txt(kwname(P(PaperForAuthor(ctpaper,ct),:)>0),', ')];
    end
    ctstr=ctstr+1;
    end
    str{ctstr}=[];
    ctstr=ctstr+1;
end

hf=fopen(fname,'w+');

for row=1:size(str,1)
    
    fprintf(hf,'%s\n',str{row,:});
end
fclose(hf);
end

function txt=cell2txt(incell,delimiter)

txt=incell{1};
if length(incell)>1
    for ct=2:length(incell)
       txt= [txt,delimiter,incell{ct} ];
    end 
end
end