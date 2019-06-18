%GETNEXTCLIQUES Find a pair of cliques ready for message passing
%   [i, j] = GETNEXTCLIQUES(P, messages) finds ready cliques in a given
%   clique tree, P, and a matrix of current messages. Returns indices i and j
%   such that clique i is ready to transmit a message to clique j.
%
%   We are doing clique tree message passing, so
%   do not return (i,j) if clique i has already passed a message to clique j.
%
%	 messages: is a n x n matrix of passed messages, where messages(i,j)
% 	 represents the message going from clique i to clique j.
%   This matrix is initialized in CliqueTreeCalibrate as such:
%      MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
%
%   If more than one message is ready to be transmitted, return
%   the pair (i,j) that is numerically smallest. If you use an outer
%   for loop over i and an inner for loop over j, breaking when you find a
%   ready pair of cliques, you will get the right answer.
%
%   If no such cliques exist, returns i = j = 0.
%
%   See also CLIQUETREECALIBRATE
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function [i, j] = GetNextCliques(P, messages)

[n_clusters,~] = size(messages);
edges_mat = P.edges;

% defualt initialization in case we do not find next clique
i = 0;
j = 0;

edges_upper_triangle = triu(edges_mat);
for a = 1:n_clusters
    cluster_i_edges = edges_upper_triangle(a,:);
    col_idxs = find(cluster_i_edges == 1);
    for idx = 1:length(col_idxs)
        col_idx = col_idxs(idx);
        curr_message = messages(a,col_idx);
        if isempty(curr_message.var)
            i = a;
            j = col_idx;
            return;
        else
            continue
        end
    end
end

edges_lower_triangle = tril(edges_mat);
for a = n_clusters:-1:1
    cluster_i_edges = edges_lower_triangle(a,:);
    col_idxs = find(cluster_i_edges == 1);
    for idx = 1:length(col_idxs)
        col_idx = col_idxs(idx);
        curr_message = messages(a,col_idx);
        if isempty(curr_message.var)
            i = a;
            j = col_idx;
            return;
        else
            continue
        end
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
