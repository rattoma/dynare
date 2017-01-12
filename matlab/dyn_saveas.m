function dyn_saveas(h,fname,DynareOptions)
%function dyn_saveas(h,fname,DynareOptions)
% save figures for DYNARE
%
% INPUTS
%    h     : figure handle
%    fname : name of the saved figure
%    DynareOptions: dynare options
%
% OUTPUTS
%    none
%
% SPECIAL REQUIREMENTS
%    none

% Copyright (C) 2012-2013 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

if any(strcmp('eps',cellstr(DynareOptions.graph_format)))
    if isoctave
        fname = strrep(fname,'/',filesep);
        fname = strrep(fname,'\',filesep);
        if DynareOptions.nodisplay && ispc,
            set(h, 'Visible','on');
        end
    end
    print(h,'-depsc2',[fname,'.eps']) 
end
if any(strcmp('pdf',cellstr(DynareOptions.graph_format)))
    if isoctave
        error('Octave cannot create pdf files!')
    else
        print(h,'-dpdf',[fname,'.pdf']) 
    end
end
if any(strcmp('fig',cellstr(DynareOptions.graph_format)))
    if isoctave
        error('Octave cannot create fig files!')
    else
        if DynareOptions.nodisplay
%  THE FOLLOWING LINES COULD BE USED IF BUGS/PROBLEMS ARE REPORTED USING LINE 60		
%             set(h,'Units','Normalized')
%             mypos=get(h,'Position');
%             set(h,'Position',[-1 -1 mypos(3:4)])
%             set(h, 'Visible','on');
            set(h,'CreateFcn','set(gcf, ''Visible'',''on'')') ;
        end
        saveas(h,[fname '.fig']);
    end
end
if any(strcmp('none',cellstr(DynareOptions.graph_format)))
% don't save
% check here as a reminder that none is an option to graph_format
end
if DynareOptions.nodisplay
    close(h);
end
