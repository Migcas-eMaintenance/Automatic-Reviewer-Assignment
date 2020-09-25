%% Script for Information Gathering (see Section 2.1 in [1]) by parsing 
% the program from the conference CDC2019
%
% [1]: "Automatic assignment of reviewers in peer reviewed conferences",
% subbmitted to Epert Systems (May2020)
%
% The script is divided in two parts. Part 1 parses the Author Index and
% Part 2 parses the Paper Index. 

%% 1.- Code for parsing the Author Index from the conference CDC 2019
%  After executing this section of the code, the following variables are 
%  obtained:
%   - authorSet: cell array with the names of all the authors
%   - papernSet: cell array with the ID of each paper
%   - W: Authorship matrix. If author{j} is an author of paper{i}, then
%       W(i,j)=1. Otherwise W(i,j)=0. 

hf=fopen('AuthorIndexCDC2019.txt');
st=textscan(hf,'%s','Delimiter','\n'); st=st{1};
alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
for ct=1:length(alphabet)
    nostr{ct}= [alphabet(ct), st{20}(2:end)]; %#ok<SAGROW>
end
Paperprefix={'WeA','WeB','WeC','ThA','ThB','ThC','FrA','FrB','FrC',...
    'WeSP','ThSP','FrSP'};
ctauthor=1;authorSet={};
for ct=16:length(st)-13
    if ~isempty(st{ct})
        if  sum(strcmp(st{ct},nostr))
            
        elseif sum(strcmp(st{ct}(1:3),Paperprefix))
            if ~isempty(strfind(st{ct},'.'))
                papersbyauthor{ctauthor-1}{ctpaper}=st{ct}; %#ok<SAGROW>
                ctpaper=ctpaper+1;
            end
        else
            authorSet{ctauthor}=st{ct}; %#ok<SAGROW>
            ctauthor=ctauthor+1;
            ctpaper=1;
        end
    end
end

ct=1;
for ctauthor=1:length(papersbyauthor)
    for ctpaper=1:length(papersbyauthor{ctauthor})
        papernames{ct}=papersbyauthor{ctauthor}{ctpaper}; %#ok<SAGROW>
        ct=ct+1;
    end
end
paperSet=unique(papernames);

for ctauthor=1:length(authorSet)
    for ctpaper=1:length(papersbyauthor{ctauthor})
        ind=strcmp(paperSet,papersbyauthor{ctauthor}{ctpaper});
        W(ind,ctauthor)=1; %#ok<SAGROW>
    end
end

%% 2.- Code for parsing the Keyword Index from the conference CDC 2019
%  After executing this section of the code, the following variables are 
%  obtained:
%   - kwSEet: cell array with all the keywords
%   - P: Paper/Keyword Matrix. Binary matrix such that P(i,j)= 1 if 
%       keyword{j} is present in paper{i}. P(i,j)=0 otherwise.

hf=fopen('KEywordIndexCDC2019.txt');
st=textscan(hf,'%s','Delimiter','\n'); st=st{1};
for ct=1:length(alphabet)
    nostr{ct}= [alphabet(ct), st{14}(2:end)];
end

ctkw=1;
for ct=15:length(st)-12
    if ~isempty(st{ct})
        if  sum(strcmp(st{ct},nostr))
        elseif strcmp(st{ct}(1:8),'See also')
            % repeated=1;
        else
            kw{ctkw}=st{ct}; %#ok<SAGROW>
            ctkw=ctkw+1;
        end
    end
end

for ctkw=1:length(kw)
    paperwithKW=textscan(kw{ctkw},'%s','Delimiter',',');
    paperwithKW=paperwithKW{1};
    a=textscan(paperwithKW{1},'%s');
    paperwithKW{1}=a{1}{end};
    for ct=1:length(a{1})-1
        if ct==1
            kwSEetaux= [a{1}{1} ];
        else
            kwSEetaux= [kwSEetaux,' ',a{1}{ct} ]; %#ok<AGROW>
        end
    end
    kwSEet{ctkw}=kwSEetaux; %#ok<SAGROW>
    for ctpaper=1:length(paperwithKW)
        ind=strcmp(paperSet,paperwithKW{ctpaper});
        P(ind,ctkw)=1; %#ok<SAGROW>
    end
end
clear a alphabet ct ctauthor ctkw ctpaper hf ind kw kwSEetaux nostr
clear paperprefix papersbyauthor paperwithKW repeated st
