function sofaStripped = loadSofaFile(hrtf_sofa_path)
% LOADSOFAFILE Extract HRIRs and source positions from an HRTF sofa file
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
% Author:   Leo McCormack (leomccormack@aalto.fi)
% Copyright (C) 2021 - Leo McCormack
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
% hrtf_sofa_path    % full path/filename to SOFA file
%
% OUTPUT ARGUMENTS
%
% sofaStripped      % MATLAB structure holding HRIRs, HRIR samplerate, and
%                     measurement directions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Info on sofa file
%ncdisp(hrtf_sofa_path)

%% Open sofa file and determine dimension IDs and lengths
ncid = netcdf.open(hrtf_sofa_path, 'NOWRITE'); % read-only access
for i=1:6% there are 6 dimensions in the sofa standard
    [dimname(i,1), dimlen(i,1)] = netcdf.inqDim(ncid,i-1); %#ok
    dimid(i,1) = netcdf.inqDimID(ncid,dimname(i,1)); %#ok
end  
varname = 'DataType';
DataType = netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),varname);

%% Extract IR data
varname = 'Data.IR';
varid = netcdf.inqVarID(ncid,varname); 
%[~, ~, dimids, ~] = netcdf.inqVar(ncid,varid);
%IR_dim1 = dimlen(dimid(dimids(1,1)+1)+1); %+1s only for MatLab
%IR_dim2 = dimlen(dimid(dimids(1,2)+1)+1);
%IR_dim3 = dimlen(dimid(dimids(1,3)+1)+1); 
IR = netcdf.getVar(ncid,varid); 
varname = 'Data.SamplingRate';
varid = netcdf.inqVarID(ncid,varname); 
IR_fs = netcdf.getVar(ncid,varid);   

%% Extract positional data
varname = 'SourcePosition';
varid = netcdf.inqVarID(ncid,varname);
%[~, ~, dimids, ~] = netcdf.inqVar(ncid,varid);
%SourcePosition_dim1 = dimlen(dimid(dimids(1,1)+1)+1); %+1s only for MatLab
%SourcePosition_dim2 = dimlen(dimid(dimids(1,2)+1)+1);  
SourcePosition = netcdf.getVar(ncid,varid);

%% Stripped down sofa info
sofaStripped.DataType = DataType;
sofaStripped.IR = IR;
sofaStripped.IR_fs = IR_fs;
sofaStripped.SourcePosition = SourcePosition;
%sofaStripped

%% Close sofa file, once info extracted
netcdf.close(ncid);

end
