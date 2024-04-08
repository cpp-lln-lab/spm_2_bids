classdef Mapping
    %
    % Creates a mapping object that will contain the list how an spm file will be renamed
    % into a bids derivatives.
    %
    % Has the following attributes:
    %
    %   - mapping, (n X 1) structure with the following fields:
    %
    %         - ``prefix``
    %         - ``suffix``
    %         - ``entities``
    %         - ``ext``
    %         - ``name_spec``: structure that must resemble the output of bids.File
    %
    %   - cfg describes the common properties to be used for several names in the output.
    %     (See ``check_cfg()``)
    %
    %   - list of SPM prefixes from ``get_spm_prefix_list()``:
    %
    %           - ``stc = ''``
    %           - ``realign = ''``
    %           - ``unwarp = ''``
    %           - ``coreg = ''``
    %           - ``bias_cor = ''``
    %           - ``norm = ''``
    %           - ``smooth = ''``
    %

    % (C) Copyright 2021 spm_2_bids developers

    properties

        mapping

        cfg = struct([])

        stc = ''
        realign = ''
        unwarp = ''
        coreg = ''
        bias_cor = ''
        norm = ''
        smooth = ''

    end

    properties (SetAccess = private)
        default_value = ''
    end

    methods

        function obj = Mapping(cfg)
            %
            % Creates the mapping object with a given configuration
            %
            % USAGE::
            %
            %  map = Mapping(cfg)
            %
            %

            if nargin == 1
                obj.cfg = cfg;
            else
                obj.cfg = check_cfg();
            end

            prefix_list = get_spm_prefix_list();

            obj.stc = prefix_list.stc;
            obj.realign = prefix_list.realign;
            obj.unwarp = prefix_list.unwarp;
            obj.coreg = prefix_list.coreg;
            obj.bias_cor = prefix_list.bias_cor;
            obj.norm = prefix_list.norm;
            obj.smooth = prefix_list.smooth;

        end

        function obj = add_mapping(obj, varargin)
            %
            % Add a mapping to the for a given files or set of spm files to a
            % specific name output.
            %
            % USAGE::
            %
            %  map = add_mapping('prefix', prefix, ...
            %                       'suffix', suffix, ...
            %                       'entities', entities, ...
            %                       'ext', ext, ...
            %                       'name_spec', struct)
            %

            % TODO add possibility to pass "filter" argument that is a structure
            % with shape (allows to chain the output from bids parsing)
            %
            % filter.prefix
            % filter.suffix
            % filter.entities
            % filter.ext
            %

            args = inputParser;

            addParameter(args, 'prefix', obj.default_value);
            addParameter(args, 'suffix', obj.default_value);
            addParameter(args, 'entities', obj.default_value);
            addParameter(args, 'ext', obj.default_value);
            addParameter(args, 'name_spec', obj.default_value);

            parse(args, varargin{:});

            prefix = args.Results.prefix;
            if ~iscell(prefix)
                prefix = {prefix};
            end

            obj.mapping(end + 1, 1).prefix = prefix;
            obj.mapping(end, 1).suffix = args.Results.suffix;
            obj.mapping(end, 1).entities = args.Results.entities;
            obj.mapping(end, 1).ext = args.Results.ext;
            obj.mapping(end, 1).name_spec = args.Results.name_spec;

        end

        function obj = flatten_mapping(obj)
            %
            % ensures that there is only one prefix, suffix, entity for each mapping
            %
            % typically to be run before using ``spm_2_bids``
            %
            % (C) Copyright 2021 spm_2_bids developers

            % TODO add a check to make sure each prefix is only present once

            tmp = struct([]);

            for i = 1:size(obj.mapping, 1)

                if ~iscell(obj.mapping(i).prefix)
                    obj.mapping(i).prefix = {obj.mapping(i).prefix};
                end

                for j = 1:numel(obj.mapping(i).prefix)
                    tmp(end + 1, 1).prefix = obj.mapping(i).prefix{j};
                    tmp(end).suffix = obj.mapping(i).suffix;
                    tmp(end).entities = obj.mapping(i).entities;
                    tmp(end).name_spec = obj.mapping(i).name_spec;
                    tmp(end).ext = obj.mapping(i).ext;
                end

            end

            obj.mapping =  tmp;

        end

        function print_mapping(obj, filename)
            %
            % Print to screen by default.
            % Otherwise can print to a file (markdown) or a json
            %
            %
            % USAGE::
            %
            %  map = print_mapping(filename)
            %

            obj = flatten_mapping(obj);

            if nargin > 1 && strcmp(bids.internal.file_utils(filename, 'ext'), 'json')
                output_is_json = true;
                content = {};
                for i = 1:size(obj.mapping, 1)
                    input = obj.mapping(i);
                    input = rmfield(input, 'name_spec');
                    content{i, 1} = struct('input', input, ...
                                           'output', obj.mapping(i).name_spec);
                end
                bids.util.jsonencode(filename, content);
                return
            end

            % print to screen by default
            fid = 1;

            % what to separate input and output with
            left = ' ';
            separator = ' --> ';
            right = ' ';

            if nargin > 1
                fid = fopen(filename, 'Wt');
                if fid == -1
                    error('Unable to write file %s.', filename);
                end
                % markdown table separators
                left = '| ';
                separator = ' | ';
                right = ' |';
            end

            header = ['<!--\n', ...
                      ' THIS FILE IS AUTOMATICALLY GENERATED!\n', ...
                      ' DO NOT EDIT MANUALLY!\n', ...
                      '-->\n', ...
                      '# Mapping\n\n', ...
                      left, 'input', separator, 'output', right,  '\n', ...
                      left, '-',     separator, '-',      right,  '\n'];

            fprintf(fid, '\n');
            if fid ~= 1
                fprintf(fid, header);
            end

            for i = 1:size(obj.mapping, 1)

                %%
                input = obj.mapping(i);
                input = prepare_for_printing(input);

                input_filename = input.filename;

                %%
                output = obj.mapping(i).name_spec;
                output = prepare_for_printing(output);

                output_filename = output.filename;

                output_filename = ['*' output_filename];
                output_filename = strrep(output_filename, 'add-star', '*');

                if fid ~= 1
                    input_filename = strrep(input_filename, '*', '\*');
                    input_filename = strrep(input_filename, '_', '\_');
                    output_filename = strrep(output_filename, '*', '\*');
                    output_filename = strrep(output_filename, '_', '\_');
                end

                fprintf(fid, '%s%s%s%s%s\n', ...
                        left, input_filename, separator, output_filename, right);

            end

            fprintf(fid, '\n');
            if fid ~= 1
                fclose(fid);
            end

        end

        function obj = default(obj)
            %
            % Load into the the mapping objects the default map for SPM --> bids derivatives
            %
            % USAGE::
            %
            %   map = map.default;
            %

            spec = {{ obj.bias_cor },               obj.cfg.segment.bias_corrected; ...
                    { 'c1' },                       obj.cfg.segment.gm; ...
                    { 'c2' },                       obj.cfg.segment.wm; ...
                    { 'c3' },                       obj.cfg.segment.csf; ...
                    { 'iy_' },                      obj.cfg.segment.deformation_field.from_mni; ...
                    { 'y_' },                       obj.cfg.segment.deformation_field.to_mni; ...
                    { 'segparam_' },                obj.cfg.segment.param; ...
                    { obj.stc, ...
                     [obj.stc, obj.unwarp] },                      obj.cfg.stc; ...
                    { 'unwarpparam_' },                            obj.cfg.realign_unwarp_param; ...
                    { obj.unwarp, ...
                     [obj.unwarp, obj.stc] },                      obj.cfg.realign_unwarp; ...
                    { 'rp_', ...
                     ['rp_', obj.stc], ...
                     ['rp_', obj.stc, obj.unwarp] },               obj.cfg.real_param; ...
                    {[obj.norm, 'c1'] },                           obj.cfg.segment.gm_norm; ...
                    {[obj.norm, 'c2'] },                           obj.cfg.segment.wm_norm; ...
                    {[obj.norm, 'c3'] },                           obj.cfg.segment.csf_norm};

            spec_mean = {{ 'mean', ...
                          ['mean' obj.unwarp], ...
                          ['mean' obj.unwarp, obj.stc], ...
                          ['mean' obj.stc, obj.unwarp] },               obj.cfg.mean};

            spec_norm_mean = {{[obj.norm, 'mean'], ...
                               [obj.norm, 'mean', obj.unwarp], ...
                               [obj.norm, 'mean', obj.unwarp, obj.stc], ...
                               [obj.norm, 'mean', obj.stc, obj.unwarp]}, obj.cfg.normalized_mean};

            spec_smooth = {{ obj.smooth, ...
                            [obj.smooth, obj.unwarp,  obj.stc], ...
                            [obj.smooth, obj.stc,     obj.unwarp], ...
                            [obj.smooth, obj.realign, obj.stc], ...
                            [obj.smooth, obj.unwarp], ...
                            [obj.smooth, obj.realign] },                           obj.cfg.smooth};

            spec_smooth_norm = {{[obj.smooth, obj.norm], ...
                                 [obj.smooth, obj.norm, obj.unwarp,  obj.stc], ...
                                 [obj.smooth, obj.norm, obj.stc,     obj.unwarp], ...
                                 [obj.smooth, obj.norm, obj.realign, obj.stc], ...
                                 [obj.smooth, obj.norm, obj.unwarp], ...
                                 [obj.smooth, obj.norm, obj.realign] },        obj.cfg.smooth_norm};

            spec_preproc = {{[obj.realign, obj.stc]},                obj.cfg.preproc};

            spec_preproc_norm = {{obj.norm, ...
                                  [obj.norm, obj.bias_cor], ...
                                  [obj.norm, obj.stc,     obj.unwarp], ...
                                  [obj.norm, obj.unwarp,  obj.stc], ...
                                  [obj.norm, obj.realign, obj.stc], ...
                                  [obj.norm, obj.unwarp], ...
                                  [obj.norm, obj.realign] },                 obj.cfg.preproc_norm};

            spec = cat(1, spec, ...
                       spec_smooth, ...
                       spec_smooth_norm, ...
                       spec_preproc_norm, ...
                       spec_preproc, ...
                       spec_mean, ...
                       spec_norm_mean);

            for i_map = 1:size(spec, 1)
                obj = obj.add_mapping('prefix', spec{i_map, 1}, ...
                                      'name_spec', spec{i_map, 2});
            end

            obj = flatten_mapping(obj);

        end

        function idx = find_mapping(obj, varargin)
            %
            % USAGE::
            %
            %    idx = obj.find_mapping('prefix', str)
            %

            args = inputParser;

            addParameter(args, 'prefix', @ischar);

            parse(args, varargin{:});

            available_mapped_prefixes = {obj.mapping.prefix}';

            idx = strcmp(args.Results.prefix, available_mapped_prefixes);

        end

        function obj = rm_mapping(obj, idx)

            obj.mapping(idx) = [];

        end

    end
end
