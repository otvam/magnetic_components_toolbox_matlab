% =================================================================================================
% Compute the magnetic reluctance of the core elements and air gaps.
% =================================================================================================
%
% Reluctance models for core elements and air gaps.
% Check the valididy of the geometry.
% All static class.
%
% =================================================================================================
%
% See also:
%     - reluctance_method (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef reluctance_element < handle
    %% public api
    methods (Static, Access = public)
        function R_tmp = get_reluctance_type(element)
            % create the object
            %     - element - struct with the definition of core element or air gap
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the right type (reluctance, magnetic length, magnetic area)
            switch element.type
                case 'magnetic'
                    R_tmp = reluctance_element.get_reluctance_magnetic(element.data);
                case 'stab'
                    R_tmp = reluctance_element.get_reluctance_stab(element.data);
                case 'corner'
                    R_tmp = reluctance_element.get_reluctance_corner(element.data);
                case 'gap_simple'
                    R_tmp = reluctance_element.get_reluctance_gap_simple(element.data);
                case 'gap_stab_stab'
                    R_tmp = reluctance_element.get_reluctance_gap_stab_stab(element.data);
                case 'gap_stab_half_plane'
                    R_tmp = reluctance_element.get_reluctance_gap_stab_half_plane(element.data);
                case 'gap_stab_full_plane'
                    R_tmp = reluctance_element.get_reluctance_gap_stab_full_plane(element.data);
                otherwise
                    error('invalid type')
            end
            
            % set type
            R_tmp.type = element.type;
        end
        
        function R_tmp = get_reluctance_magnetic(data)
            % get the reluctance of a element with given magnetic parameters
            %     - data - struct with the parameter of the element
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            % l_mag: magnetic length
            % A_mag: magnetic area
            % mu: permeability
            validateattributes(data.l_mag, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.A_mag, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.mu, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute reluctance
            R_tmp = reluctance_element.set_R_sub(data.l_mag, data.A_mag, data.mu);
        end
        
        function R_tmp = get_reluctance_stab(data)
            % get the reluctance of a magnetic core stab
            %     - data - struct with the parameter of the element
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            % d_l: length
            % d_stab: width of the stab
            % z_core: tickness of the core
            % mu: permeability
            validateattributes(data.d_l, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.d_stab, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.z_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.mu, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute reluctance
            l = data.d_l;
            A = data.z_core.*data.d_stab;
            R_tmp = reluctance_element.set_R_sub(l, A, data.mu);
        end
        
        function R_tmp = get_reluctance_corner(data)
            % get the reluctance of a magnetic core corner
            %     - data - struct with the parameter of the element
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            % d_a: first length
            % d_b: second length
            % z_core: tickness of the core
            % mu: permeability
            validateattributes(data.d_a, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.d_b, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.z_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.mu, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute reluctance
            l = (pi./8.0).*(data.d_a+data.d_b);
            A = data.z_core.*(data.d_a+data.d_b)./2.0;
            R_tmp = reluctance_element.set_R_sub(l, A, data.mu);
        end
        
        function R_tmp = get_reluctance_gap_simple(data)
            % get the reluctance of an air gap with a simple model (no frinding field)
            %     - data - struct with the parameter of the element
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            % d_gap: length
            % d_stab: width of the stab
            % z_core: tickness of the core
            validateattributes(data.d_gap, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.d_stab, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.z_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.mu, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute reluctance
            l = data.d_gap;
            A = data.z_core.*data.d_stab;
            R_tmp = reluctance_element.set_R_sub(l, A, data.mu);
        end
        
        
        function R_tmp = get_reluctance_gap_stab_stab(data)
            % get the reluctance of an air gap composed by two stabs
            %     - data - struct with the parameter of the element
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fct = @reluctance_element.get_R_gap_stab_stab;
            R_tmp = reluctance_element.set_R_gap_sub(data, fct);
        end
        
        function R_tmp = get_reluctance_gap_stab_half_plane(data)
            % get the reluctance of an air gap composed by a stab and an infinite half plane
            %     - data - struct with the parameter of the element
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fct = @reluctance_element.get_R_gap_stab_half_plane;
            R_tmp = reluctance_element.set_R_gap_sub(data, fct);
        end
        
        function R_tmp = get_reluctance_gap_stab_full_plane(data)
            % get the reluctance of an air gap composed by a stab and an infinite full plane
            %     - data - struct with the parameter of the element
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fct = @reluctance_element.get_R_gap_stab_full_plane;
            R_tmp = reluctance_element.set_R_gap_sub(data, fct);
        end
    end
    
    %% private api
    methods (Static, Access = private)
        function R_tmp = set_R_sub(l, A, mu)
            % set a magnetic element (core element or air gap)
            %     - l - scalar with the magnetic length
            %     - A - scalar with the magnetic area
            %     - mu - scalar with the magnetic permeability
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            mu0 = 4*pi*1e-7;
            R = l./(mu0.*mu.*A);
            
            R_tmp.l = l;
            R_tmp.A = A;
            R_tmp.R = R;
        end
        
        function R_tmp = set_R_gap_sub(data, fct)
            % set a magnetic element for an air gap
            %     - data - struct with the parameter of the element
            %     - fct - function handler to the corresponding air gap type
            %     - R_tmp - struct with the computed magnetic parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            % d_stab: width of the stab
            % z_core: tickness of the core
            % d_gap: length of the air gap
            % d_corner: distance to the next corner (for the stab)
            validateattributes(data.d_gap, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.d_stab, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.d_corner, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.z_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(data.mu, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute the fringing effect
            sigma_1 = reluctance_element.get_sigma(data.d_gap, data.d_stab, data.d_corner, fct);
            sigma_2 = reluctance_element.get_sigma(data.d_gap, data.z_core, data.d_corner, fct);
            sigma = sigma_1.*sigma_2;
            
            % set the equivalent magnetic area
            l = data.d_gap;
            A = (data.z_core.*data.d_stab)./sigma;
            R_tmp = reluctance_element.set_R_sub(l, A, data.mu);
        end
        
        function sigma = get_sigma(d_gap, d_stab, d_corner, fct)
            % get the fringing effect correction factor
            %     - d_gap: scalar with the length of the air gap
            %     - d_stab: scalar with the width of the stab
            %     - d_corner: scalar with the distance to the next corner (for the stab)
            %     - fct - function handler to the corresponding air gap type
            %     - sigma - scalar with the fringing effect correction factor
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            R_prime_gap = fct(d_gap, d_stab, d_corner);
            R_prime_ref = d_gap./d_stab;
            sigma = R_prime_gap./R_prime_ref;
        end
        
        function R_prime = get_R_gap_stab_stab(d_gap, d_stab, d_corner)
            % get the (scaled in per unit) reluctance for an air gap between two stabs
            %     - d_gap: scalar with the length of the air gap
            %     - d_stab: scalar with the width of the stab
            %     - d_corner: scalar with the distance to the next corner (for the stab)
            %     - R_prime - scalar with the reluctance
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            s_gap_half = reluctance_element.get_s_gap_sub(d_gap./2.0, d_stab, d_corner);
            R_prime = 1./(s_gap_half./2.0+s_gap_half./2.0);
        end
        
        function R_prime = get_R_gap_stab_half_plane(d_gap, d_stab, d_corner)
            % get the (scaled in per unit) reluctance for an air gap between a stab and a half plane
            %     - d_gap: scalar with the length of the air gap
            %     - d_stab: scalar with the width of the stab
            %     - d_corner: scalar with the distance to the next corner (for the stab)
            %     - R_prime - scalar with the reluctance
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            s_gap_half = reluctance_element.get_s_gap_sub(d_gap./2.0, d_stab, d_corner);
            s_gap_full = reluctance_element.get_s_gap_sub(d_gap, d_stab, d_corner);
            R_prime = 1./(s_gap_half./2.0+s_gap_full);
        end
        
        function R_prime = get_R_gap_stab_full_plane(d_gap, d_stab, d_corner)
            % get the (scaled in per unit) reluctance for an air gap between a stab and a full plane
            %     - d_gap: scalar with the length of the air gap
            %     - d_stab: scalar with the width of the stab
            %     - d_corner: scalar with the distance to the next corner (for the stab)
            %     - R_prime - scalar with the reluctance
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            s_gap_full = reluctance_element.get_s_gap_sub(d_gap, d_stab, d_corner);
            R_prime = 1./(s_gap_full+s_gap_full);
        end
        
        function s_gap = get_s_gap_sub(l, w, h)
            % get the magnetic length for an air gap
            %     - l: scalar with the length of air gap
            %     - w: scalar with the width of air gap
            %     - h: scalar with the distance to the next corner (for the stab)
            %     - s_gap - scalar with the magnetic length
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            s_gap_1 = w./(2.0.*l);
            s_gap_2 = (2.0./pi).*(1.0+log((pi.*h)./(4.0.*l)));
            s_gap = s_gap_1+s_gap_2;
        end
    end
end
