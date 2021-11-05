% =================================================================================================
% Find the magnetic field and the inductance from the conductors.
% =================================================================================================
%
% Find the vector magnetic field.
% Find the inductance matrix.
% Take the conductors and the mirrored conductors into account.
% A relative mu of 1 is taken (and not mu_domain or mu_core).
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
classdef mirror_physics < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        conductor % user defined conductor
        conductor_mirror % mirrored conductor (set by mirror_conductor)
        distance % struct with the distance to the pole and size of the 2d slice
    end
    
    %% init
    methods (Access = public)
        function self = mirror_physics(conductor, conductor_mirror, distance)
            % create the object
            %     - conductor - struct with the definition of the conductor (position, radius, number)
            %     - conductor_mirror - struct with the mirrored conductors
            %     - distance - struct with the distance to the pole and size of the 2d slice
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.conductor = conductor;
            self.conductor_mirror = conductor_mirror;
            self.distance = distance;
        end
    end
    
    %% public api
    methods (Access = public)
        function L = get_L(self)
            % get the inductance matrix between the orginal conductor (takes into account the mirrored conductors)
            %     - L - matrix with the inductances
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % inductance matrix between the original conductors
            L = self.get_L_intern();
            
            % add the contribution of the mirrored conductors
            if self.conductor_mirror.n_conductor>0
                L_extern = self.get_L_extern();
                L = L+L_extern;
            end
            
            % the inductance is ill-defined for line conductors
            idx_zero = find(self.conductor.d_c==0.0);
            idx = sub2ind([self.conductor.n_conductor, self.conductor.n_conductor], idx_zero, idx_zero);
            L(idx) = NaN;
        end
        
        function [H_x, H_y] = get_H_xy(self, x, y, I_vec)
            % get the vector magnetic field at the defined coordinates
            %     - x - vector with the x coordinates
            %     - y - vector with the y coordinates
            %     - I_vec - matrix wit the current excitation of the conductors
            %     - H_x - matrix with the x componenent of the magnetic field
            %     - H_y - matrix with the y componenent of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % field produced by the original conductors
            [H_x, H_y] = self.get_H_xy_intern(x, y, I_vec);
            
            % add the contribution of the mirrored conductors
            if self.conductor_mirror.n_conductor>0
                [H_x_extern, H_y_extern] = self.get_H_xy_extern(x, y, I_vec);
                H_x = H_x+H_x_extern;
                H_y = H_y+H_y_extern;
            end
        end
    end
    
    %% private api
    methods (Access = private)
        function L = get_L_intern(self)
            % get the inductance matrix between the orginal conductor (without the mirrored conductors)
            %     - L - matrix with the inductances
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the distance between the original conductors
            [x_c_mat_1,x_c_mat_2] = self.get_matrix_coordinate(self.conductor.x, self.conductor.x);
            [y_c_mat_1,y_c_mat_2] = self.get_matrix_coordinate(self.conductor.y, self.conductor.y);
            d_square_mat = (x_c_mat_1-x_c_mat_2).^2+(y_c_mat_1-y_c_mat_2).^2;
            
            % correction if the conductor radius if the field is evaluated inside a conductor
            r_conductor_square = (self.conductor.d_c./2.0).^2.*exp(-1.0./2.0);
            d_square_mat(logical(eye(size(d_square_mat)))) = r_conductor_square;
            
            % compute the matrix
            L = self.get_L_sub(d_square_mat);
        end
        
        function L = get_L_extern(self)
            % get the contribution of the mirrored conductors to the inductance matrix
            %     - L - matrix with the inductances
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the distance between the original and mirrored conductors
            [x_c_mat_1,x_c_mat_2] = self.get_matrix_coordinate(self.conductor.x, self.conductor_mirror.x);
            [y_c_mat_1,y_c_mat_2] = self.get_matrix_coordinate(self.conductor.y, self.conductor_mirror.y);
            d_square_mat = (x_c_mat_1-x_c_mat_2).^2+(y_c_mat_1-y_c_mat_2).^2;
            
            % compute the matrix
            L_mirror = self.get_L_sub(d_square_mat);
            
            % matrix for summing the contribution of the mirrored conductor with the corresponding weight
            add_mirror = zeros(self.conductor_mirror.n_conductor, self.conductor.n_conductor);
            idx_row = 1:self.conductor_mirror.n_conductor;
            idx_col = self.conductor_mirror.idx_conductor;
            idx = sub2ind([self.conductor_mirror.n_conductor, self.conductor.n_conductor], idx_row, idx_col);
            add_mirror(idx) = self.conductor_mirror.k;
            
            % compute the matrix
            L = L_mirror*add_mirror;
        end
        
        function L = get_L_sub(self, d_square_mat)
            % get the inductance between conductors
            %     - d_square_mat - matrix with the square of the distances
            %     - d_pole - scalar with the distance to the pole (if the sum of conductors is non zero)
            %     - L - matrix with the inductances
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % compute the inductance
            mu0 = 4*pi*1e-7;
            d_pole_square = self.distance.d_pole.^2;
            cst = self.distance.z_size.*(mu0./(2.0.*pi));
            L = cst.*(0.5.*log(d_pole_square./d_square_mat));
            
            % remove the ill-defined elements
            idx_nan = d_square_mat==0;
            L(idx_nan) = 0.0;
        end
        
        function [H_x, H_y] = get_H_xy_intern(self, x, y, I_vec)
            % get the vector magnetic field produced by the original conductors
            %     - x - vector with the x coordinates
            %     - y - vector with the y coordinates
            %     - I_vec - matrix wit the current excitation of the conductors
            %     - H_x - matrix with the x componenent of the magnetic field
            %     - H_y - matrix with the y componenent of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the distance between the given coordinates and the original conductors
            [x_mat,x_c_mat] = self.get_matrix_coordinate(x, self.conductor.x);
            [y_mat,y_c_mat] = self.get_matrix_coordinate(y, self.conductor.y);
            d_square_mat = (x_mat-x_c_mat).^2+(y_mat-y_c_mat).^2;
            x_mat = x_mat-x_c_mat;
            y_mat = y_mat-y_c_mat;
            
            % correction if the conductor radius if the field is evaluated inside a conductor
            r_square_mat = ones(size(d_square_mat,1), 1)*(self.conductor.d_c./2.0).^2;
            idx = d_square_mat<r_square_mat;
            d_square_mat(idx) = r_square_mat(idx);
            
            % compute the field
            [H_x, H_y] = self.get_H_xy_sub(x_mat, y_mat, d_square_mat, I_vec);
        end
        
        function [H_x, H_y] = get_H_xy_extern(self, x, y, I_vec)
            % get the vector magnetic field produced by the mirrored conductors
            %     - x - vector with the x coordinates
            %     - y - vector with the y coordinates
            %     - I_vec - matrix wit the current excitation of the conductors
            %     - H_x - matrix with the x componenent of the magnetic field
            %     - H_y - matrix with the y componenent of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the distance between the given coordinates and the mirrored conductors
            [x_mat,x_c_mat] = self.get_matrix_coordinate(x, self.conductor_mirror.x);
            [y_mat,y_c_mat] = self.get_matrix_coordinate(y, self.conductor_mirror.y);
            d_square_mat = (x_mat-x_c_mat).^2+(y_mat-y_c_mat).^2;
            x_mat = x_mat-x_c_mat;
            y_mat = y_mat-y_c_mat;
            
            % set the conductor with the corresponding weighting
            I_c = repmat(self.conductor_mirror.k.', 1, size(I_vec, 2)).*I_vec(self.conductor_mirror.idx_conductor, :);
            
            % compute the field
            [H_x, H_y] = self.get_H_xy_sub(x_mat, y_mat, d_square_mat, I_c);
        end
        
        function [H_x, H_y] = get_H_xy_sub(self, x_mat, y_mat, d_square_mat, I_vec)
            % get the vector magnetic field produced by the mirrored conductors
            %     - x_mat - matrix with the x coordinates (difference between points and conductors)
            %     - y_mat - matrix with the y coordinates (difference between points and conductors)
            %     - d_square_mat - matrix with the square of the distances
            %     - I_vec - matrix wit the current excitation of the conductors
            %     - H_x - matrix with the x componenent of the magnetic field
            %     - H_y - matrix with the y componenent of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % compute the distance
            H_x_tmp = -y_mat./d_square_mat;
            H_y_tmp = x_mat./d_square_mat;
            
            % compute the field
            cst = 1.0./(2.*pi);
            H_x = cst.*H_x_tmp*I_vec;
            H_y = cst.*H_y_tmp*I_vec;
            
            % remove the ill-defined elements
            idx_nan = any(d_square_mat==0, 2);
            H_x(idx_nan, :) = NaN;
            H_y(idx_nan, :) = NaN;
        end
        
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
    end
end