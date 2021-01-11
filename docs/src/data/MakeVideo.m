function MakeVideo(X, t_max, filename)
    addpath('./borders');
    
    load('Stations.mat', 'lons', 'lats', 'mStart', 'y');
    load('Stations2.mat', 'outlon0', 'outlon1', 'outlat0', 'outlat1', 'numxgrid', 'numygrid');
    load('conc_hysplit.mat', 'data');
    data = permute(data, [3 4 2 1]);
    
    concExpected = zeros(280, 323, 38);
    for i=1:length(X)
        concExpected = concExpected + X(i)*data(:,:,:,i);
    end
    
    lonsTest = linspace(outlon0, outlon1, numxgrid)';
    latsTest = linspace(outlat0, outlat1, numygrid)';
    
    cropSmall   = 0.01;
    
    colorMap = colormap(hsv);
    levels  = [0.01; 0.3; 1; 2; 5; Inf];
    levelsC = floor((1:length(levels)-1)/(length(levels)-1)*size(colorMap,1));
    for timeInstant = 1:t_max
        yPred = squeeze(concExpected(:,:,timeInstant+8));
        measSmall = mStart == timeInstant & y < cropSmall*max(y(mStart == timeInstant));
        measBig   = mStart == timeInstant & y >= cropSmall*max(y(mStart == timeInstant));
        
        figure('visible', 'off');
        hold on;
        for i=1:length(lonsTest)-1
            for j=1:length(latsTest)-1
                for k=1:length(levels)-1
                    if yPred(i,j) >= levels(k) && yPred(i,j) < levels(k+1)
                        rectangle('Position',[lonsTest(i), latsTest(j), lonsTest(i+1)-lonsTest(i), latsTest(j+1)-latsTest(j)], 'FaceColor', colorMap(levelsC(k),:), 'EdgeColor', 'none');
                    end
                end
            end
        end
        
        for k=1:length(levels)-1
            measBigPart = measBig & y >= levels(k) & y < levels(k) + 1;
            scatter(lons(measBigPart), lats(measBigPart), [],  colorMap(levelsC(k),:), 'filled');
        end
        for k=1:length(levels)-1
            rectangle('Position',[outlon0 + (k-1)*2, outlat0 + 1, 2, 1], 'FaceColor', colorMap(levelsC(k),:), 'EdgeColor', 'none');
        end
        scatter(lons(measBig), lats(measBig), 'k');
        scatter(lons(measSmall), lats(measSmall), 'xk');
        xlim([outlon0 outlon1]);
        ylim([outlat0 outlat1]);
        borders('countries','nomap','k');
        set(gcf,'color','w');
        
        frame = getframe(gcf);
        [imind, cm] = rgb2ind(frame2im(frame),256);
        if timeInstant == 1
            imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.25);
        else
            imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.25);
        end
    end
end
