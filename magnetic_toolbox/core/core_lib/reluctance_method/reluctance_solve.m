% =================================================================================================
% Solve the reluctance problem for a magnetic circuit.
% =================================================================================================
%
% Magnetic circuit with parallel limbs.
% Arbitrary number of sources.
% Compute the flux and inductance.
%
% =================================================================================================
%
% See also:
%     - reluctance_method (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef reluctance_solve < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        limb_element_sum % struct with the total reluctance per limb
        source % struct with the definition of the magnetic sources
        
        field_limb_element_sum % cell with the name of the limbs
        field_source % cell with the name of the source
        phi_mat % flux matrix (for the limb) with normalized excitation
        source_limb_mat % link matrix between the source and the limb excitation
    end
    
    %% init
    methods (Access = public)
        function self = reluctance_solve(limb_element_sum, source)
            % create the object
            %     - limb - struct with the total reluctance per limb
            %     - source - struct with the definition of the magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.limb_element_sum = limb_element_sum;
            self.source = source;
            
            % get the field name (in order to have a constant order)
            self.field_limb_element_sum = fieldnames(self.limb_element_sum);
            self.field_source = fieldnames(self.source);
            
            % init the matrix
            self.init_phi_mat();
            self.init_source_limb_mat();
        end
    end
    
    %% public api
    methods (Access = public)
        function source = get_source(self)
            % get the user defined magnetic sources
            %     - source - struct with the user defined magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            source = self.source;
        end
        
        function limb_element_sum = get_limb_element_sum(self)
            % get the total reluctance per limb
            %     - limb_element_sum - struct with the total reluctance per limb
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            limb_element_sum = self.limb_element_sum;
        end
        
        function inductance = get_inductance(self)
            % get the inductance matrix between the sources
            %     - inductance - struct with the inductance matrix
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the matrix
            L_mat = (self.source_limb_mat.')*self.phi_mat*self.source_limb_mat;
            
            % assign the matrix to struct
            inductance = self.set_inductance_mat(L_mat);
        end
        
        function phi_limb = get_phi_limb(self, excitation)
            % get the flux inside the limbs
            %     - excitation - struct with the current excitation of the sources
            %     - phi_limb - struct with the flux inside the limbs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the source vector
            I_source_vec = self.get_current_vec(excitation);
            
            % get the flux
            I_limb_vec = self.source_limb_mat*I_source_vec;
            phi_limb_vec = self.phi_mat*I_limb_vec;
            
            % assign the vector to struct
            phi_limb = self.set_phi_limb_vec(phi_limb_vec);
        end
        
        function psi_source = get_psi_source(self, excitation)
            % get the flux linkage of the sources
            %     - excitation - struct with the current excitation of the sources
            %     - psi_source - struct with the flux linkage of the sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the source vector
            I_source_vec = self.get_current_vec(excitation);
            
            % get the flux linkage
            I_limb_vec = self.source_limb_mat*I_source_vec;
            phi_limb_vec = self.phi_mat*I_limb_vec;
            psi_source_vec = (self.source_limb_mat.')*phi_limb_vec;
            
            % assign the vector to struct
            psi_source = self.set_psi_source_vec(psi_source_vec);
        end
    end
    
    %% private api
    methods (Access = private)
        function init_phi_mat(self)
            % init the flux matrix (for the limb) with normalized excitation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the reluctance matrix (diagonal)
            n_limb = length(self.field_limb_element_sum);
            for i=1:n_limb
                R_tmp =  self.limb_element_sum.(self.field_limb_element_sum{i});
                validateattributes(R_tmp, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                R_vec(i) = R_tmp;
            end
            R_mat = diag(R_vec);
            
            % solve the reluctance problem with a normalized excitation per lilmb
            if n_limb==1
                self.phi_mat = 1./R_mat;
            else
                A = [R_mat ones(n_limb, 1) ; ones(1, n_limb) 0.0];
                b = [eye(n_limb, n_limb) ; zeros(1, n_limb)];
                x = A\b;
                self.phi_mat = x(1:n_limb, :);
            end
        end
        
        function init_source_limb_mat(self)
            % init the link matrix between the source and the limb excitation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init the matrix
            n_source = length(self.field_source);
            n_limb = length(self.field_limb_element_sum);
            self.source_limb_mat = zeros(n_limb, n_source);
            
            % fill the matrix
            for i=1:n_source
                source_tmp = self.source.(self.field_source{i});
                
                % find the limb assigned to the source
                idx_limb = strcmp(source_tmp.limb, self.field_limb_element_sum);
                assert(nnz(idx_limb)==1, 'invalid limb');
                
                % check to source
                validateattributes(source_tmp.n, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                
                % assign the current turn product
                self.source_limb_mat(idx_limb, i) = source_tmp.n;
            end
        end
        
        function I_source_vec = get_current_vec(self, excitation)
            % convert the excitation struct to a current vector
            %     - excitation - struct with the current excitation of the sources
            %     - I_source_vec - vector with the source current (matrix if many currents are provided)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_source = length(self.field_source);
            for i=1:n_source
                I_source_vec_tmp = excitation.source.(self.field_source{i});
                
                validateattributes(I_source_vec_tmp, {'double'},{'row', 'nonempty', 'nonnan','finite'});
                assert(length(I_source_vec_tmp)==excitation.n, 'invalid data');
                
                I_source_vec(i,:) = I_source_vec_tmp;
            end
        end
        
        function inductance = set_inductance_mat(self, L_mat)
            % convert the inductance matrix to an inductance struct
            %     - L_mat - matrix with the inductances
            %     - inductance - struct with the inductances
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_source = length(self.field_source);
            for i=1:n_source
                for j=1:n_source
                    inductance.(self.field_source{i}).(self.field_source{j}) = L_mat(i,j);
                end
            end
        end
        
        function phi_limb = set_phi_limb_vec(self, phi_limb_vec)
            % convert the flux vector to a struct
            %     - phi_limb_vec - vector with the flux
            %     - phi_limb - struct with the flux
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_limb = length(self.field_limb_element_sum);
            for i=1:n_limb
                phi_limb.(self.field_limb_element_sum{i}) = phi_limb_vec(i,:);
            end
        end
        
        function psi_source = set_psi_source_vec(self, psi_source_vec)
            % convert the flux linkage vector to a struct
            %     - psi_source_vec - vector with the flux linkage
            %     - psi_source - struct with the flux linkage
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_source = length(self.field_source);
            for i=1:n_source
                psi_source.(self.field_source{i}) = psi_source_vec(i,:);
            end
        end
    end
end