% =================================================================================================
% Compute the position of the conductors inside a winding.
% =================================================================================================
%
% Place the conductors inside the winding.
% Multilayer winding with vertical or horizontal orientation.
%
% =================================================================================================
%
% See also:
%     - winding_manager (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef winding_geom_internal < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        internal % struct with the information about the placement
        d_c % scalar with the conductor diameter
        winding_size % struct with the size of the complete winding
        conductor % struct with the position of the conductors
    end
    
    %% init
    methods (Access = public)
        function self = winding_geom_internal(internal, d_c)
            % create the object
            %     - internal - struct with the information about the placement
            %     - d_c - scalar with the conductor diameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.internal = internal;
            self.d_c = d_c;
            
            % check data
            assert(any(strcmp(self.internal.orientation, {'horizontal', 'vertical'})), 'invalid data');
            validateattributes(self.internal.t_layer, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.internal.t_turn, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.internal.n_winding, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.internal.n_par, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute the position of the conductors
            self.init_data();
        end
    end
    
    %% public api
    methods (Access = public)
        function internal = get_internal(self)
            % get the placement information
            %     - external - struct with the information about the placement
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            internal = self.internal;
        end
        
        function d_c = get_diameter(self)
            % get the diameter of the wire
            %     - d_c - scalar with the diameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            d_c = self.d_c;
        end
        
        function winding_size = get_winding_size(self)
            % get the size of the winding
            %     - winding_size - struct with the size of the winding to be placed
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            winding_size = self.winding_size;
        end
        
        function n_winding = get_n_winding(self)
            % get the number of conductor
            %     - n_winding - scalar with the number of turn
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_winding = sum(self.internal.n_winding);
        end
        
        function n_par = get_n_par(self)
            % get the number of conductor
            %     - n_par - scalar with the parallel turns
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_par = self.internal.n_par;
        end
        
        function conductor = get_conductor(self)
            % get the position of the conductors
            %     - conductor - struct with the position of the conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            conductor = self.conductor;
        end
    end
    
    %% private api
    methods (Access = private)
        function init_data(self)
            % compute position of the conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % number of turns
            n_layer = length(self.internal.n_winding);
            n_turn = max(self.internal.n_winding);
            
            % size of the winding
            t_tot_layer = self.span_conductor_tot(self.internal.t_layer, n_layer);
            t_tot_turn = self.span_conductor_tot(self.internal.t_turn, n_turn);
            
            % place the conductor for each layer
            t_vec_turn = [];
            t_vec_layer = [];
            t_vec_layer_tmp = self.span_conductor_vec(self.internal.t_layer, n_layer);
            for i=1:n_layer
                t_vec_turn_tmp = self.span_conductor_vec(self.internal.t_turn, self.internal.n_winding(i));
                t_vec_turn = [t_vec_turn t_vec_turn_tmp];
                t_vec_layer = [t_vec_layer t_vec_layer_tmp(i).*ones(1, self.internal.n_winding(i))];
            end
            
            % assign the results for vertical and horizonzal placement
            switch self.internal.orientation
                case 'vertical'
                    self.winding_size.d = t_tot_layer;
                    self.winding_size.h = t_tot_turn;
                    
                    self.conductor.x = t_vec_layer;
                    self.conductor.y = t_vec_turn;
                case 'horizonzal'
                    self.winding_size.d = t_tot_turn;
                    self.winding_size.h = t_tot_layer;
                    
                    self.conductor.x = t_vec_turn;
                    self.conductor.y = t_vec_layer;
                otherwise
                    error('invalid position')
            end
        end
        
        function t_tot = span_conductor_tot(self, d_space, n)
            % compute the space required by n turns
            %     - d_space - scalar with the space between the turn
            %     - n - scalar with the number of turn
            %     - t_tot - scalar with the required space
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            t_tot = n.*self.d_c+(n-1).*d_space;
        end
        
        function t_vec = span_conductor_vec(self, d_space, n)
            % compute the position of n turns
            %     - d_space - scalar with the space between the turn
            %     - n - scalar with the number of turn
            %     - t_vec - vector with the center position
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            t_tmp = (n-1).*self.d_c+(n-1).*d_space;
            t_vec = linspace(-t_tmp./2.0, t_tmp./2.0, n);
        end
    end
end
