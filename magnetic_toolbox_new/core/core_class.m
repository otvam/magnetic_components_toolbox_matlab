% =================================================================================================
% Class for computing the magnetic core related parameter of a component.
% =================================================================================================
%
% Define an interface for:
%     - the magnetic core material parameter
%     - the geometry of the core
%     - the type of magnetic component
%     - the reluctance circuit
%     - the core losses
%
% =================================================================================================
%
% Warning: Only the core and the magnetic source are considered.
%          The winding (losses, stray field, etc.) are not considered.
%          The computations are based on reluctance method which is inacurate for some materials and geometries.
%
% =================================================================================================
%
% See also:
%     - core_material (class for core material properties)
%     - core_geom_abstract (abtract class for the core geometry)
%     - core_component_abstract (abtract class for the component defintion)
%     - reluctance_method (class for the reluctance model)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_class < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        core_material_obj % instance of core_material
        core_geom_obj  % instance of core_geom
        core_component_obj  % instance of core_component
        reluctance_method_obj  % instance of reluctance_method
    end
    
    %% init
    methods (Access = public)
        function self = core_class(class, material, geom, winding)
            % get the core geometrical data
            %     - class - struct with function handlers on the abstract classes
            %     - material - struct with the core material
            %     - geom - struct with the core geometry
            %     - winding - struct with the winding parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % create the core material manager
            self.core_material_obj = core_material(material.mu_core, material.mu_domain, material.rho, material.losses_map);
            
            % init the core geometry manager (with the user specified class)
            mu_core = self.core_material_obj.get_mu_core();
            mu_domain = self.core_material_obj.get_mu_domain();
            self.core_geom_obj = class.core_geom_class(geom, mu_core, mu_domain);
            
            % init the core component manager (with the user specified class)
            self.core_component_obj = class.core_component_class(winding);
            
            % init the reluctance solver manager
            limb = self.core_geom_obj.get_limb();
            source = self.core_component_obj.get_source();
            self.reluctance_method_obj = reluctance_method(limb, source);
        end
    end
    
    %% public api
    methods (Access = public)
        function type = get_type(self)
            % get the component type
            %     - type - str with the component type
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            type = self.core_component_obj.get_type();
        end
        
        function V = get_core_volume(self)
            % get the core volume of the core (without window)
            %     - V - scalar with the volume of the core
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            V = self.core_geom_obj.get_core_volume();
        end
        
        function V = get_box_volume(self)
            % get the box volume of the core (with window)
            %     - V - scalar with the box volume of the core
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            V = self.core_geom_obj.get_box_volume();
        end
        
        function m = get_mass(self)
            % get the mass of the core (without the window)
            %     - m - scalar with the mass of the core
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            rho = self.core_material_obj.get_rho();
            V = self.core_geom_obj.get_core_volume();
            m = rho.*V;
        end
        
        function fig = get_plot(self)
            % make a plot with the core geometry
            %     - fig - handler of the created figure
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the data
            plot_data = self.core_geom_obj.get_plot_data();
            
            % find the title
            str_d_gap = sprintf('gap = %.1f mm', 1e3.*plot_data.d_gap);
            str_z_core = sprintf('z = %.1f mm', 1e3.*plot_data.z_core);
            str_A_mag = sprintf('A = %.1f mm2', 1e6.*plot_data.A_mag);
            msg = [plot_data.name ' / ' str_d_gap ' / ' str_z_core ' / ' str_A_mag];
            
            % set the the plot
            fig = figure();
            title(msg, 'interpreter', 'none');
            xlabel('x [mm]');
            ylabel('y [mm]');
            axis('equal');
            hold('on');
            
            % plot the core element
            for i=1:length(plot_data.core)
                tmp = plot_data.core{i};
                rectangle('Position', 1e3.*[tmp.x_min tmp.y_min tmp.x_max-tmp.x_min tmp.y_max-tmp.y_min],'FaceColor', [0.5 0.5 0.5], 'LineStyle','none')
            end
            
            % substract the window area
            for i=1:length(plot_data.window)
                tmp = plot_data.window{i};
                rectangle('Position', 1e3.*[tmp.x_min tmp.y_min tmp.x_max-tmp.x_min tmp.y_max-tmp.y_min],'FaceColor', [1 1 1], 'LineStyle','none')
            end
        end
        
        function circuit = get_circuit(self)
            % get the equivalent circuit of the core with the corresponding source
            %     - circuit - struct with the equivalent circuit
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            inductance = self.reluctance_method_obj.get_inductance();
            circuit = self.core_component_obj.parse_circuit(inductance);
        end
        
        function losses = get_losses(self, stress)
            % get the core losses with a given stress (current, frequency, temperature, etc.)
            %     - stress - stress applied to the component
            %     - losses - struct with the core losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            validateattributes(stress.d_vec, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(stress.f, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(stress.T, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            
            % get the flux inside the limbs
            excitation = self.core_component_obj.parse_excitation(length(stress.d_vec), stress.current);
            phi_limb = self.reluctance_method_obj.get_phi_limb(excitation);
            
            % get the element composing the limb
            limb_element = self.reluctance_method_obj.get_limb_element();
            
            % compute the losses
            losses = self.get_losses_sub(stress, phi_limb, limb_element);
        end
    end
    
    %% private api
    methods (Access=private)
        function losses = get_losses_sub(self, stress, phi_limb, limb_element)
            % compute the core losses from the reluctance element and the flux (all limbs)
            %     - stress - stress applied to the component
            %     - phi_limb - struct with the flux inside the limbs
            %     - limb_element - struct with the magnetic properties of the limbs
            %     - losses - struct with the core losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init the losses struct
            losses.is_valid = true;
            losses.P = 0.0;
            
            % add the losses for each limb
            field = fieldnames(phi_limb);
            for i=1:length(field)
                losses = self.get_losses_limb(losses, stress, phi_limb.(field{i}), limb_element.(field{i}));
            end
        end
        
        function losses = get_losses_limb(self, losses, stress, phi_limb, limb_element)
            % compute the core losses for a particular limb
            %     - losses - struct with the core losses
            %     - stress - stress applied to the component
            %     - phi_limb - struct with the flux inside the limbs
            %     - limb_element - struct with the magnetic properties of the selected limb
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            field = fieldnames(limb_element);
            for i=1:length(field)
                losses = self.get_losses_element(losses, stress, phi_limb, limb_element.(field{i}));
            end
        end
        
        function losses = get_losses_element(self, losses, stress, phi_limb, element)
            % compute the core losses for a particular reluctance element
            %     - losses - struct with the core losses
            %     - stress - stress applied to the component
            %     - phi_limb - struct with the flux inside the limbs
            %     - element - struct with the magnetic properties of the selected element
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % only core elements are cotributing to the losses
            switch element.type
                case {'stab', 'corner'}
                    % flux density
                    B_vec = phi_limb./element.A;
                    
                    % effective magnetic volume
                    V = element.A.*element.l;
                    
                    % get the losses per volume
                    losses_tmp = self.core_material_obj.get_losses_igse(stress.f, stress.d_vec, B_vec, stress.T);
                    
                    % add the losses
                    losses.is_valid = losses.is_valid&&losses_tmp.is_valid;
                    losses.P = losses.P+V.*losses_tmp.P;
                case {'gap_simple', 'gap_stab_stab', 'gap_stab_half_plane', 'gap_stab_full_plane'}
                    % pass
                otherwise
                    error('invalid type')
            end
        end
    end
end