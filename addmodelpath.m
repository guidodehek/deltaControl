function returnval = addmodelpath(varargin)
% ADDMODELPATH adds first level directories to path
% example:
%   addmodelpath;
%   addmodelpath('SilentMode',1); (only R2014b+)
%
% See also: -

% Copyright	2006-2014 Strukton Rolling Stock BV

ST=dbstack(1);
in_recurse=0;
for k=1:length(ST)
    if strcmp(ST(k).name,'addmodelpath')
        in_recurse=1; break;
    end
end

returnval=[]; %#ok<*NASGU>
if ~isempty(varargin)
    p = inputParser;    % Create an instance of the class.
    addParameter(p,'SilentMode', 0);
    p.parse(varargin{:});
else
    p.Results.SilentMode=0;
end

SilentMode=p.Results.SilentMode;

if ~in_recurse % if this is not a nested addmodelpath
    % Reset the Matlab search path to the path's defined in pathdef.m
    path(pathdef);
    if ~SilentMode
        disp(' ');
        disp('Resetting the Matlab search path to the default search path.');
    end
    
end

% Search the current directory for sub directories and add them to the
% Matlab search path.
try
    CurrentPath = pwd;
    if ~SilentMode
        disp(' ');
        disp(['The current path is:' CurrentPath]);
        disp('Added directories are:');
    end
    files = dir('.');
    
    verconstraints(1).minSL=0;
    verconstraints(1).maxSL=7.7;
    verconstraints(1).dirspec='LEVEL1';
    verconstraints(1).action='include';

    verconstraints(2).minSL=8.3;
    verconstraints(2).maxSL=Inf;
    verconstraints(2).dirspec='LEVEL2';
    verconstraints(2).action='include';
    
    for i=1:length(files)
        if files(i).isdir == 1
            if files(i).name(1) ~= '.'
                % don't include LEVEL2 data object definition for R2011a
                % and below
                DirToInclude=[CurrentPath filesep files(i).name];
                Include=checkminmaxSLversion(DirToInclude,verconstraints);
                if Include
                    addpath(DirToInclude);
                    if ~SilentMode
                        disp (DirToInclude);
                    end
                end
                if isdir([files(i).name '\Images'])
                    addpath([CurrentPath filesep files(i).name '\Images']);
                    if ~SilentMode
                        disp ([CurrentPath filesep files(i).name '\Images']);
                    end
                end
                
            end
        end
    end
    
    if ~SilentMode
        disp('The directories in the current path are added to the MATLAB search path.');
    end
    
    rehash;
    pathscripts=which('addmodelpath','-all');
    if length(pathscripts)>1 && ~in_recurse
        for k=2:length(pathscripts)
            eval(['run(''' pathscripts{k} ''');']);
        end
    end
  
    rehash;
    
    returnval=1;
catch ME
    if ~SilentMode
        disp(getReport(ME));
    end
    returnval=[];
end

function isInclude = checkminmaxSLversion(checkpath,verconstraints)
isInclude=1;
SL_info=ver('Simulink');
if ~isempty(SL_info)
    SLver=str2double(SL_info.Version);
    for k=1:length(verconstraints)
        curConstraint=verconstraints(k);
        if strcmpi(curConstraint.action,'include')
            if ~isempty(strfind(upper(checkpath),curConstraint.dirspec)) % dirspec applies to checkpath
                if ((SLver>curConstraint.maxSL) || (SLver<curConstraint.minSL ))
                    isInclude=0;
                end
            end
        end
    end
    
end

