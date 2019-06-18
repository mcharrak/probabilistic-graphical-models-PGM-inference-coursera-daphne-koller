%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)
% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%

% do a log-transform of the values in the factors/cliques using natural log
if isMax
    for ii = 1:N
        P.cliqueList(ii).val = log(P.cliqueList(ii).val);
    end
end    


while 1
    % find message passing involved cliques
    [i,j] = GetNextCliques(P,MESSAGES);
    if (i == 0 && j == 0)
        break
    end
    C_i = P.cliqueList(i);
    C_j = P.cliqueList(j);
    % sepset variables
    S_i_j = intersect(C_i.var,C_j.var);
    % marginalize out variables not in Sepset_i_j
    C_i_marg_out_vars = setdiff(C_i.var,S_i_j);
    
    % max-sum-algo
    if isMax
        delta_sum = C_i;
        for b = 1:N
            % we only accept incoming messages which do not belong to cluter j
            if ( not(isempty(MESSAGES(b,i).var)) && (j ~= b) )
                incoming_msg = MESSAGES(b,i);
                delta_sum = FactorSum(delta_sum,incoming_msg);
            end
        end
        % marginalize out variables which are not in Sepset (S_i_j)
        message_i_j = FactorMaxMarginalization(delta_sum,C_i_marg_out_vars);
    % sum-produt-algo    
    else
        delta_prod = C_i;
        for b = 1:N
            % we only accept incoming messages which do not belong to cluter j
            if ( not(isempty(MESSAGES(b,i).var)) && (j ~= b) )
                incoming_msg = MESSAGES(b,i);
                delta_prod = FactorProduct(delta_prod,incoming_msg);
            end
        end
        % marginalize out variables which are not in Sepset (S_i_j)
        message_i_j = FactorMarginalization(delta_prod,C_i_marg_out_vars);
        %normalize message_i_j
        Z = sum(message_i_j.val);
        message_i_j.val = message_i_j.val./Z;
    end
    % finally: save message    
    MESSAGES(i,j) = message_i_j; 
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.

% construct final beliefs for each clique and update the entries in P
if isMax
    for C_idx = 1:N
        neighbors_idxs = find(P.edges(C_idx,:) == 1);
        belief = P.cliqueList(C_idx);
        for k = 1:length(neighbors_idxs)
            neighbor_idx = neighbors_idxs(k);
            neighbor_message = MESSAGES(neighbor_idx,C_idx);
            belief = FactorSum(belief,neighbor_message);
        end
        % finally update belief
        P.cliqueList(C_idx) = belief;
    end
else
    for C_idx = 1:N
        neighbors_idxs = find(P.edges(C_idx,:) == 1);
        belief = P.cliqueList(C_idx);
        for k = 1:length(neighbors_idxs)
            neighbor_idx = neighbors_idxs(k);
            neighbor_message = MESSAGES(neighbor_idx,C_idx);
            belief = FactorProduct(belief,neighbor_message);
        end
        % finally update belief
        P.cliqueList(C_idx) = belief;
    end
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return

%     % extract all messages clique C_i has received
%     rec_msgs_idxs = [];
%     for b = 1:N
%         if not(isempty(MESSAGES(b,i).var))
%             rec_msgs_idxs = [rec_msgs_idxs ; [b,i]];
%         else
%             continue
%         end
%     end
%     
%     size_rec_msgs_idxs = size(rec_msgs_idxs);
%     count_rec_msgs = size_rec_msgs_idxs(1);
% 
%     count_max_msgs = sum(P.edges(i,:));
% 
%     % if we have received all messages, we must exclude the idx for the
%     % cluster we are about to send a message to!
%     if count_rec_msgs == count_max_msgs
%         [~,idx_removing_row] = ismember([j,i],rec_msgs_idxs,'rows');
%         rec_msgs_idxs(idx_removing_row,:) = [];
%     end        
%     % multiply all rec_msgs
%     delta_prod = struct('var', [], 'card', [], 'val', []);
%     if not(isempty(rec_msgs_idxs))
%         for c = 1:length(rec_msgs_idxs)
%             msg_idx = rec_msgs_idxs(c);
%             msg = MESSAGES(msg_idx);
%             delta_prod = FactorProduct(msg,delta_prod);
%         end    
%     end
%     % multiply initial belief with product of received messages
%     final_prod = FactorProduct(C_i,delta_prod);
%
%    message_i_j = FactorMarginalization(final_prod,C_i_marg_out_vars);
%   %normalize message_i_j
%    Z_norm = sum(message_i_j.val);
%    message_i_j.val = (message_i_j.val./Z_norm);
%    % finally: save message
%    MESSAGES(i,j) = message_i_j;
