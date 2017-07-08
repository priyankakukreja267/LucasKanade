function rects = testCarSequenceWithTemplateCorrection()
    load('../data/carseq.mat');
    rect = [60, 117, 146, 152];

    % Get rects matrix: nX4
    rects = LucasKanadeWithTemplateCorrection(frames, rect);
    rectsWithoutTC = testCarSequence();
    save('../results/carseqrects-wcrt.mat', 'rects');

    sampleIndex = [2,100,200,300,400];

    for i = 1:length(sampleIndex)
        coord = getDrawCoordinates(rects(sampleIndex(i), :));
        coordWithoutTC = getDrawCoordinates(rectsWithoutTC(sampleIndex(i), :));

        im = imshow(frames(:,:,sampleIndex(i)));
        hold on;
        
        rectangle('Position', coord, 'EdgeColor', 'y');
        rectangle('Position', coordWithoutTC, 'EdgeColor', 'g');
        filename = sprintf('../results/q14_%d', sampleIndex(i));
        saveas(im, filename);
        close
    end
end

function rects = LucasKanadeWithTemplateCorrection(frames, rect)
    nFrames = size(frames, 3);
    rects = zeros(nFrames, 4);
    rects(1,:) = rect;
    
    initRect = rect;
    prevRect = initRect;
    
    for i = 1:nFrames-1
        [p0,p1] = findDrift(frames(:,:,i+1), frames(:,:,i), [0.0,0.0], prevRect);
        [p0star,p1star] = findDrift(frames(:,:,i+1), frames(:,:,1), [p0,p1], initRect);
        dist = sqrt((p0star - p0)^2 + (p1star - p1)^2);
        if dist <= 2.5
            prevRect = [prevRect(1)+p0star, prevRect(2)+p1star, prevRect(3)+p0star, prevRect(4)+p1star];
        else
            prevRect = [prevRect(1)+p0, prevRect(2)+p1, prevRect(3)+p0, prevRect(4)+p1];
        end
        rects(i+1,:) = prevRect;
    end
end

function [u,v] = findDrift(I, T, seed, rect)
    rect = int32(rect);
    x1 = rect(1);
    y1 = rect(2);
    x2 = rect(3);
    y2 = rect(4);
    rowsW = y2-y1+1;
    colsW = x2-x1+1;
    n = rowsW*colsW; % 'n' is the total number of pixels in the template

    p0 = seed(1);
    p1 = seed(2);

    I = double(I);
    T = double(T);
    
    rowsI = size(I,1);
    colsI = size(I,2);
    X = repmat((1:colsI), rowsI, 1);
    Y = repmat((1:rowsI)', 1, colsI);
    V = I;

    rowsT = size(T,1);
    colsT = size(T,2);
    Xt = repmat((1:colsT), rowsT, 1);
    Yt = repmat((1:rowsT)', 1, colsT);
    Vt = T;
    
    templateX = repmat(x1+p0:x2+p0, rowsW, 1);
    templateX = double(templateX);
    
    templateY = repmat((y1+p1:y2+p1)', 1, colsW);
    templateY = double(templateY);
    
    T = interp2(Xt,Yt,Vt,templateX,templateY);
    
    % Precompute gradient of T, J, steepest Descent and H
    [gradTx, gradTy] = gradient(T);
    grad = [reshape(gradTx, [n,1]), reshape(gradTy, [n,1])]; % grad is nX2 matrix
    J = [1 0; 0 1]; % J is 2X2
    sDescent = grad*J; % sDescent is nX2
    H = sDescent'*sDescent; %H is 2X2

    nIter = 0;
    while nIter < 20
        templateX = repmat((x1+p0:x2+p0), rowsW, 1);
        templateX = double(templateX);

        templateY = repmat((y1+p1:y2+p1)', 1, colsW);
        templateY = double(templateY);

        warpedI = interp2(X,Y,V,templateX,templateY);
        
        errorImg = warpedI - T; % errorImg is rowsW X colsW
        errorImg = reshape(errorImg, [n, 1]); % errorImg is nX1

        M7 = sDescent'*errorImg; % M7 is 2X1

        deltaP = inv(H)*M7; %deltaP is 2X1
        p0 = p0 - deltaP(1);
        p1 = p1 - deltaP(2);

        nIter = nIter + 1;
    end

    u = p0;
    v = p1;
end

function coord = getDrawCoordinates(rect)
    coord = [rect(1), rect(2), rect(3)-rect(1), rect(4)-rect(2)];
end
