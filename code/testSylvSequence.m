function rects = testSylvSequence()
    load('../data/sylvseq.mat');
    load('../data/sylvbases.mat');
    nFrames = size(frames, 3);
    
    rect = [102, 62, 156, 108];
    initRect = rect;
    rects = zeros(nFrames, 4);
    rects(1,:) = rect;
    
    % Get rects matrix: nX4
    for i = 1:nFrames-1
        [u,v] = LucasKanadeBasis(frames(:,:,i), frames(:,:,i+1), rect, bases);
        rect = [rect(1)+u, rect(2)+v, rect(3)+u, rect(4)+v];
        rects(i+1,:) = rect;
    end
    
    save('../results/sylvseqrects.mat', 'rects');
    rectsWithoutBases = testSylvSequenceWithoutBasis(frames, initRect);
    size(rectsWithoutBases)
    
    sampleIndex = [2, 200, 300, 350, 400]
    for i = 1:length(sampleIndex)
        coord = getDrawCoordinates(rects(sampleIndex(i), :));
        coordWithoutBases = getDrawCoordinates(rectsWithoutBases(sampleIndex(i), :));

        im = imshow(frames(:,:,sampleIndex(i)));
        hold on;
        
        rectangle('Position', coord, 'EdgeColor', 'y');
        rectangle('Position', coordWithoutBases, 'EdgeColor', 'g');
        filename = sprintf('../results/q23_%d', sampleIndex(i));
        saveas(im, filename);
        close
    end
end

function rects = testSylvSequenceWithoutBasis(frames, rect)
    nFrames = size(frames, 3);
    rects = zeros(nFrames, 4);
    rects(1,:) = rect;
    for i = 1:nFrames-1
        [u,v] = LucasKanadeInverseCompositional(frames(:,:,i), frames(:,:,i+1), rect);
        rect = [rect(1)+u, rect(2)+v, rect(3)+u, rect(4)+v];
        rects(i+1,:) = rect;
    end
end

function coord = getDrawCoordinates(rect)
    coord = [rect(1), rect(2), rect(3)-rect(1), rect(4)-rect(2)];
end
