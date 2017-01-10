function [output_dim] = create_kern_shape (input_dim, pooling, required_output)

%the function calculates the dimension of the kernels according to fixed
%parameters like: pooling, the dimension of the required_output, and the
%dimension of the input.
% as example
% input_dim =[4,5]
% pooling =[2,2]
% input_dim =[10,12]

output_dim = [0,0];

for i=1:2
    output_dim(i) = - required_output(i)*pooling(i) + input_dim(i) + 1;
    if output_dim(i) <= 0
        disp ('ERROR: kernel size negative');
    end
end

