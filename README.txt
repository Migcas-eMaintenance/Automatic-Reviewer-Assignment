The files in this folder are a MATLAB implementation of the results reported in: 
"Automatic assignment of reviewers in  peer reviewed conferences, subbmitted to Epert Systems (September 2020)"

A description of the files follows: 
- CaseStudy.m can be simply executed in MATLAB to run the case study reported in the paper. 
- AssignmentResult.text includes a detailed solution to the problem. This is overwritten everytime CaseStuy.m is run. 
- AuthorIndexCDC2019 is the author index for the cnference CDC2019, which has bee downloaded from https://cdc2019.ieeecss.org/
- KeywordIndexCDC2019 is the keyword index for the conference CDC2019, which has been donwloaded from https://cdc2019.ieeecss.org/
- OPERAP_CES.m is the main function of the distributed code and it us the implementation of the Exper System OPERAP-CES
- OPERAP_GES.m is the implmentation of the greedy Expert System OPERAP-GES which is introdueced as baseline
- printassignment.m is used to print the result from the assignment problem in the file AssignmentResult.text
- hungarian.m is a function which is needed by assignreviewers.m and which solves the optimization problem. This function has been 
created by a third party: namely Niclas Borlin (niclas@cs.umu.se)
- removeinexpert.m is a preprocessing function to remove inexpert reviewers
- removeisolated.m is a preprocessing function to remove inexpert papers
