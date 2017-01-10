function [output_dim] = plan_CNN (feat_1_R, context, N_layers, pooling, required_output)

%The function creates the layers of the network according to the dimension
%of the required output, the number of layers, and pooling.
%Inputs are:
%N_layers - integer (number of layer of both convolution and pooling) -
%must be 1 or 2
%pooling = [2,2,2,1] for two layers of pooling of respectively [2,2] and
%[2,1]
%required_output is a 2 values vector (rows ad columns)
%feat_1_R is the length of the features of a single Room (example 26 for
%MFCC)
%context is the length of the context
%output_dim will be a vector of 2*N_layers, where first and second value
%will be the dimension of the first kernel, and so on

%The function is implemented for 1 or 2 layer. In the case of 2 layer a
%default dimension is set for the output of the first layer, which must be
%a fixed parameter


input_matrix = [context*2, feat_1_R];
output_dim = [];

%in this case pooling and required_output is supposed to be 2 values
%vectors
if N_layers == 1
    output_dim = create_kern_shape(input_matrix, pooling, required_output);
end

% in this case pooling and required_output are 4 values vectors
if N_layers == 2
    default_middle = [8,8];
    output_dim(1:2) = create_kern_shape(input_matrix, pooling(1:2), default_middle);
    output_dim(3:4) = create_kern_shape(default_middle, pooling(3:4), required_output);
end

end
    