%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


function [std_dz] = Delta_Z_vs_CM_Spaghetti_Plot(radius,theta)
    close all; 
    rng default
    monte_carlos = 100;
    meanz(101, monte_carlos) = 0;
    dz(101, monte_carlos) = 0;
    for k = 1:monte_carlos % Runs 100 Monte Carlo Simulations
        % Checks for any inputs from user
        if nargin < 2
            radius = 50;
            theta = 70; % 61.38860895 < theta < 90
        end
        instances = 200;
        tagged = 200; % Indicate the number of instances are tagged

        % Creating a Evenly Distributed Uniformed Vesicle
        gr = (sqrt(5)+1)/2; %Golden Ratio
        ga = 2*pi*(1-1/gr); %Golden Angle
        r = randperm(instances, tagged); %Particle index
        lat = acos(1-2*r/(instances-1)); %Latitude
        lon = r*ga; %Longitude

        for j = 0:100 % For Each Percentage of the Formed Vesicle
            elevation = j-100; % The Chord of the Fluorophores

            % Convert from spherical to Cartesian coordinates
            x = real(sin(lat).*cos(lon).*radius + radius); %#ok<NASGU>
            y = real(sin(lat).*sin(lon).*radius + radius);  %#ok<NASGU>
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

            for i = 1:n % Call for the index of the column value
                if z(1, i) > 0
                    % First and Second Intensity at Z2
                    intensity_488_z(i) = real(I_naught/exp(z(1, i)/d_488)); %#ok<AGROW>
                    intensity_647_z(i) = real(I_naught/exp(z(1, i)/d_647)); %#ok<AGROW>

                    % Sum of intensities value (Clean)
                    total_intensity_488 = total_intensity_488 + intensity_488_z(i);
                    total_intensity_647 = total_intensity_647 + intensity_647_z(i);
                end
            end

            %Calculating the Center of Mass
            meanz(j+1, k) = radius + (0.5*elevation);

            % Get dz value
            ratio = total_intensity_647/total_intensity_488;
            dz(j+1, k) = log(ratio/reference)/gamma;
        end
    end
     
    mean_dz = mean(dz, 2, 'omitnan');
    std_dz = std(dz, 0, 2, 'omitnan');
    std_dz(isnan(std_dz))=0;
    
    mean_CM = mean(meanz,2);
    
    hold on;
    grid on;
    %xlabel('Percentage of Vesicle Formed (%)');
    %ylabel('[nm]');
    %axis equal;
    %title(sprintf('Delta z vs. Center of Mass with 100 Percent Tagged'));

    dd_index = 1;
    color = [1 0.4 1; 0.2 1 0.6; 1 0.8 0.4; 0.2 0.8 1];
    for a = 1:monte_carlos
        
        plot((0:1:100), dz(1:end, a), '-', 'color', color(dd_index, 1:end),'LineWidth', 0.75);
        dd_index = dd_index + 1;
        if dd_index == 5
            dd_index = 1;
        end
    end
    hold on;
    plot(mean_CM, 'k-', 'LineWidth', 1.5);
    plot(mean_dz, 'b-', 'LineWidth', 3);
    
    fake_names = cell(1,monte_carlos);
    for ii = 1:monte_carlos
        fake_names{1,ii} = '';
    end
%      important_names = {'Center of Mass', 'Mean of Delta z'};
%     both_together = [fake_names, important_names];
%     legend(both_together, 'Location', 'northwest');
    box on
    axis([0 100 0 70]);
    axis square;
    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);

    
    
end