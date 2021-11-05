% =================================================================================================
% Class for computing the winding window related parameter of a component.
% =================================================================================================
%
% Define an interface for:
%     - the losses of the windings
%     - the geometry of the winding
%     - the type of magnetic component
%     - the equivalent circuit
%
% =================================================================================================
%
% Warning: Only the winding window is considered.
%          The core related parameters are only partially considered.
%          The computations are based on a 2D mirroring method which is inacurate geometries.
%
% =================================================================================================
%
% See also:
%     - window_geom_abstract (abtract class for the window geometry)
%     - window_component_abstract (abtract class for the component defintion)
%     - winding_mirroring (abstraction layer for the mirroring method)
%     - mirroring_method (implementation of the mirroring method)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_class < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        window_geom_obj % instance of window_geom
        window_component_obj % instance of window_component
        winding_mirroring_obj % instance of winding_mirroring
        mirroring_method_obj % instance of mirroring_method
    end
    
    %% init
    methods (Access = public)
        function self = window_class(class, core, window, winding)
            % get the core geometrical data
            %     - class - struct with function handlers on the abstract classes
            %     - bc - struct with the boundary condition
            %     - geom - struct with the window geometry
            %     - winding - struct with the winding parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init the window geometry manager (with the user specified class)
            self.window_geom_obj = class.window_geom_class(core, window);
            
            % init the window component manager (with the user specified class)
            window = self.window_geom_obj.get_window();
            self.window_component_obj = class.window_component_class(window, winding);
            
            % init the abstraction layer for the mirroring method
            air_gap = self.window_geom_obj.get_air_gap();
            winding_conductor = self.window_component_obj.get_winding_conductor();
            self.winding_mirroring_obj = winding_mirroring(air_gap, winding_conductor);
            
            % init the mirroring method
            conductor = self.winding_mirroring_obj.get_conductor();
            bc = self.window_geom_obj.get_bc();
            self.mirroring_method_obj = mirroring_method(bc, conductor);
        end
    end
    
    %% public api
    methods (Access = public)
        function type = get_type(self)
            % get the component type
            %     - type - str with the component type
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            type = self.window_component_obj.get_type();
        end
        
        function V = get_copper_volume(self)
            % get the copper volume of the wires of all windings
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            V = self.window_component_obj.get_copper_volume();
        end
        
        function V = get_conductor_volume(self)
            % get the total (copper and insulation) volume of the wires of all windings
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            V = self.window_component_obj.get_conductor_volume();
        end
        
        function V = get_window_volume(self)
            % get the volume of the winding window
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            V = self.window_component_obj.get_window_volume();
        end
        
        function m = get_mass(self)
            % get the mass of all windings
            %     - m - scalar with the mass
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            m = self.window_component_obj.get_mass();
        end
        
        function fig = get_plot(self)
            % make a plot with the window geometry
            %     - fig - handler of the created figure
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the data
            plot_data_conductor = self.window_component_obj.get_plot_data();
            plot_data_geom = self.window_geom_obj.get_plot_data();
            plot_data_geom_sub = self.window_geom_obj.get_plot_data_sub();
            
            % find the title
            str_bc = sprintf('bc = %s', plot_data_geom_sub.type);
            str_n = sprintf('n = %d', plot_data_conductor.n_conductor);
            str_z = sprintf('z = %.1f mm / linear', 1e3.*plot_data_geom.z);
            msg = [str_bc ' / ' str_n ' / ' str_z];
            
            % set the the plot
            fig = figure();
            title(msg, 'interpreter', 'none');
            xlabel('x [mm]');
            ylabel('y [mm]');
            axis('equal');
            hold('on');
            
            % plot winding window
            rectangle('Position', 1e3.*[-plot_data_geom.d./2.0 -plot_data_geom.h./2.0 plot_data_geom.d plot_data_geom.h],'FaceColor', [0.5 0.5 0.5], 'LineStyle','none')
            
            % plot symmetry axis for BC
            for i=1:length(plot_data_geom_sub.sym)
                plot(1e3.*plot_data_geom_sub.sym{i}.x, 1e3.*plot_data_geom_sub.sym{i}.y, 'g')
            end
            
            % plot air gap
            plot(1e3.*plot_data_geom_sub.x_gap, 1e3.*plot_data_geom_sub.y_gap, 'xr')
            
            % plot the conductors
            for i=1:plot_data_conductor.n_conductor
                x = plot_data_conductor.x(i);
                y = plot_data_conductor.y(i);
                d_c = plot_data_conductor.d_c(i);
                
                rectangle('Position', 1e3.*[x-d_c./2.0 y-d_c./2.0 d_c d_c], 'Curvature', 1.0, 'FaceColor', [0.9 0.5 0.0], 'LineStyle','none')
            end
        end
        
        function circuit = get_circuit(self)
            % get the equivalent circuit of the core with the corresponding source
            %     - circuit - struct with the equivalent circuit
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            L = self.mirroring_method_obj.get_L();
            inductance = self.winding_mirroring_obj.parse_inductance(L);
            circuit = self.window_component_obj.parse_circuit(inductance);
        end
        
        function losses = get_losses(self, stress)
            % get the winding losses with a given stress (current, frequency, temperature, etc.)
            %     - stress - stress applied to the component
            %     - losses - struct with the winding losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            validateattributes(stress.f_vec, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(stress.T, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            
            % get the conductor current
            excitation = self.window_component_obj.parse_excitation(length(stress.f_vec), stress.current);
            I_vec = self.winding_mirroring_obj.parse_excitation(excitation);
            
            % get the winding magnetic field
            H = self.mirroring_method_obj.get_H_norm_conductor(I_vec);
            magnetic_field = self.winding_mirroring_obj.parse_magnetic_field(H);
            
            % compute the losses
            losses = self.window_component_obj.get_losses(stress.f_vec, stress.T, excitation, magnetic_field);
        end
    end
end