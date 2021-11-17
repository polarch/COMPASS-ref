function p = getPvalue(DTT,f)
% GETPVALUE used for the frequency-dependent normalisation of VBAP gains
%
% For more information, refer to:
%     Laitinen, M., Vilkamo, J., Jussila, K., Politis, A., Pulkki, V.
%     (2014). Gain normalisation in amplitude panning as a function of
%     frequency and room reverberance. 55th International Conference of
%     the AES. Helsinki, Finland
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This file is part of the COMPASS reference implementation, as described
% in the publication
%
%   Archontis Politis, Sakari Tervo, and Ville Pulkki. 2018. 
%   "COMPASS: Coding and multidirectional parameterization of ambisonic 
%   sound scenes." 
%   IEEE Int. Conf. on Acoustics, Speech and Signal Processing (ICASSP).
%
% Author:   Archontis Politis (archontis.politis@gmail.com)
% Copyright (C) 2021 - Archontis Politis
% 
% The COMPASS reference code is free software; you can redistribute it 
% and/or modify it under the terms of the GNU General Public License as 
% published by the Free Software Foundation; either version 2 of the 
% License, or (at your option) any later version.
% 
% The COMPASS reference code is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program; if not, see <https://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT ARGUMENTS
%
% f    frequency vector
% DTT  normal room (p=2) DTT = 1:  anechoic room (p<2)
%
% OUTPUT ARGUMENTS
%
% p    pValues per frequency
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    a1 = 0.00045;
    a2 = 0.000085;
    p0 = 1.5 - 0.5 * cos(4.7*tanh(a1*f)).*max(0,1-a2*f);
    p = (p0-2)*sqrt(DTT)+2;

end
