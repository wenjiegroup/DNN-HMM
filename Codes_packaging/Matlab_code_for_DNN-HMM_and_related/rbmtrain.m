function rbm = rbmtrain(rbm, x, opts)
    assert(isfloat(x), 'x must be a float');
    m = size(x, 1);
    numbatches = floor(m / opts.batchsize);
    
    assert(rem(numbatches, 1) == 0, 'numbatches not integer');

    for i = 1 : opts.numepochs
        kk = randperm(m);
        err = 0;
        for l = 1 : numbatches
            
            if l==numbatches 
                batch = x(kk((l - 1) * opts.batchsize + 1 : end), :);
            else
                batch = x(kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize), :);
            end
            batchsize=size(batch,1);
            
            v1 = batch;
            h1 = sigmrnd(repmat(rbm.c', batchsize, 1) + v1 * rbm.W');
            v2 = sigmrnd(repmat(rbm.b', batchsize, 1) + h1 * rbm.W);
            h2 = sigmrnd(repmat(rbm.c', batchsize, 1) + v2 * rbm.W');

            c1 = h1' * v1;
            c2 = h2' * v2;

            rbm.vW = rbm.momentum * rbm.vW + rbm.alpha * (c1 - c2)     / batchsize;
            rbm.vb = rbm.momentum * rbm.vb + rbm.alpha * sum(v1 - v2)' / batchsize;
            rbm.vc = rbm.momentum * rbm.vc + rbm.alpha * sum(h1 - h2)' / batchsize;

            rbm.W = rbm.W + rbm.vW;
            rbm.b = rbm.b + rbm.vb;
            rbm.c = rbm.c + rbm.vc;

            err = err + sum(sum((v1 - v2) .^ 2)) / batchsize;
        end
        
        disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)  '. Average reconstruction error is: ' num2str(err / numbatches)]);
        
    end
end
