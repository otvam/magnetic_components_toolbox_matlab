% =================================================================================================
% Reluctance solver for magnetic circuit with core and air gaps.
% =================================================================================================
%
% Reluctance solver taking into account:
%     - core and air gap elements
%     - core with many parallel limbs
%     - multiple source (windings)
%
% The following element are considered:
%     - magnetic core stab
%     - magnetic core corner
%     - air gap type 1 (stab to stab)
%     - air gap type 2 (stab to half plane)
%     - air gap type 3 (stab to plane)
%
% A 3D approximation of the fringing field is used.
% All the limbs are connected in paralle.
% One or many winding can be connected per limb.
%
% =================================================================================================
%
% Warning: Reluctance models are approximations.
%          The validity of the model short be controlled for each geometry.
%
% =================================================================================================
%
% References:
%     - Muehlethaler, J. / Modeling and multi-objective optimization of inductive power components / ETHZ / 2012
%     - Muehlethaler, J. and Kolar, J.W. and Ecklebe, A. / A Novel Approach for 3D Air Gap Reluctance Calculations / ECCE / 2011
%
% See also:
%     - reluctance_element (compute reluctance of core or air gap elements)
%     - reluctance_limb (compute reluctance of a limb)
%     - reluctance_solve (solve the reluctance problem)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef reluctance_method < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        reluctance_solve_obj % instance of reluctance_solve
        reluctance_limb_obj % instance of reluctance_limb
    end
    
    %% init
    methods (Access = public)
        function self = reluctance_method(limb, source)
            % create the object
            %     - limb - struct with the definition of the limbs with the reluctances
            %     - source - struct with the definition of the magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % create the limbs and compute reluctances
            self.reluctance_limb_obj = reluctance_limb(limb);
            
            % init the solver
            limb_element_sum = self.reluctance_limb_obj.get_limb_element_sum();
            self.reluctance_solve_obj = reluctance_solve(limb_element_sum, source);
        end
    end
    
    %% public api - get data limb
    methods (Access = public)
        function limb = get_limb(self)
            % get the user defined limbs (geometry, material)
            %     - limb - struct with the user defined limbs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            limb = self.reluctance_limb_obj.get_limb();
        end
        
        function limb_element = get_limb_element(self)
            % get the magnetic properties of the limbs
            %     - limb_element - struct with the magnetic properties of the limbs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            limb_element = self.reluctance_limb_obj.get_limb_element();
        end
        
        function limb_element_sum = get_limb_element_sum(self)
            % get the total reluctance per limb
            %     - limb_element_sum - struct with the total reluctance per limb
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            limb_element_sum = self.reluctance_limb_obj.get_limb_element_sum();
        end
    end
    
    %% public api - get data solve
    methods (Access = public)
        function source = get_source(self)
            % get the user defined magnetic sources
            %     - source - struct with the user defined magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            source = self.reluctance_solve_obj.get_source();
        end
        
        function inductance = get_inductance(self)
            % get the inductance matrix between the sources
            %     - inductance - struct with the inductance matrix
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            inductance = self.reluctance_solve_obj.get_inductance();
        end
        
        function phi_limb = get_phi_limb(self, excitation)
            % get the flux inside the limbs
            %     - excitation - struct with the current excitation of the sources
            %     - phi_limb - struct with the flux inside the limbs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            phi_limb = self.reluctance_solve_obj.get_phi_limb(excitation);
        end
        
        function psi_source = get_psi_source(self, excitation)
            % get the flux linkage of the sources
            %     - excitation - struct with the current excitation of the sources
            %     - psi_source - struct with the flux linkage of the sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            psi_source = self.reluctance_solve_obj.get_psi_source(excitation);
        end
    end
end