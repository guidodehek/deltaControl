% PROJECTPOLISH updates the drawings to a common drawing style.
%
% example:
%  nr_polishs=projectpolish;

% ProjectPolish updates the drawings to a common drawing style
% Returns the number of touched items
% In case you use model references, run the tool on each mref seperately
%
% Inports and Outports:
%   are colored red and green
%   are resized to same size
%   font set to preset size and type
%   name is hidden, except when it doesn't start with the 'standard name'
%   ('In' or 'Out')
%
% Add block
%   name is hidden, except when it doesn't start the 'standard name' ('Add')
%
% Subsystems:
%   font set to preset size and type
%   name is hidden
%
% From and Goto flags:
%   font set to preset size and type
%   are resized to fit content
%
% Constants
%   font set to preset size and type
%   are resized to fit content
%   color set to cyan when datatype inherit
%   color set to yellow when datatype boolean
%   color set to light blue when other
%
% Signal Specifications
%   font set to preset size and type
%   are resized to fit content
%
% Datatype Conversions
%   font set to preset size and type
%   are resized to fit content
%
% Datastores (Read, Write and Name)
%   font set to preset size and type
%   are resized to fit content (also mending multiple signals in
%   bus-structures)
%
% Signal Names
%   font set to preset size and type
%
% Remove BlockNames of all but SubSytem blocks
%
% For most Simulink/Discontinuities-blocks Block Annotation will show
% variable values
%

function countupdates = projectpolish
countupdates=0;

%% Find all Blocks in the System
all_blocks=getfullname(Simulink.findBlocks(gcs));

%% Proces the From-flags

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'From')
            apply_na_0004(curblock,countupdates);
            countupdates=setwhendifferent(curblock{1},'ShowName', 'off',countupdates);
            tmp_len = numel(get_param(curblock{1},'GotoTag'));
            countupdates=block_resize(curblock,20+9*tmp_len,15,'left',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end

%% Proces the Goto-flags
%x=find_system(bdroot, 'BlockType', 'Goto');

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'Goto')
            countupdates=apply_na_0004(curblock,countupdates);
            countupdates=setwhendifferent(curblock{1},'ShowName', 'off',countupdates);
            tmp_len = numel(get_param(curblock{1},'GotoTag'));
            countupdates=block_resize(curblock,20+9*tmp_len,15,'right',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end

%% Proces the Subsystems

% process the lines on top-level
lines = get_param(bdroot,'Lines');
countupdates = format_lines(lines,countupdates);

% Process the blocks
for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'SubSystem')
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',14,countupdates);
            
            if isempty(get_param(curblock{1},'LibraryVersion')) % exclude library components
                %process the lines on lower levels
                lines = get_param(curblock{1},'Lines');
                countupdates = format_lines(lines,countupdates);
            end
        end
    catch
        % Block does not contain BlockType
    end
end

%% Proces the Inports

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'Inport')
            countupdates=apply_hg_0002_inport(curblock,countupdates);
            countupdates=block_resize(curblock,60,15,'right',countupdates);
            %countupdates=setwhendifferent(curblock{1},'ShowName', 'on',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end


%% Proces the Outports

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'Outport')
            countupdates=apply_hg_0002_outport(curblock,countupdates);
            countupdates=block_resize(curblock,60,15,'left',countupdates);
            %countupdates=setwhendifferent(curblock{1},'ShowName', 'on',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end

%% Proces the Constants

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'Constant')
            countupdates=apply_na_0004_constant(curblock,countupdates);
            tmp_len = numel(get_param(curblock{1},'Value'));
            countupdates=block_resize(curblock,20+7*tmp_len,15,'right',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end

%% Proces the SignalSpecifications

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'SignalSpecification')
            countupdates=set_font(curblock,'Courier New',10,'white',countupdates);
            countupdates=block_resize(curblock,100,10,'right',countupdates);
            countupdates=setwhendifferent(curblock{1},'ShowName', 'off',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
    
end

%% Proces the DatatypeConverversions

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'DataTypeConversion')
            
            countupdates=set_font(curblock,'Courier New',10,'white',countupdates);
            
            tmp_len = numel(get_param(curblock{1},'OutDataTypeStr'));
            if strcmp(get_param(curblock{1},'OutDataTypeStr'),'Inherit: Inherit via back propagation')
                tmp_len=numel('Convert'); % In case DataTypeConversion is unspecified...
            end
            countupdates=block_resize(curblock,10+6*tmp_len,10,'left',countupdates);
            countupdates=setwhendifferent(curblock{1},'ShowName', 'off',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end

%% Proces the DataStoreReads

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'DataStoreRead')
            countupdates=apply_na_0004_datastore(curblock,countupdates);
            tmp_elements=get_param(curblock{1},'DataStoreElements');
            tmp_numelements = numel(strfind(tmp_elements,'#'))+1;
            if tmp_numelements==1
                max_len_element = numel(tmp_elements);
            else
                endpos_of_elements=[strfind(tmp_elements,'#') numel(tmp_elements)];
                max_len_element=max(endpos_of_elements(2:1:numel(endpos_of_elements))-endpos_of_elements(1:1:numel(endpos_of_elements)-1));
            end
            
            name_len = numel(get_param(curblock{1},'DataStoreName'));
            
            if isempty(tmp_elements)
                tmp_len = name_len;
            else
                tmp_len = max_len_element;
            end
            
            countupdates=block_resize(curblock,20+8*tmp_len,5+20*tmp_numelements,'right',countupdates);
            countupdates=setwhendifferent(curblock{1},'ShowName', 'off',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
    
end

%% Proces the DataStoreWrites

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'DataStoreWrite')
            countupdates=apply_na_0004_datastore(curblock,countupdates);
            tmp_elements=get_param(curblock{1},'DataStoreElements');
            tmp_numelements = numel(strfind(tmp_elements,'#'))+1;
            if tmp_numelements==1
                max_len_element = numel(tmp_elements);
            else
                endpos_of_elements=[strfind(tmp_elements,'#') numel(tmp_elements)];
                max_len_element=max(endpos_of_elements(2:1:numel(endpos_of_elements))-endpos_of_elements(1:1:numel(endpos_of_elements)-1));
            end
            
            name_len = numel(get_param(curblock{1},'DataStoreName'));
            
            if isempty(tmp_elements)
                tmp_len = name_len;
            else
                tmp_len = max_len_element;
            end
            
            countupdates=block_resize(curblock,20+8*tmp_len,5+20*tmp_numelements,'left',countupdates);
            countupdates=setwhendifferent(curblock{1},'ShowName', 'off',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end

%% Proces the DataStoreMemories
%x=find_system(bdroot, 'BlockType', 'DataStoreMemory');

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if strcmp(get_param(curblock{1},'BlockType'),'DataStoreMemory')
            countupdates=apply_na_0004_datastore(curblock,countupdates);
            name_len = numel(get_param(curblock{1},'DataStoreName'));
            countupdates=block_resize(curblock,20+8*name_len,+5+20*1,'left',countupdates);
            countupdates=setwhendifferent(curblock{1},'ShowName', 'off',countupdates);
        end
    catch
        % Block does not contain BlockType
    end
end



%% All Blocks that need their names to become hidden

for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if ~strcmp(bdroot,curblock) % check whether bdroot is curblock
            RefBlockName=(get_param(curblock{1},'ReferenceBlock'));
            RefBlockType=(get_param(curblock{1},'BlockType'));
            BlockName=(get_param(curblock{1},'Name'));
            
            switch RefBlockType
                % These lists must be extended when omissions are
                % encountered...
                
                case 'UniformRandomNumber'
                    RefBlockType={['Uniform Random' newline 'Number']};
                    
                case 'ToWorkspace'
                    RefBlockType={'To Workspace'};
                    
                case 'ToFile'
                    RefBlockType={'To File'};
                    
                case 'Stop'
                    RefBlockType={'Stop Simulation'};
                    
                case 'SignalGenerator'
                    RefBlockType={['Signal' newline 'Generator']};
                    
                case 'RandomNumber'
                    RefBlockType={['Random' newline 'Number']};
                    
                case 'DiscretePulseGenerator'
                    RefBlockType={['Pulse' newline 'Generator']};
                    
                case 'FromSpreadsheet'
                    RefBlockType={'From Spreadsheet'};
                    
                case 'FromFile'
                    RefBlockType={'From File'};
                    
                case 'FromWorkspace'
                    RefBlockType={'From' newline 'Workspace'};
                    
                case 'Scope'
                    RefBlockType={'Scope' ['Floating' newline 'Scope']};
                    
                case 'DigitalClock'
                    RefBlockType={'Digital Clock'};
                    
                case 'ManualSwitch'
                    RefBlockType={'Manual Switch'};
                    
                case 'MultiPortSwitch'
                    RefBlockType={['Index' newline 'Vector']  ...
                        ['Multiport' newline 'Switch']};
                    
                case 'GotoTagVisibility'
                    RefBlockType={['Goto Tag' newline 'Visibility']};
                    
                case 'BusAssignment'
                    RefBlockType={['Bus' newline 'Assignment']};
                    
                case 'UnitConversion'
                    RefBlockType={'Unit Conversion'};
                    
                case 'SignalConversion'
                    RefBlockType={['Signal' newline 'Conversion']};
                    
                case 'RateTransition'
                    RefBlockType={'Rate Transition'};
                    
                case 'InitialCondition'
                    RefBlockType={'IC'};
                    
                case 'DataTypeDuplicate'
                    RefBlockType={['Data Type' newline 'Duplicate']};
                    
                case 'BusToVector'
                    RefBlockType={'Bus To Vector'};
                    
                case 'SampleTimeMath'
                    RefBlockType={['Weighted' newline 'Sample Time' newline 'Math'] ...
                        ['Weighted' newline 'Sample Time']};
                    
                case 'UnaryMinus'
                    RefBlockType={'Unary Minus'};
                    
                case 'Trigonometry'
                    RefBlockType={['Trigonometric' newline 'Function']};
                    
                case 'Sin'
                    RefBlockType={['Sine Wave' newline 'Function'] ...
                        'Sine Wave'};
                    
                case 'Signum'
                    RefBlockType={'Sign'};
                    
                case 'Rounding'
                    RefBlockType={['Rounding' newline 'Function']};
                    
                case 'Sqrt'
                    RefBlockType={['Reciprocal' newline 'Sqrt'] ...
                        ['Signed' newline 'Sqrt'] ...
                        'Sqrt'};
                    
                case 'RealImagToComplex'
                    RefBlockType={['Real-Imag to' newline 'Complex']};
                    
                case 'Polyval'
                    RefBlockType={'Polynomial'};
                    
                case 'Concatenate'
                    RefBlockType={['Matrix' newline 'Concatenate'] ...
                        ['Vector' newline 'Concatenate']};
                    
                case 'Math'
                    RefBlockType={['Math' newline 'Function']};
                    
                case 'MagnitudeAngleToComplex'
                    RefBlockType={['Magnitude-Angle' newline 'to Complex']};
                    
                case 'Find'
                    RefBlockType={['Find Nonzero' newline 'Elements']};
                    
                case 'DotProduct'
                    RefBlockType={'Dot Product'};
                    
                case 'Product'
                    RefBlockType={'Product' 'Divide' ['Product of' newline 'Elements']};
                    
                case 'ComplexToRealImag'
                    RefBlockType={['Complex to' newline 'Real-Imag']};
                    
                case 'ComplexToMagnitudeAngle'
                    RefBlockType={['Complex to' newline 'Magnitude-Angle']};
                    
                case 'ArithShift'
                    RefBlockType={['Shift' newline 'Arithmetic']};
                    
                case 'ZeroOrderHold'
                    RefBlockType={['Zero-Order' newline 'Hold']};
                    
                case 'UnitDelay'
                    RefBlockType={'Unit Delay'};
                    
                case 'Delay'
                    RefBlockType={'Delay' 'Enabled Delay' 'Resettable Delay' 'Variable Integer Delay'};
                    
                case 'DiscreteStateSpace'
                    RefBlockType={'Discrete State-Space'};
                    
                case 'DiscreteFilter'
                    RefBlockType={'Discrete Filter'};
                    
                case 'DiscreteFir'
                    RefBlockType={'Discrete FIR Filter'};
                    
                case 'DiscreteZeroPole'
                    RefBlockType={['Discrete' newline 'Zero-Pole']};
                    
                case 'DiscreteTransferFcn'
                    RefBlockType={['Discrete' newline 'Transfer Fcn']};
                    
                case 'ZeroPole'
                    RefBlockType={'Zero-Pole'} ;
                    
                case 'VariableTransportDelay'
                    RefBlockType={['Variable' newline 'Time Delay'] ...
                        ['Variable' newline 'Transport Delay']} ;
                    
                case 'TransportDelay'
                    RefBlockType={['Transport' newline 'Delay']} ;
                    
                case 'Sum'
                    RefBlockType={'Add' 'Subtract' ['Sum of' newline 'Elements']}; % Default BlockName for Sum is Add OR Subtract
                    
                case 'Inport'
                    RefBlockType={'In'}; % Default BlockName for Inport is In
                    
                case 'Outport'
                    RefBlockType={'Out'}; % Default BlockName for Inport is In
                    
                case 'Logic'
                    RefBlockType={['Logical' newline 'Operator']} ;
                    
                case 'RelationalOperator'
                    RefBlockType={['Relational' newline 'Operator']} ;
                    
                case 'DiscreteIntegrator'
                    RefBlockType={['Discrete-Time' newline 'Integrator']} ;
                    
                case 'Integrator'
                    RefBlockType={['Integrator' newline 'Limited']} ;
                    
                case 'SecondOrderIntegrator'
                    RefBlockType={['Integrator,' newline 'Second-Order'] ...
                        ['Integrator,' newline 'Second-Order' newline 'Limited']} ;
                    
                case 'StateSpace'
                    RefBlockType={'State-Space'} ;
                    
                case 'TransferFcn'
                    RefBlockType={'Transfer Fcn'} ;
                    
                case 'ToWorkSpace'
                    RefBlockType='To WorkSpace';
                    
            end
            
            if ~isempty(RefBlockName) %then strip everything left from the last '/'
                RefBlockType=RefBlockName(max(findstr('/',RefBlockName))+1:numel(RefBlockName)); %#ok<FSTR> 
            end
            
            if ~iscell(RefBlockType)
                RefBlockType={RefBlockType};
            end
            
            if doesOccur(BlockName,RefBlockType)
                
                for x=1:numel(RefBlockType)
                    if numel(BlockName) ~= cellfun('length',RefBlockType(x)) %length different?
                        % test if next characters are numeric...
                        NextChars=BlockName(cellfun('length',RefBlockType(x))+1:numel(BlockName));
                        NextChars=str2double(NextChars);
                        if isnumeric(NextChars)&&~isnan(NextChars) % when last characters are numerical...
                            if ~strcmp(get_param(curblock{1},'ShowName'),'off')
                                set_param(curblock{1},'ShowName', 'off')
                                countupdates=countupdates+1;
                            end
                        end
                    else % identical
                        if ~strcmp(get_param(curblock{1},'ShowName'),'off')
                            set_param(curblock{1},'ShowName', 'off')
                            countupdates=countupdates+1;
                        end
                    end
                end
            end
            
        end
    catch ME
        disp(getReport(ME));
    end
end

%% Show Limits/Values of Simulink Discontinuities Blocks
% according guideline db_0140
for n=1:length(all_blocks)
    curblock=all_blocks(n);
    try
        if (strcmp(get_param(curblock{1},'BlockType'),'Saturate'))
            countupdates=setwhendifferent(curblock{1},'AttributesFormatString', 'max = %<UpperLimit>\nmin = %<LowerLimit>',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',12,countupdates);
        end
        if (strcmp(get_param(curblock{1},'BlockType'),'Backlash'))
            countupdates=setwhendifferent(curblock{1},'AttributesFormatString', 'Backlash = %<BacklashWidth>',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',12,countupdates);
        end
        if (strcmp(get_param(curblock{1},'BlockType'),'DeadZone'))
            countupdates=setwhendifferent(curblock{1},'AttributesFormatString', 'DeadZone = %<UpperValue> to %<LowerValue>',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',12,countupdates);
        end
        if (strcmp(get_param(curblock{1},'BlockType'),'HitCross'))
            countupdates=setwhendifferent(curblock{1},'AttributesFormatString', 'HitCross for %<HitCrossingDirection> edge\nFor value %<HitCrossingOffset>',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',12,countupdates);
        end
        if (strcmp(get_param(curblock{1},'BlockType'),'Quantizer'))
            countupdates=setwhendifferent(curblock{1},'AttributesFormatString', 'Quantization = %<QuantizationInterval>',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',12,countupdates);
        end
        if (strcmp(get_param(curblock{1},'BlockType'),'RateLimiter'))
            countupdates=setwhendifferent(curblock{1},'AttributesFormatString', 'RisingRate = %<RisingSlewLimit>\nFallingRate = %<FallingSlewLimit>',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',12,countupdates);
        end
        if (strcmp(get_param(curblock{1},'BlockType'),'Relay'))
            countupdates=setwhendifferent(curblock{1},'AttributesFormatString', 'y = %<OnOutputValue> when u > %<OnSwitchValue>\ny = %<OffOutputValue> when u < %<OffSwitchValue>',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontName','Courier New',countupdates);
            countupdates=setwhendifferent(curblock{1},'FontSize',12,countupdates);
        end
        
    catch
        %
    end
end

end


function counter=apply_hg_0002_inport(curblock,oldcount)
counter=set_font(curblock,'Courier New',12,'red',oldcount);
end

function counter=apply_hg_0002_outport(curblock,oldcount)
counter=set_font(curblock,'Courier New',12,'green',oldcount);
end

function counter=apply_na_0004(curblock,oldcount)
counter=set_font(curblock,'Courier New',12,'white',oldcount);
end

function counter=apply_na_0004_constant(curblock,oldcount)
ConstDataType=get_param(curblock,'OutDataTypeStr');
if strfind(char(ConstDataType),'Inherit:')==1
    %   color set to cyan when datatype inherit
    counter=set_font(curblock,'Courier New',12,'cyan',oldcount);
else
    if strfind(char(ConstDataType),'boolean')==1
        %   color set to yellow when datatype boolean
        counter=set_font(curblock,'Courier New',12,'yellow',oldcount);
    else
        %   color set to light blue when other
        counter=set_font(curblock,'Courier New',12,'lightBlue',oldcount);
    end
end
end

function counter=apply_na_0004_datastore(curblock,oldcount)
counter=set_font(curblock,'Courier New',14,'white',oldcount);
end

function counter=format_lines(lines,oldcount)
counter=oldcount;
for i = 1:length(lines)
    counter=setwhendifferent(lines(i).Handle,'FontSize','8',counter);
    counter=setwhendifferent(lines(i).Handle,'FontName','Courier New',counter);
end
end

function counter=block_resize(curblock,length,height,hold_pos,oldcount)

tmp_pos = get_param(curblock{1},'Position');
X1=tmp_pos(1);
Y1=tmp_pos(2);
X2=tmp_pos(3);
Y2=tmp_pos(4);
Xavg=floor(X1+X2)/2;
Yavg=floor(Y1+Y2)/2;
Y1=Yavg-floor(height/2);
Y2=Yavg+floor(height/2);
if strcmp(hold_pos,'right') % for horizontal alignment
    X1=X2-length;
else
    if strcmp(hold_pos,'center')
        X1=Xavg-length/2;
        X2=Xavg+length/2;
    else % align left
        X2=X1+length;
    end
end
counter=setwhendifferent(curblock{1},'Position',[X1 Y1 X2 Y2],oldcount);
end

function counter=set_font(curblock,FontName,FontSize,BackgroundColor,oldcount)
counter=setwhendifferent(curblock,'FontName',FontName,oldcount);
counter=setwhendifferent(curblock,'FontSize',FontSize,counter);
counter=setwhendifferent(curblock,'BackgroundColor', BackgroundColor,counter);
end

function counter = setwhendifferent(curblock,ValuePairName,ValuePairValue,oldcount)
CurrVal=get_param(curblock,ValuePairName);
if isnumeric(CurrVal)
    CurrVal=num2str(CurrVal);
end
if iscell(CurrVal) && isnumeric(cell2mat(CurrVal))
    CurrVal=cell2mat(CurrVal);%cellstr
else
    CurrVal=char(CurrVal);%cellstr
end
if isnumeric(ValuePairValue)
    ValuePairValue=num2str(ValuePairValue);
end
if iscell(curblock)
    curblock=curblock{1};
end
if strcmpi(ValuePairName,'Position')
    ValuePairValue=str2num(ValuePairValue); %#ok<ST2NM> 
    CurrVal=str2num(CurrVal); %#ok<ST2NM> 
end

if strcmpi(ValuePairName,'Position')
    if max(abs(ValuePairValue-CurrVal))>5
        set_param(curblock,ValuePairName,ValuePairValue);
        oldcount=oldcount+1;
    end
    
else
    if ~isequal(ValuePairValue,CurrVal)
        set_param(curblock,ValuePairName,ValuePairValue);
        oldcount=oldcount+1;
    end
end
counter=oldcount;
end

function yesorno = doesOccur(BlockName,ListOfNames)
yesorno=false;
for x=1:numel(ListOfNames)
    if strcmpi(ListOfNames(x),BlockName(1:min(cellfun('length',ListOfNames(x)),numel(BlockName))))
        yesorno=true;
    end
end
end