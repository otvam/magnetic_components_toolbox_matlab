% =================================================================================================
% Implementation of the mirroring method (method of images) for 2D magnetic problem.
% =================================================================================================
%
% Mirroring method for magnetic field computation of conductors surrounded by magnetic materials.
%
% Different boundary conditions are included:
%     - conductors in free space
%     - conductors surrounded by a single magnetic boundary
%     - conductors surrounded by two parallel magnetic boundaries
%     - conductors surrounded by a box of four magnetic boundaries
%
% An infinite or a finite permeability of the BC can be considered.
% The conductors are accepted to be round with an uniform current density.
% The radius and the position of the different conductors is arbitrary.
% No HF effects (skin, proximity, etc.) are considered.
%
% The following results can be extracted:
%     - magnetic field (vector or norm)
%     - inductance matrix
%     - energy
%
% =================================================================================================
%
% Warning: For 2D problem, the energy is infinite for a single conductor (no return path exists).
%          Then the definition of the inductance is ill-formulated.
%          This problem is (partially) adressed by setting a pole at a fixed distance from the conductor.
%          For distances greater than the pole distance, the energy is not anymore considered.
%
% Warning: The convergence of the mirroring problem can be very slow for some problems.
%
% =================================================================================================
%
% References:
%     - Muehlethaler, J. / Modeling and multi-objective optimization of inductive power components / ETHZ / 2012
%     - Ferreira, J.A. / Electromagnetic Modelling of Power Electronic Converters /Kluwer Academics Publishers / 1989.
%     - Bossche, A. and Valchev, V. / Inductors and Transformers for Power Electronics / CRC Press / 2005.
%     - Binns, K.J. and Lawrenson, P. J. / Analysis and Computation of Electric and Magnetic Field Problems / Elsevier/ 1973
%
% See also:
%     - mirror_check (check the validy of the problem)
%     - mirror_conductor (mirror the conductors)
%     - mirror_physics (solve the magnetic field and inductance matrix)
%
% =================================================================================================
% (c) 2016-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod, BSD License
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef mirroring_method < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        bc % user defined boundary condition
        conductor % user defined conductors
        mirror_conductor_obj % instance of mirror_conductor
        mirror_check_obj % instance of mirror_check
        mirror_physics_obj % instance of mirror_physics
    end
    
    %% init
    methods (Access = public)
        function self = mirroring_method(bc, conductor)
            % create the object
            %     - bc - struct with the definition of the BC (type, position, permeability, number of mirror)
            %     - conductor - struct with the definition of the conductor (position, radius, number)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.bc = bc;
            self.conductor = conductor;
            
            % check the validity of the problem
            self.mirror_check_obj = mirror_check(self.bc, self.conductor);
            self.mirror_check_obj.check_data();
            
            % create the mirror
            self.mirror_conductor_obj = mirror_conductor(self.bc, self.conductor);
            
            % create the physics with the conductors and the mirrored conductors
            conductor_mirror = self.mirror_conductor_obj.get_conductor_mirror();
            distance = self.mirror_conductor_obj.get_distance();
            self.mirror_physics_obj = mirror_physics(self.conductor, conductor_mirror, distance);
        end
    end
    
    %% public api
    methods (Access = public)
        function bc = get_bc(self)
            % get the data with the bc
            %     - bc - user defined boundary condition
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            bc = self.bc;
        end
        
        function conductor = get_conductor(self)
            % get the data with the conductors
            %     - conductor - user defined conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            conductor = self.conductor;
        end
        
        function [H_x, H_y] = get_H_xy_position(self, x, y, I_vec)
            % get the vector magnetic field at the defined coordinates
            %     - x - vector with the x coordinates
            %     - y - vector with the y coordinates
            %     - I_vec - matrix wit the current excitation of the conductors
            %     - H_x - matrix with the x componenent of the magnetic field
            %     - H_y - matrix with the y componenent of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.mirror_check_obj.check_x_y(x, y);
            self.mirror_check_obj.check_I_vec(I_vec);
            [H_x, H_y] = self.mirror_physics_obj.get_H_xy(x, y, I_vec);
        end
        
        function H = get_H_norm_position(self, x, y, I_vec)
            % get the norm of the magnetic field at the defined coordinates
            %     - x - vector with the x coordinates
            %     - y - vector with the y coordinates
            %     - I_vec - matrix wit the current excitation of the conductors
            %     - H - matrix with the norm of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.mirror_check_obj.check_x_y(x, y);
            self.mirror_check_obj.check_I_vec(I_vec);
            [H_x, H_y] = self.mirror_physics_obj.get_H_xy(x, y, I_vec);
            H = hypot(abs(H_x), abs(H_y));
        end
        
        function [H_x, H_y] = get_H_xy_conductor(self, I_vec)
            % get the vector magnetic field at the center of the conductors
            %     - I_vec - matrix with the current excitation of the conductors
            %     - H_x - matrix with the x componenent of the magnetic field
            %     - H_y - matrix with the y componenent of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.mirror_check_obj.check_I_vec(I_vec);
            [H_x, H_y] = self.mirror_physics_obj.get_H_xy(self.conductor.x, self.conductor.y, I_vec);
        end
        
        function H = get_H_norm_conductor(self, I_vec)
            % get the norm of the magnetic field at the center of the conductors
            %     - I_vec - matrix with the current excitation of the conductors
            %     - H - matrix with the norm of the magnetic field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.mirror_check_obj.check_I_vec(I_vec);
            [H_x, H_y] = self.mirror_physics_obj.get_H_xy(self.conductor.x, self.conductor.y, I_vec);
            H = hypot(abs(H_x), abs(H_y));
        end
        
        function E = get_E(self, I_vec)
            % get the energy stored in the system
            %     - I_vec - matrix with the current excitation of the conductors
            %     - E - vector with the stored energy
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the inductance matrix
            self.mirror_check_obj.check_I_vec(I_vec);
            L = self.mirror_physics_obj.get_L();
            
            % compute the energy if the matrix is valid
            if any(isnan(L(:)))
                E = NaN(size(I_vec, 1), 1);
            else
                E = (1.0./2.0).*diag((I_vec.'*L)*I_vec);
            end
        end
        
        function L = get_L(self)
            % get the inductance matrix between the conductors
            %     - L - matrix with the inductances
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            L = self.mirror_physics_obj.get_L();
        end
    end
end