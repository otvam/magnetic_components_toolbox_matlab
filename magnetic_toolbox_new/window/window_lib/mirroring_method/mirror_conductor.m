% =================================================================================================
% Mirror the conductors with respect to the BC.
% =================================================================================================
%
% Find the symmetry axis.
% Mirror the conductors.
% Weight the mirrored conductors.
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
classdef mirror_conductor < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        bc % user defined boundary condition
        conductor % user defined conductor
        distance % struct with the distance to the pole and size of the 2d slice
        bc_mirror % mirror axis for the BC (set by mirror_conductor)
        conductor_mirror % mirrored conductor (set by mirror_conductor)
    end
    
    %% init
    methods (Access = public)
        function self = mirror_conductor(bc, conductor)
            % create the object
            %     - bc - struct with the definition of the BC (type, position, permeability, number of mirror)
            %     - conductor - struct with the definition of the conductor (position, radius, number)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.bc = bc;
            self.conductor = conductor;
            
            % compute the BC and the mirrored conductors
            self.init_distance();
            self.init_bc_mirror();
            self.init_conductor_mirror();
        end
    end
    
    %% public api
    methods (Access = public)
        function bc_mirror = get_bc_mirror(self)
            % get the post processed BC
            %     - bc_mirror - struct with the post processed BC
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            bc_mirror = self.bc_mirror;
        end
        
        function distance = get_distance(self)
            % get the struct with the distances required for the computations
            %     - distance - struct with the distances required for the computations
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            distance = self.distance;
        end
        
        function conductor_mirror = get_conductor_mirror(self)
            % get the mirrored conductors
            %     - conductor_mirror - struct with the mirrored conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            conductor_mirror = self.conductor_mirror;
        end
    end
    
    %% private api
    methods (Access = private)
        function init_distance(self)
            % create the struct with the distances required for the computations
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.distance.d_pole = self.bc.d_pole;
            self.distance.z_size = self.bc.z_size;
        end
        
        function self = init_bc_mirror(self)
            % create the post processed BC
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init the data
            self.bc_mirror = struct('d_x', 0.0, 'd_y', 0.0, 'x_flip', 0.0, 'y_flip', 0.0);
            
            % set the symmetry axis and the distance between the planes
            switch self.bc.type
                case 'none'
                    % pass
                case 'x'
                    self.bc_mirror.d_x = self.bc.x;
                    self.bc_mirror.x_flip = self.bc.x./2.0;
                case 'y'
                    self.bc_mirror.d_y = self.bc.y;
                    self.bc_mirror.y_flip = self.bc.y./2.0;
                case 'xx'
                    self.bc_mirror.d_x = self.bc.x_max-self.bc.x_min;
                    self.bc_mirror.x_flip = (self.bc.x_min+self.bc.x_max)./2.0;
                case 'yy'
                    self.bc_mirror.d_y = self.bc.y_max-self.bc.y_min;
                    self.bc_mirror.y_flip = (self.bc.y_min+self.bc.y_max)./2.0;
                case 'xy'
                    self.bc_mirror.d_x = self.bc.x_max-self.bc.x_min;
                    self.bc_mirror.x_flip = (self.bc.x_min+self.bc.x_max)./2.0;
                    self.bc_mirror.d_y = self.bc.y_max-self.bc.y_min;
                    self.bc_mirror.y_flip = (self.bc.y_min+self.bc.y_max)./2.0;
                otherwise
                    error('invalid data');
            end
        end
        
        function self = init_conductor_mirror(self)
            % create the mirrored conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init the data
            self.conductor_mirror = struct('x', [], 'y', [], 'k', [], 'idx_conductor', [], 'n_conductor', 0);
            
            % create the different images (without including the original conductors)
            switch self.bc.type
                case 'none'
                    % pass
                case 'x'
                    self.add_image(+1, 0);
                case 'y'
                    self.add_image(0, 1);
                case 'xx'
                    n_idx = -self.bc.n_mirror:self.bc.n_mirror;
                    for i=n_idx
                        self.add_image(i, 0);
                    end
                case 'yy'
                    n_idx = -self.bc.n_mirror:self.bc.n_mirror;
                    for i=n_idx
                        self.add_image(0, i);
                    end
                case 'xy'
                    n_idx = -self.bc.n_mirror:self.bc.n_mirror;
                    for i=n_idx
                        for j=n_idx
                            self.add_image(i, j);
                        end
                    end
                otherwise
                    error('invalid data');
            end
        end
        
        function add_image(self, idx_x, idx_y)
            % create an image of the original conductor (index of the original image are allowed)
            %     - idx_x - integer with the x index of the image
            %     - idx_y - integer with the y index of the image
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % prevent the creation of an image which is identical to the orignial conductors
            if (idx_x~=0)||(idx_y~=0)
                self.add_image_sub(idx_x, idx_y);
            end
        end
        
        function add_image_sub(self, idx_x, idx_y)
            % create an image of the original conductor (index of the original image are not allowed)
            %     - idx_x - integer with the x index of the image
            %     - idx_y - integer with the y index of the image
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % shift of the image
            d_x_tmp = idx_x.*self.bc_mirror.d_x;
            d_y_tmp = idx_y.*self.bc_mirror.d_y;
            
            % flip along x axis
            if mod(idx_x, 2)==0
                x = d_x_tmp+self.conductor.x;
            else
                x = d_x_tmp+(2.0.*self.bc_mirror.x_flip-self.conductor.x);
            end
            
            % flip along y axis
            if mod(idx_y, 2)==0
                y = d_y_tmp+self.conductor.y;
            else
                y = d_y_tmp+(2.0.*self.bc_mirror.y_flip-self.conductor.y);
            end
            
            % weight of the image
            k_idx = max(abs(idx_x), abs(idx_y));
            k = ((self.bc.mu_core-self.bc.mu_domain)./(self.bc.mu_core+self.bc.mu_domain)).^k_idx;
            k = k.*ones(1, self.conductor.n_conductor);
            
            % index of the imaged conductors with respect to the original conductors
            idx_conductor = 1:self.conductor.n_conductor;
            
            % add the image
            self.conductor_mirror.n_conductor = self.conductor_mirror.n_conductor+self.conductor.n_conductor;
            self.conductor_mirror.x = [self.conductor_mirror.x x];
            self.conductor_mirror.y = [self.conductor_mirror.y y];
            self.conductor_mirror.idx_conductor = [self.conductor_mirror.idx_conductor idx_conductor];
            self.conductor_mirror.k = [self.conductor_mirror.k k];
        end
    end
end