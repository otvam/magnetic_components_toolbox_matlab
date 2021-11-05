% =================================================================================================
% Compute the losses using GSE and IGSE.
% =================================================================================================
%
% Compute the losses with GSE.
% Compute the losses with IGSE.
%
% =================================================================================================
%
% See also:
%     - core_material (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_steinmetz_losses < handle
    %% init
    methods (Access = public)
        function self = core_steinmetz_losses()
            % create the object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % pass
        end
    end
    
    %% public api
    methods (Access = public)
        function P = get_P_gse(self, param, f, B_peak)
            % get the losses density computed with the GSE (sinusoidal flux)
            %     - param - struct with the steinmetz parameters
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - P - scalar with the losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            P = param.k.*f.^param.alpha.*(B_peak).^param.beta;
        end
        
        function P = get_P_isge(self, param, f, d_vec, B_vec)
            % get the losses density computed with the IGSE (arbitrary flux)
            %     - param - struct with the steinmetz parameters
            %     - f - scalar with the frequency
            %     - d_vec - vector with the normalized (to [0.0, 1.0]) where the flux density is defined
            %     - B_vec - vector with the piecewise linear flux density
            %     - P - scalar with the losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the time intervals
            d_vec_diff = [diff(d_vec) 1.0-d_vec(end)+d_vec(1)];
            t_vec_diff = d_vec_diff./f;
            
            % find the flux variations
            B_vec_tmp = [B_vec B_vec(1)];
            d_B_diff = (B_vec_tmp(2:end)-B_vec_tmp(1:end-1));
            
            % remove zero interval
            idx = t_vec_diff==0;
            t_vec_diff(idx) = [];
            d_B_diff(idx) = [];
            
            % peak to peak flux density
            B_peak_peak = max(B_vec)-min(B_vec);
            
            % apply IGSE
            v_int = sum((abs(d_B_diff./t_vec_diff).^param.alpha).*t_vec_diff);
            v_cst = f.*param.ki.*B_peak_peak.^(param.beta-param.alpha);
            P = v_cst.*v_int;
        end
        
        function [B_peak, B_dc] = get_param_waveform(self, d_vec, B_vec)
            % get the peak and DC flux density from a piecewise linear flux
            %     - d_vec - vector with the normalized (to [0.0, 1.0]) where the flux density is defined
            %     - B_vec - vector with the piecewise linear flux density
            %     - B_peak - peak (and not peak to peak) flux density
            %     - B_dc - average (DC) flux density
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % peak flux density
            B_peak = (max(B_vec)-min(B_vec))./2.0;
            
            % average flux density
            d_vec_diff = [diff(d_vec) 1.0-d_vec(end)+d_vec(1)];
            B_vec_tmp = [B_vec B_vec(1)];
            d_B_mean = (B_vec_tmp(2:end)+B_vec_tmp(1:end-1))./2.0;
            B_dc = abs(sum(d_vec_diff.*d_B_mean));
        end
    end
end