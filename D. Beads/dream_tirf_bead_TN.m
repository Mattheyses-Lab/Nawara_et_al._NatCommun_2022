%based on Stabley et al. 2015 modyfied by Tomasz Nawara

function [mean_z_profile,mean_zHeight] = dream_tirf_bead_TN
close all
%Set path to folder with pictures
% beads need to be splitted based on vavlenght, corrrected for chromatic
% aberation and blured in 488 to correct for interpolation in 647 the smae
% as cell data is look at lines 26-28 to see ho to name bead files for each
% channel neceseary for the analysis
yourpath = 'C:\Users\tnawara\Desktop\Nawara - Nat Commun\5. Test data sets\D. Beads';
pixl = 110; %pixel size in [nm]
fun = 30; %how much from ceter of the bead to be displayed
%manual_detection = 1;
% Get all the subfolders
ContentInFold = dir(yourpath);
SubFold = ContentInFold([ContentInFold.isdir]); % keep only the directories

d_488 = decay(488,1.515,1.43,1.2741); %%% Updated trefractive idexex TN and TIRF angle
d_647 = decay(647,1.515,1.43,1.2741); 

gamma = (1/((d_647-d_488)/(d_647*d_488)));
count = 1;

% Loop on each folder
for h = 3:length(SubFold)% start at 3 to skip . and ..
    Bead_488T = fullfile(yourpath,SubFold(h).name,[SubFold(h).name(end-2:end) '_TIRF_488_Cor_Blur.tif']); 
    Bead_647T = fullfile(yourpath,SubFold(h).name,[SubFold(h).name(end-2:end) '_TIRF_647_Cor_Reg.tif']); 
    Bead_488E = fullfile(yourpath,SubFold(h).name,[SubFold(h).name(end-2:end) '_EPI_488.tif']);

%      Bead_488T = fullfile(yourpath,SubFold(h).name,[SubFold(h).name '_488_Cor_Blur.tif']); 
%      Bead_647T = fullfile(yourpath,SubFold(h).name,[SubFold(h).name '_647_Cor_Reg.tif']); 
%      Bead_488E = fullfile(yourpath,SubFold(h).name,[SubFold(h).name '_EPI488_Raw.tif']); 


    im_488T = double(imread(Bead_488T));
    im_647T = double(imread(Bead_647T));
    im_488E = double(imread(Bead_488E));
    
    maxv = max(max(im_488T));
    minv = min(min(im_488T));
    maxE = max(max(im_488E));
    minE = min(min(im_488E));
        
    %click on beads, right click on last bead to end
    figure(1);
    Idisp = im2uint8(((im_488T- minv)/(maxv-minv))+((im_488E- minE)/(maxE-minE)) );
    %apply a mask to make sure that you chose beads in range
    Idisp(1:fun, 1:end) = 0;
    Idisp(end-fun:end, 1:end) = 0;
    Idisp(1:end, 1:fun) = 0;
    Idisp(1:end, end-fun:end) = 0;
    
%    if manual_detection == 1
     [xpos, ypos, ~] = impixel(Idisp);
     npoints(h) = size(xpos, 1);
    hold off
%     else
%         sigma = 3;
%         f = 31;
%         Idisp_gaus = imgaussfilt(Idisp, sigma);
%         points_beads = detectHarrisFeatures(Idisp_gaus, 'FilterSize', f); 
%         figure(488)
%         imshow(imadjust(Idisp_gaus)); hold on; plot(points_beads);
%         xpos = points_beads.Location(1:end,1);
%         ypos = points_beads.Location(1:end,2);
%         npoints(h) = size(xpos, 1);
%     end
    
    %loop over beads
    for i = 1:npoints(h)
        bead = im_488T(ypos(i)-fun:ypos(i)+fun, xpos(i)-fun:xpos(i)+fun);
        bead_647 = im_647T(ypos(i)-fun:ypos(i)+fun, xpos(i)-fun:xpos(i)+fun);
        bead_epi488 = im_488E(ypos(i)-fun:ypos(i)+fun, xpos(i)-fun:xpos(i)+fun);
        
%         bead = im_488T;
%         bead_647 = im_647T;
%         bead_epi488 = im_488E;
        
        figure(3);
        image(bead);
        beadforfit = (bead+bead_647)/2;
        %median filter before curve fitting
        %beadforfit = medfilt2(beadforfit);
        
        [height,width] = size(beadforfit);
        [X,Y] = meshgrid(1:height,1:width);
        X = X(:); Y=Y(:); Z = beadforfit(:);
        %figure(1); clf; scatter3(X,Y,Z);

%          [X,Y] = meshgrid(1:(2*fun+1),1:(2*fun+1));
%          X = X(:); Y=Y(:);

        % 2D gaussian fit object
        gauss2 = fittype( @(a1, sigmax, sigmay, x0,y0, x, y) a1*exp(-(x-x0).^2/(2*sigmax^2)-(y-y0).^2/(2*sigmay^2)),'independent', {'x', 'y'},'dependent', 'z' );

        a1 = max(beadforfit(:)); % height, determine from image. may want to subtract background
        sigmax = 12; % guess width
        sigmay = 12; % guess width
        x0 = width/2; % guess position (center)
        y0 = height/2; 

        % compute fit
        sf = fit([X,Y],double(Z),gauss2,'StartPoint',[a1, sigmax, sigmay, x0,y0]);
        figure(1); clf; plot(sf,[X,Y],Z);

        %sf.x0 and sf.y0 is the center of gaussian
        %sf.sigmax etc will get you the other parameters
        
        %center = [round(xpos(i)), round(ypos(i))];%center of the bead
        center = [round(sf.y0), round(sf.x0)];%center of the bead
        keepcenter(count, 1) = center(1) + ypos(i);
        keepcenter(count, 2) = center(2) + xpos(i);
        %calculate distance of each pixel from the center
        
%         linescanvertical = bead_epi488(center(1)-fun:center(1)+fun, center(2));
%         linescanhorizontal = bead_epi488(center(2)-fun:center(2)+fun, center(1));

        linescanvertical = bead_epi488(:, center(2));
        linescanhorizontal = bead_epi488(:, center(1));

        
        %linescanvertical_smooth = movmean(linescanvertical,10);
        [~,LOCS_vert]= findpeaks(smooth(linescanvertical, 3), 'MinPeakProminence',100);
        if size(LOCS_vert,1) > 2 || size(LOCS_vert,1) < 2
            figure(4);
            plot(linescanvertical);
            [vx,~] = ginput(2);
        else
            vx = zeros(2,1); 
            vx(1,1) = LOCS_vert(1,1);
            vx(2,1) = LOCS_vert(2,1);
        end
        
       % linescanhorizontal_smooth = movmean(linescanhorizontal,10);
        [~,LOCS_horz] =  findpeaks(smooth(linescanhorizontal, 3), 'MinPeakProminence',100);
        if size(LOCS_horz,1) > 2 || size(LOCS_horz,1) < 2
            figure(4);
            plot(linescanhorizontal);
            [hx,~] = ginput(2);
        else
            hx = zeros(2,1); 
            hx(1,1) = LOCS_horz(1,1);
            hx(2,1) = LOCS_horz(2,1);
        end
        
        %[linescanverticalsort, zz] = sort(linescanvertical);
        %linescan_vertical_size = size(linescanvertical);
        
        %[linescanhorizontalsort, zz] = sort(linescanhorizontal);
        %linescan_horizontal_size = size(linescanhorizontal);
        
        %bead_diameter(count) = abs(((zz(linescan_vertical_size(1))-zz(linescan_vertical_size(1)-1))+(zz(linescan_horizontal_size(1))-zz(linescan_horizontal_size(1)-1))/2));
        bead_diameter(count) = pixl.*(abs(((hx(2)-hx(1))/2)+((vx(2)-vx(1))/2)));
        
        
        radius(count) = bead_diameter(count)/2;

        ii = X(:);
        jj = Y(:);
        dist = round(sqrt((ii-center(1)).^2 + (jj-center(2)).^2));
        distout = dist;
        [dist, yy] = sort(dist);

        %how many matrix values at each distance?
        hh = hist(dist,max(dist+1));
        vec_488 = bead(:);
        vec_488 = vec_488(yy); %sort vec same as dist
        vec_647 = bead_647(:);
        vec_647 = vec_647(yy); %sort vec same as dist
        
        %result(1:max(dist))=0;
        result_488(count, 300)=0;
        result_647(count, 300)=0;
        ini = 2;
        
        for k = 1:max(dist)
            index = (ini:ini+hh(k+1)-1);
            result_488(k)= mean(vec_488(index));
            result_647(k)= mean(vec_647(index));
            ini = max(index)+1;
        end

       

        %save intensity as a function of pixel
        I_profile_488(:, count) = result_488(1:40);
        I_profile_647(:, count) = result_647(1:40);
        
%         figure(count+10000)
%         plot(I_profile_488(:, count)); hold on; plot(I_profile_647(:, count));
%         m=input('Accept, y/n:','s');
% 
%         if m=='n' %discard
%         close(count+10000)
%         
%         elseif m=='y' 
       
        
        Ratio(:, count) =  I_profile_647(:, count)./I_profile_488(:, count);
        zHeight(:, count) = log(Ratio(:,count)/Ratio(1,count)).*gamma;
        %convert pixel into z distance
        
        MaxVal488(count) = max(I_profile_488(1,count));
        MaxVal647(count) = max(I_profile_647(1,count));
      
        result_488_normalized = I_profile_488(:,count)/MaxVal488(count);
        result_647_normalized = I_profile_647(:,count)/MaxVal647(count);
        
        
        
        for k = 1:21
            z_profile(k,count) = radius(count) - ((radius(count)*sin(acos((k*pixl)/radius(count)))));
        end
        
        
        figure(count+10000)
        plot(z_profile(1:20, count)); hold on; plot(zHeight(1:20, count));
        m=input('Accept, y/n:','s');

        if m=='n' %discard
        close(count+10000)
        
        elseif m=='y' 

             dd = 21;
           if count == 1 
            z_profile_total = z_profile(1:dd,count);
            zHeight_total = zHeight(1:dd,count);
            
        else
            z_profile_total =  [z_profile_total z_profile(1:dd,count)];
            zHeight_total = [zHeight_total zHeight(1:dd,count)]; 
        end
        
    
        figure(count+5);
        plot(z_profile(1:dd,count),result_488_normalized(1:dd));
        hold all
        plot(z_profile(1:dd,count),result_647_normalized(1:dd));
        hold all
        plot(z_profile(1:dd,count),ev_field(z_profile(1:dd,count),d_488)); %%% got rid of 1
        hold all
        plot(z_profile(1:dd,count),ev_field(z_profile(1:dd,count),d_647));
        

        figure(count+6);
        plot(z_profile(1:dd,count));
        hold all
        plot(zHeight(1:dd,count));
        
        count = count +1;
        end
        
        
        clear ii;
        clear jj;
          clear yy;
        clear index;
        clear dist;
        clear vec_488;
        clear result_488;
        clear vec_647;
        clear result_647;

      
        end
  
end
Mean_z_profile = mean(z_profile_total,2);
SEM_z_profile = std(z_profile_total,0,2)/sqrt(length(z_profile_total));

Mean_z_heigth = mean(zHeight_total,2);
SEM_z_height = std(zHeight_total,0,2)/sqrt(length(zHeight_total));

x_axis = (0:1:size(zHeight_total,1)-1)*110; %*110 is a pixel size in nm

figure(1)
errorbar(x_axis(1:8),Mean_z_profile(1:8), SEM_z_profile(1:8), 'b')
hold on
errorbar(x_axis(1:8),Mean_z_heigth(1:8), SEM_z_height(1:8), 'r')
axis square
legend('Theor','Meas')
xlabel('x[nm]')
ylabel('z[nm]')
end


function [ d ] = decay( lambda, ng, ns, theta )

d = (lambda/(4*pi*sqrt(ng^2* sin(theta)^2 - (ns^2))));

end

function [ I ] = ev_field( z, d )
 
I= exp(-z/d);
 
end



    


        
