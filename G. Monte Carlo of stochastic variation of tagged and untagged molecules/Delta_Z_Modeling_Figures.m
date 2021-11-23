%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


function Delta_Z_Modeling_Figures(increments, percentage)
    
    if nargin < 2
        increments = 5; %% Indicate the number of figures (or increments) wanted
        percentage = 100; %% Indicate the percentage of molecules tagged
    end
    
    for j = 0:(increments-1)
            rng default; %% Stops the Random Generator
            % Checks for any inputs from user
            radius = 50;
            theta = 70; % 61.38860895 < theta < 90
            instances  = 200;
            elevation = -2*radius*j/(increments - 1); % The Chord of the Fluorophores
            tagged = round(instances*percentage/100);

            % Creating a Evenly Distributed Uniformed Vesicle
            gr = (sqrt(5)+1)/2; % Golden Ratio
            ga = 2*pi*(1-1/gr); % Golden Angle
            r = randperm(instances, tagged); % Particle index
            lat = acos(1-2*r/(instances-1)); % Latitude 
            lon = r*ga; % Longitude

            % Convert from spherical to Cartesian coordinates
            x = real(sin(lat).*cos(lon).*radius + radius);
            y = real(sin(lat).*sin(lon).*radius + radius);
            z = real(cos(lat).*radius + radius + elevation);

            % Refractive index of the air, the prism/glass, and the cell
            z0 = 0;
            n0 = 1.000; %#ok<NASGU>
            n1 = 1.515;
            n2 = 1.330;

            % First and Second Wavelengths in nanometers
            wavelength1 = 488;
            wavelength2 = 647;

            % Initial Intensity
            I_naught = 100;

            % Calculating the d-variables
            d_488 = wavelength1/4/pi/sqrt((n1*sind(theta))^2-n2^2);
            d_647 = wavelength2/4/pi/sqrt((n1*sind(theta))^2-n2^2);

            % Calculating the gamma(in degrees)
            gamma = (1/d_488)-(1/d_647);

            % First and Second Intensity at Refernce Point (Z0)
            intensity_488_z0 = I_naught/exp(z0/d_488);
            intensity_647_z0 = I_naught/exp(z0/d_647);
            reference = intensity_647_z0/intensity_488_z0;

            % Calculating the Total Intensities
            total_intensity_488 = 0;
            total_intensity_647 = 0;
            [~, n] = size(z);

            count = 0;
            meanz = 0;
            for i = 1:n % Call for the index of the column value
                if z(1, i) > 0 
                    % First and Second Intensity at Z2
                    intensity_488_z(i) = real(I_naught/exp(z(1, i)/d_488)); %#ok<AGROW>
                    intensity_647_z(i) = real(I_naught/exp(z(1, i)/d_647)); %#ok<AGROW>

                    % Sum of intensities value (Clean)
                    total_intensity_488 = total_intensity_488 + intensity_488_z(i);
                    total_intensity_647 = total_intensity_647 + intensity_647_z(i);

                    meanz = (meanz*count + z(1, i))/(count+1);
                    count = count + 1;
                end
            end

            % Get dz value
            ratio = total_intensity_647/total_intensity_488;
            dz = log(ratio/reference)/gamma;

            % Define color of each point based on z value
            colors = jet(numel(z));
            [~, ~, depthIdx] = unique(abs(z)); 
            colorData = colors(depthIdx,:);

            % Define size gradient based on z value
            dotSize = linspace(1,50,numel(x)); 
            sizeData = dotSize(depthIdx);

            % Plot Sphere and Center of Mass
            figure (j+1)
            hold on;
            axis equal;
            grid on;
            view([45 45 45]);
            xlim([0 100]);
            ylim([0 100]);
            zlim([0 100]);
            % tickCell = {'XTickLabel',{},'YTickLabel',{},'ZTickLabel',{},};
            % set(gca,tickCell{:});
            xlabel('');
            ylabel('');
            zlabel('');
            title(sprintf(''));
            scatter3(x, y, z, sizeData, colorData, 'filled', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.5);
            plot3(mean(x), mean(y), meanz, 'k*'); % Center of Mass
            plot3(mean(x), mean(y), dz,'b*'); % Delta z
    end
end