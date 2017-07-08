function rects = testUltrasoundSequence()
load('../data/usseq.mat');

nFrames = size(frames, 3);
%nFrames = 100;

rect = [255, 105, 310, 170];
rects = zeros(nFrames, 4);
rects(1,:) = rect;

% Get rects matrix: nX4
for i = 1:nFrames-1
    [u,v] = LucasKanadeInverseCompositional(frames(:,:,i), frames(:,:,i+1), rect);
    rect = [rect(1)+u, rect(2)+v, rect(3)+u, rect(4)+v];
    rects(i+1,:) = rect;
end

save('../results/usseqrects.mat', 'rects');

sampleIndex = [5,25,50,75,100];
sampleR = rects(sampleIndex,:);

for i = 1:length(sampleIndex)
    coord = getDrawCoordinates(rects(sampleIndex(i), :));
    %drawCoordinates = [sampleR(i,1), sampleR(i,2), sampleR(i,3)-sampleR(i,1), sampleR(i,4)-sampleR(i,2)];
    im = imshow(frames(:,:,sampleIndex(i)));
    hold on;
    rectangle('Position', coord, 'EdgeColor', 'y');
    filename = sprintf('../results/q13b_%d', sampleIndex(i));
    saveas(im, filename);
    close
end

%filenames = ['../results/q13_002.fig', '../results/q13_100.fig', '../results/q13_200.fig', '../results/q13_300.fig', '../results/q13_400.fig'];
%montage(filenames, 'Size', [1,5])
end

function coord = getDrawCoordinates(rect)
    coord = [rect(1), rect(2), rect(3)-rect(1), rect(4)-rect(2)];
end
