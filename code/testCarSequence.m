function rects = testCarSequence()
load('../data/carseq.mat');

nFrames = size(frames, 3);
%nFrames = 100;

rect = [60, 117, 146, 152];
rects = zeros(nFrames, 4);
rects(1,:) = rect;

% Get rects matrix: nX4
for i = 1:nFrames-1
    [u,v] = LucasKanadeInverseCompositional(frames(:,:,i), frames(:,:,i+1), rect);
    rect = [rect(1)+u, rect(2)+v, rect(3)+u, rect(4)+v];
    rects(i+1,:) = rect;
end

save('../results/carseqrects.mat', 'rects');

sampleIndex = [2,100,200,300,400];

for i = 1:length(sampleIndex)
    coord = getDrawCoordinates(rects(sampleIndex(i), :));
    im = imshow(frames(:,:,sampleIndex(i)));
    hold on;
    rectangle('Position', coord, 'EdgeColor', 'y');
    filename = sprintf('../results/q13_%d', sampleIndex(i));
    saveas(im, filename);
    close
end

%filenames = ['../results/q13_002.fig', '../results/q13_100.fig', '../results/q13_200.fig', '../results/q13_300.fig', '../results/q13_400.fig'];
%montage(filenames, 'Size', [1,5])
end

function coord = getDrawCoordinates(rect)
    coord = [rect(1), rect(2), rect(3)-rect(1), rect(4)-rect(2)];
end
