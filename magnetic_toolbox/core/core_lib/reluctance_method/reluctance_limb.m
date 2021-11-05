% =================================================================================================
% Compute the magnetic reluctance of the limbs.
% =================================================================================================
%
% Compute the magnetic reluctance.
% Sum the reluctance per limb.
%
% =================================================================================================
%
% See also:
%     - reluctance_method (main class)
%     - reluctance_element (compute reluctance of core or air gap elements)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef reluctance_limb < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        limb % struct with the user defined limbs
        limb_element % struct with the magnetic properties of the limbs
        limb_element_sum % struct with the total reluctance per limb
    end
    
    %% init
    methods (Access = public)
        function self = reluctance_limb(limb)
            % create the object
            %     - source - struct with the definition of the magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.limb = limb;
            self.init_limb_element()
        end
    end
    
    %% public api
    methods (Access = public)
        function limb = get_limb(self)
            % get the user defined limbs (geometry, material)
            %     - limb - struct with the user defined limbs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            limb = self.limb;
        end
        
        function limb_element = get_limb_element(self)
            % get the magnetic properties of the limbs
            %     - limb_element - struct with the magnetic properties of the limbs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            limb_element = self.limb_element;
        end
        
        function limb_element_sum = get_limb_element_sum(self)
            % get the total reluctance per limb
            %     - limb_element_sum - struct with the total reluctance per limb
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            limb_element_sum = self.limb_element_sum;
        end
    end
    
    %% private api
    methods (Access=private)
        function init_limb_element(self)
            % compute the magnetic properties of the different limbs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            assert(isstruct(self.limb), 'invalid data')
            
            field = fieldnames(self.limb);
            for i=1:length(field)
                [limb_element_tmp, R_sum] = self.init_limb_element_sub(self.limb.(field{i}));
                self.limb_element.(field{i}) = limb_element_tmp;
                self.limb_element_sum.(field{i}) = R_sum;
            end
        end
        
        function [limb_element_tmp, R_sum] = init_limb_element_sub(self, limb_tmp)
            % compute the magnetic properties of a specific different limb
            %     - limb_tmp - struct with the limb data
            %     - limb_element_tmp - struct with the computed magnetic parameters
            %     - R_sum - total reluctance of the limb
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            assert(isstruct(limb_tmp), 'invalid data')
            
            R_sum = 0.0;
            field = fieldnames(limb_tmp);
            for i=1:length(field)
                R_tmp = reluctance_element.get_reluctance_type(limb_tmp.(field{i}));
                
                limb_element_tmp.(field{i}) = R_tmp;
                R_sum = R_sum+R_tmp.R;
            end
        end
    end
end