function F = ReshapeVarFields(F)
% this function takes the field .var and reshapes the entries such that we
% have the default shape of 1xn_vars
    n_factors = length(F);
    for i = 1:n_factors
        F(i).var = F(i).var';
    end
return