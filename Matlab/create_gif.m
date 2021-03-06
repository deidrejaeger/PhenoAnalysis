%Original create_gif script. Should now use createGif()

filename = 'C:\Users\tstafford2\Desktop\tmp\timelapse2.gif';
%Get the images
[rgbs,irs] = getImgs(phenoDataPath,'ninemileprairie',false);

gcc = []; ndvi = [];

for i = 1:length(rgbs)
    %Read the image and calculate gcc. 
    rgb = imread(rgbs{i});
    ir = imread(irs{i});
    gcc = horzcat(gcc,getGcc(rgb));
    ndvi = horzcat(ndvi,getNdvi(rgb,ir));
end

for i = 1:length(rgbs)
    h = figure('position',[200,200,1000,700],'Visible','Off');   
    %Prepare the figure. Everything needs to be set up to mimic the final
    %frame. 
    rgb = imread(rgbs{i});
    
    %Get the current date
    datenm = path2datenum(rgbs{i});
    [~, m] = month(datenm);
    
    %rgb = imresize(rgb,0.5);
    s1 = subplot(3,2,1);
    %imshow(imresize(rgb,2));
    imshow(rgb);
    axis image
    title(['RGB: ' m ' ' num2str(day(datenm))],'FontSize',11);
    
    ir = imread(irs{i});
    cir = getCir(rgb,ir);
    s2 = subplot(3,2,3);
    imshow(cir);
    axis image
    title(['CIR: ' m ' ' num2str(day(datenm))],'FontSize',11);

    
    ndviIm = getNdviIm(rgb,ir);
    s3 = subplot(3,2,5);
    imagesc(ndviIm); colorbar('westoutside');
    set(gca,'xtick',[]);set(gca,'ytick',[])
    set(gca,'xticklabel',[]);set(gca,'yticklabel',[])
    axis image
    pos = get(s3,'position');
    pos(1) = pos(1) - 0.032;
    set(s3,'position',pos);
    title(['NDVI: ' m ' ' num2str(day(datenm))],'FontSize',11);
    
    linkaxes([s1,s2,s3]);
    
    subplot(3,2,[2 4 6]);   
    %plot(1:i,gcc(1:i),'b*');
    %plot(1:i,gcc(1:i),'b*',1:i,sigfun(params,1:i),'g-')
    plot(1:i,sigfun(params,1:i),'k-');
    hold on;
    [ax,~,~] = plotyy(1:i,gcc(1:i),1:i,ndvi(1:i),@(x,y)plot(x,y,'*','color',[0 0.5 0]),@(x,y)plot(x,y,'r*'));
    title('Nine Mile Prairie GCC, April 16 - May 6','FontSize',12);
    xlim([0 25]);
    set(ax(1),'XLim',[0 25]);
    set(ax(2),'XLim',[0 25]);
    set(ax(1),'YLim',[0.33 0.39]);
    set(ax(1),'YTick',[0.33:0.01:0.39]);
    %ylim(ax(2),[-1 1]);
    set(ax(2),'Ylim',[-1 1]);
    set(ax(2),'YTick',[-1:0.2:1]);
    xlabel('DOY','FontSize',11);
    ylabel(ax(1),'Green Chromatic Coordinate','FontSize',11);
    ylabel(ax(2),'NDVI','FontSize',11);
    set(ax(1),'XTickLabel',[105:5:130]); % have to change the tick label...
    set(ax(2),'XTickLabel',[105:5:130]);
    legend('Sigmoidal Fit','Image GCC','Mean NDVI');
    tightfig(h);
    drawnow;
   
    %Write the gif. THIS WILL NEED TO CHANGE
    frame = getframe(h);
    im = frame2im(frame);
    [a,map] = rgb2ind(im, 256);
    %[a,map] = rgb2ind(rgb,256);
    if i==1
        imwrite(a,map,filename,'gif','LoopCount',Inf,'DelayTime',0.5);
    elseif i==length(rgbs)
        imwrite(a,map,filename,'gif','WriteMode','append','DelayTime',5);
    else
        imwrite(a,map,filename,'gif','WriteMode','append','DelayTime',0.5);
    end
    
    clf(h);
    close(h);

end
