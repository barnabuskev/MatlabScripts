%Usage: load5([OPTIONS],filename,var1,var2,...)
%       load5 [OPTIONS] filename var1 var2 ...
%       load5 [OPTIONS] filename var1as=var1 var2as=var2
%
%  Loads a Matlab MAT version 5 compatible matlab file
%
%  OPTIONS
%    --help          - This output
%    --version       - version information
%    --prefix PREFIX - prepends PREFIX to variables loaded from MAT file
%                      except variable names explicitly set using '='
%    --suffix SUFFIX - appends SUFFIX to variables loaded from MAT file
%                      except variable names explicitly set using '='
%
%  INPUT:
%    filename - MAT filename with .mat extension
%  OPTIONAL INPUT:
%    var1     - Name of variable to load
%    :
%    var#     - Name of variable to load
%
%  EXAMPLES:
%    >> load5 --prefix pre_ --suffix _suf dem dLat dLon TerrainHeight=th
%    >> whos
%      Name               Size                   Bytes  Class
%    
%      pre_dLat_suf       1x1                        8  double array
%      pre_dLon_suf       1x1                        8  double array
%      th              1440x1441               2075040  uint8 array
%    
%    Grand total is 2075042 elements using 2075056 bytes
%      
%    >>
%
%
%    >> load5('--prefix','pre_','--suffix','_suf','dem.mat');
%    >> whos
%      Name                            Size                   Bytes  Class
%    
%      pre_SouthmostLatitude_suf       1x1                        8  double array
%      pre_TerrainHeight_suf        1440x1441               2075040  uint8 array
%      pre_WestmostLongitude_suf       1x1                        8  double array
%      pre_dLat_suf                    1x1                        8  double array
%      pre_dLon_suf                    1x1                        8  double array
%    
%    Grand total is 2075044 elements using 2075072 bytes
%    
%    >>
