function F_new = ChangeVariablesOrder(F)
%input F: set of factors
%output F_new: reordered set of factors
n_factors = length(F);

F_new = repmat(struct('var', [], 'card', [], 'val', []), n_factors, 1)';

for a = 1:n_factors
    
    curr_var = F(a).var;
    curr_card = F(a).card;
    % change to ascending varibles order
    [var_new, sort_order] = sort(curr_var,"ascend");
    card_new = curr_card(sort_order);
    
    F_new(a).var = var_new;
    F_new(a).card = card_new;
    
    old_assignments = IndexToAssignment(1:prod(curr_card),curr_card);
    for b=1:prod(curr_card)
        old_assignment = old_assignments(b,:);
        old_value = GetValueOfAssignment(F(a),old_assignment);       
        new_assignment = old_assignment(sort_order);
        F_new(a) = SetValueOfAssignment(F_new(a),new_assignment,old_value);
    end
end    