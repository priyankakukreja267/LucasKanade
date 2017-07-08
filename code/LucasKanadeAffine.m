% I2(x2) = I1(inv(M).x2)
% Take all the points in image 2. Multiply these points by inv(M) to get
% the corresponding points in image1. Use interp2 to get the intensity
% values at the corresponding points of image - 1. This is the intensity
% value 

function M = LucasKanadeAffine(It, It1)
% input - image at time t, image at t+1 
% output - M affine transformation matrix

    T = double(It);
    I = double(It1);

    rowsI = size(I, 1);
    colsI = size(I, 2);

    n = colsI*rowsI;
    
    X = repmat((1:colsI), rowsI, 1);
    Y = repmat((1:rowsI)', 1, colsI);
    V = I;

    % Precompute gradient of T, J, steepest Descent and H
    [gradTx, gradTy] = gradient(T);
    grad = [reshape(gradTx, [n,1]), reshape(gradTy, [n,1])]; % grad is nX2 matrix
    
    % Finding sDescent
    sDescent = zeros(n,6);
    cnt = 1;

    for a = 1:colsI
        for b = 1:rowsI
            J = [1 0 a b 0 0; 0 1 0 0 a b];
            sDescent(cnt,:) = grad(cnt,:)*J;
            cnt = cnt + 1;                        
        end
    end
    
    H = sDescent'*sDescent; %H is 2X2

    p1 = 0;
    p2 = 0;
    p3 = 0;
    p4 = 0;
    p5 = 0;
    p6 = 0;
    M = [1+p1 p3 p5; p2 (1+p4) p6; 0 0 1];

    Pts = [];
    for i = 1:colsI
        for j = 1:rowsI
            Pts = [Pts [i j 1]'];
        end
    end
    
    pX = (1:colsI);
    pX = repmat(pX, rowsI, 1);
    pX = reshape(pX, [rowsI*colsI 1]);
    pX = pX';

    pY = (1:rowsI);
    pY = repmat(pY, 1, colsI);

    points = [pX;pY;ones(1, rowsI*colsI)];
    points = double(points);
    e = 1;
    nIter = 1;
    while nIter < 10
        nIter = nIter + 1;
        warpedI = warpImage(I, M);
        errorImg = warpedI - T;

        errorImg = reshape(errorImg, [n, 1]); % errorImg is nX1

        M7 = sDescent'*errorImg; % M7 is 6X1

        deltaP = inv(H)*M7; %deltaP is 6X1
        e = sqrt((deltaP(1)*deltaP(1)) + (deltaP(2)*deltaP(2)) + (deltaP(3)*deltaP(3)) + (deltaP(4)*deltaP(4)) + (deltaP(5)*deltaP(5)) + (deltaP(6)*deltaP(6)) );

        % Update the estimate
        denomi = 1/( ((1+deltaP(1))*(1+deltaP(4))) - (deltaP(2)*deltaP(3)) );
        if denomi == 0
            display('beware!')
        end
        deltaP(1) = -deltaP(1) - (deltaP(1)*deltaP(4)) + (deltaP(2)*deltaP(3));
        deltaP(2) = -deltaP(2);
        deltaP(3) = -deltaP(3);
        deltaP(4) = -deltaP(4) - (deltaP(1)*deltaP(4)) + (deltaP(2)*deltaP(3));
        deltaP(5) = -deltaP(5) - (deltaP(4)*deltaP(5)) + (deltaP(3)*deltaP(6));
        deltaP(6) = -deltaP(6) - (deltaP(1)*deltaP(6)) + (deltaP(2)*deltaP(5));

        deltaP = deltaP/denomi;

        p1 = p1 + deltaP(1) + (p1*deltaP(1)) + (p3*deltaP(2));
        p2 = p2 + deltaP(2) + (p2*deltaP(1)) + (p4*deltaP(2));
        p3 = p3 + deltaP(3) + (p1*deltaP(3)) + (p3*deltaP(4));
        p4 = p4 + deltaP(4) + (p2*deltaP(3)) + (p4*deltaP(4));
        p5 = p5 + deltaP(5) + (p1*deltaP(5)) + (p3*deltaP(6));
        p6 = p6 + deltaP(6) + (p2*deltaP(5)) + (p4*deltaP(6));

        M = [1+p1 p3 p5; p2 (1+p4) p6; 0 0 1];
    end
end


function warpedI = warpImage(I, M)
    % I = im2double(I);
    V = I;

    rowsI = size(I, 1);
    colsI = size(I, 2);

    [pX, pY] = meshgrid(1:1:colsI, 1:1:rowsI);
    pX = reshape(pX,[rowsI*colsI,1]);
    pY = reshape(pY, [ rowsI*colsI,1]);
    P = [pX'; pY'; ones(1,rowsI*colsI)];

    warpedP = M\P;

    warpedI = interp2(V, warpedP(1, :)', warpedP(2, :)');
    warpedI(isnan(warpedI)) = 0;
    warpedI = reshape(warpedI', [rowsI colsI]);
end

