% =================================================================================================
% Check the validity of a 2D mirroring problem.
% =================================================================================================
%
% Check if the conductors are correctly located.
% Check if the field is evaluated inside the domain.
% Check the length of different vectors.
%
% =================================================================================================
%
% See also:
%     - mirroring_method (main class)
%
% =================================================================================================
% (c) 2016-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod, BSD License
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef mirror_check < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        bc % user defined boundary condition
        conductor % user defined conductor
    end
    
    %% init
    methods (Access = public)
        function self = mirror_check(bc, conductor)
            % create the object
            %     - bc - struct with the definition of the BC (type, position, permeability, number of mirror)
            %     - conductor - struct with the definition of the conductor (position, radius, number)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.bc = bc;
            self.conductor = conductor;
        end
    end
    
    %% public api
    methods (Access = public)
        function check_x_y(self, x, y)
            % check if the given coordinates are inside the domain
            %     - x - vector with the x coordinates
            %     - y - vector with the y coordinates
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            validateattributes(x, {'double'},{'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(y, {'double'},{'row', 'nonempty', 'nonnan', 'real','finite'});
            assert(length(x)==length(y), 'invalid data');
            self.check_in_bc_sub(x, y, 0.0);
        end
        
        function check_I_vec(self, I_vec)
            % check if the length of the current vector is correct
            %     - I_vec - vector wit the current excitation of the conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            validateattributes(I_vec, {'double'},{'2d', 'nonempty', 'nonnan','finite'});
            assert(size(I_vec, 1)==self.conductor.n_conductor, 'invalid data');
        end
        
        function check_data(self)
            % check the validity of the data provided by the user
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check conductor
            validateattributes(self.conductor.x, {'double'},{'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.conductor.x, {'double'},{'row', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.conductor.d_c, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.conductor.n_conductor, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            assert(length(self.conductor.x)==self.conductor.n_conductor, 'invalid data');
            assert(length(self.conductor.y)==self.conductor.n_conductor, 'invalid data');
            assert(length(self.conductor.d_c)==self.conductor.n_conductor, 'invalid data');
            
            % check bc
            assert(any(strcmp(self.bc.type, {'none', 'x', 'y' , 'xx', 'yy', 'xy'})), 'invalid data');
            validateattributes(self.bc.z_size, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.bc.d_pole, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.bc.mu_domain, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            if any(strcmp(self.bc.type, {'xx', 'xy'}))
                validateattributes(self.bc.x_min, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
                validateattributes(self.bc.x_max, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            end
            if any(strcmp(self.bc.type, {'yy', 'xy'}))
                validateattributes(self.bc.y_min, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
                validateattributes(self.bc.y_max, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            end
            if strcmp(self.bc.type, 'x')
                validateattributes(self.bc.x, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            end
            if strcmp(self.bc.type, 'y')
                validateattributes(self.bc.y, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            end
            if any(strcmp(self.bc.type, {'xx', 'yy', 'xy'}))
                validateattributes(self.bc.n_mirror, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            end
            if any(strcmp(self.bc.type, {'x', 'y', 'xx', 'yy', 'xy'}))
                validateattributes(self.bc.mu_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            end
            
            % check if the conductor are located inside the domain
            self.check_in_bc_sub(self.conductor.x, self.conductor.y, self.conductor.d_c./2.0);
            
            % check if no overlap exists between the conductors
            [x_c_mat_1,x_c_mat_2] = self.get_matrix_coordinate(self.conductor.x, self.conductor.x);
            [y_c_mat_1,y_c_mat_2] = self.get_matrix_coordinate(self.conductor.y, self.conductor.y);
            d_conductor_square = (x_c_mat_1-x_c_mat_2).^2+(y_c_mat_1-y_c_mat_2).^2;
            
            [r_mat_1,r_mat_2] = self.get_matrix_coordinate(self.conductor.d_c./2.0, self.conductor.d_c./2.0);
            d_min_square = (r_mat_1+r_mat_2).^2;
            d_min_square(logical(eye(size(d_min_square)))) = 0.0;
            
            assert(all(all(d_conductor_square>=d_min_square)), 'invalid data');
        end
    end
    
    %% private api
    methods (Access = private)
        function [v1_mat,v2_mat] = get_matrix_coordinate(self, v1, v2)
            % meshgrid the space formed by two vectors
            %     - v1 - first input vector
            %     - v2 - first input vector
            %     - v1_mat - matrix corresponding to the vector v1
            %     - v2_mat - matrix corresponding to the vector v2
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            v1_mat = (v1.')*ones(1,length(v2));
            v2_mat = ones(length(v1),1)*v2;
        end
        
        function check_in_bc_sub(self, x, y, r)
            % check if the given coordinates are inside the domain (within a cylinder radius)
            %     - x - vector with the x coordinates
            %     - y - vector with the y coordinates
            %     - r - radius around the coordinates
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if any(strcmp(self.bc.type, {'xx', 'xy'}))
                assert(all((x-r)>=self.bc.x_min), 'invalid data')
                assert(all((x+r)<=self.bc.x_max), 'invalid data')
            end
            if any(strcmp(self.bc.type, {'yy', 'xy'}))
                assert(all((y-r)>=self.bc.y_min), 'invalid data')
                assert(all((y+r)<=self.bc.y_max), 'invalid data')
            end
            if strcmp(self.bc.type, 'x')
                assert(all((x-r)>=self.bc.x)||all((x+r)<=self.bc.x), 'invalid data')
            end
            if strcmp(self.bc.type, 'y')
                assert(all((y-r)>=self.bc.y)||all((y+r)<=self.bc.y), 'invalid data')
            end
        end
    end
end