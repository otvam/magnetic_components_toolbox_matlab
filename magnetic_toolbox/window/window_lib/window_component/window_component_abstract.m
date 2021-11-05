% =================================================================================================
% Abstract class for defining magnetic components (winding, circuit, etc.).
% =================================================================================================
%
% Define an interface for:
%     - computing the losses of the windings
%     - find the equivalent circuit from the inductance matrix
%     - get the geometrical properties of the windings
%     - get the excitation of the windings
%
% =================================================================================================
%
% See also:
%     - winding_manager (manage the different windings)
%     - window_class (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_component_abstract < handle
    %% properties
    properties (SetAccess = protected, GetAccess = protected)
        window % struct with the size of the window
        winding % struct with the information about all the windings
        winding_manager_obj % struct with instances of winding_manager
    end
    
    %% init
    methods (Access = public)
        function self = window_component_abstract(window, winding)
            % create the object
            %     - window - struct with the size of the window
            %     - winding - struct with the information about all the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.window = window;
            self.winding = winding;
        end
    end
    
    %% public api
    methods (Access = public)
        function winding_conductor = get_winding_conductor(self)
            % get the conductors composing the different windings
            %     - winding_conductor - struct with the conductors composing the different windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            field = fieldnames(self.winding_manager_obj);
            for i=1:length(field)
                winding_conductor.(field{i}) = self.winding_manager_obj.(field{i}).get_conductor();
            end
        end
        
        function plot_data = get_plot_data(self)
            % get the data for plotting the window (conductors)
            %     - plot_data - struct with the data for plotting the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            plot_data.x = [];
            plot_data.y = [];
            plot_data.d_c = [];
            
            field = fieldnames(self.winding_manager_obj);
            for i=1:length(field)
                conductor_tmp = self.winding_manager_obj.(field{i}).get_conductor();
                plot_data.x = [plot_data.x conductor_tmp.x];
                plot_data.y = [plot_data.y conductor_tmp.y];
                plot_data.d_c = [plot_data.d_c conductor_tmp.d_c];
            end
            
            plot_data.n_conductor = length(plot_data.d_c);
        end
        
        function losses = get_losses(self, f_vec, T, current, magnetic_field)
            % get the losses produced by all the windings
            %     - f_vec - vector with the frequency
            %     - T - scalar with the temperature
            %     - current - struct with the peak current of the windings
            %     - magnetic_field - struct with the peak RMS magnetic field of the windings
            %     - losses - struct with the losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [P, P_sub] = self.sum_losses(f_vec, T, current, magnetic_field);
            
            losses.P = P;
            losses.P_sub = P_sub;
            losses.is_valid = true;
        end
        
        function V = get_copper_volume(self)
            % get the copper volume of the wires of all windings
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fct = @(self) get_copper_volume(self);
            V = self.sum_value(fct);
        end
        
        function V = get_conductor_volume(self)
            % get the total (copper and insulation) volume of the wires of all windings
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fct = @(self) get_conductor_volume(self);
            V = self.sum_value(fct);
        end
        
        function V = get_window_volume(self)
            % get the volume of the winding window
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A = self.window.d.*self.window.h;
            V = self.window.z_mean.*A;
        end
        
        function m = get_mass(self)
            % get the mass of all windings
            %     - m - scalar with the mass
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fct = @(self) get_mass(self);
            m = self.sum_value(fct);
        end
    end
    
    %% private api
    methods (Access = private)
        function value = sum_value(self, fct)
            % sum a property for all the winding
            %     - fct - function handler for getting the property
            %     - value - scalar with the sum
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            value = 0.0;
            field = fieldnames(self.winding_manager_obj);
            for i=1:length(field)
                value_tmp = fct(self.winding_manager_obj.(field{i}));
                value = value+value_tmp;
            end
        end
        
        function [P, P_sub] = sum_losses(self, f, T, current, magnetic_field)
            % sum the losses of all windings
            %     - f - vector with the frequency
            %     - T - scalar with the temperature
            %     - current - struct with the peak current of the windings
            %     - magnetic_field - struct with the peak RMS magnetic field of the windings
            %     - P - scalar with the total losses
            %     - P_sub - struct with the winding losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            P = 0.0;
            P_sub = struct();
            field = fieldnames(self.winding_manager_obj);
            for i=1:length(field)
                I = abs(current.(field{i}));
                H = abs(magnetic_field.(field{i}));
                
                P_tmp = self.winding_manager_obj.(field{i}).get_losses(f, T, I, H);
                
                P_sub.(field{i}) = P_tmp;
                P = P+P_tmp;
            end
        end
    end
    
    %% public abstract api
    methods (Abstract, Access=public)
        type = get_type(self)
        % get the component type
        %     - type - str with the component type
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        parse_circuit(self, inductance)
        % find the equivalent circuit from the inductance matrix
        %     - inductance - struct with the inductance matrix
        %     - circuit - struct with the equivalent circuit
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        excitation = parse_excitation(self, n, current)
        % find the current of the windings from the current stress applied to the component
        %     - n - scalar with the size of the current vectors
        %     - stress - struct with the current stress applied to the component
        %     - excitation - struct with the current excitation of the windings
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end