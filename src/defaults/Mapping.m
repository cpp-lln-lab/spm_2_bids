classdef Mapping
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

            p = inputParser;

            addParameter(p, 'prefix', obj.default_value);
            addParameter(p, 'suffix', obj.default_value);
            addParameter(p, 'entities', obj.default_value);
            addParameter(p, 'ext', obj.default_value);
            addParameter(p, 'name_spec', obj.default_value);

            parse(p, varargin{:});

            prefix = p.Results.prefix;
            if ~iscell(prefix)
                prefix = {prefix};
            end

            obj.mapping(end + 1, 1).prefix = prefix;
            obj.mapping(end, 1).suffix = p.Results.suffix;
            obj.mapping(end, 1).entities = p.Results.entities;
            obj.mapping(end, 1).ext = p.Results.ext;
            obj.mapping(end, 1).name_spec = p.Results.name_spec;

        end

        function obj = flatten_mapping(obj)
            %
            % ensures that there is only one prefix, suffix, entity for each mapping
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

        function obj = default(obj)

            % map of prefix to name specification
            prfx_spec = { ...
                         { obj.bias_cor },               obj.cfg.segment.bias_corrected; ...
                         { 'c1' },                       obj.cfg.segment.gm; ...
                         { 'c2' },                       obj.cfg.segment.wm; ...
                         { 'c3' },                       obj.cfg.segment.csf
                         { 'iy_' },                      obj.cfg.segment.deformation_field.from_mni
                         { 'y_' },                       obj.cfg.segment.deformation_field.to_mni
                         { obj.stc, [obj.unwarp, obj.stc]},  obj.cfg.stc
                         { obj.unwarp },                     obj.cfg.realign_unwarp
                         { 'rp_', ['rp_' obj.stc] },         obj.cfg.real_param
                         { 'mean', ...
                          ['mean' obj.unwarp], ...
                          ['mean' obj.unwarp, obj.stc] },    obj.cfg.mean
                         { obj.norm, ...
                          [obj.norm, obj.bias_cor], ...
                          [obj.norm, obj.unwarp,  obj.stc], ...
                          [obj.norm, obj.realign, obj.stc], ...
                          [obj.norm, obj.unwarp], ...
                          [obj.norm, obj.realign] },         obj.cfg.preproc_norm
                         { [obj.norm, 'mean', obj.unwarp] }, obj.cfg.normalized_mean
                         { [obj.norm, 'c1'] },               obj.cfg.segment.gm_norm
                         { [obj.norm, 'c2'] },               obj.cfg.segment.wm_norm
                         { [obj.norm, 'c3'] },               obj.cfg.segment.csf_norm
                         {[obj.smooth, obj.norm], ...
                          [obj.smooth, obj.norm, obj.unwarp,  obj.stc], ...
                          [obj.smooth, obj.norm, obj.realign, obj.stc], ...
                          [obj.smooth, obj.norm, obj.unwarp], ...
                          [obj.smooth, obj.norm, obj.realign] }, obj.cfg.smooth_norm
                         { obj.smooth, ...
                          [obj.smooth, obj.unwarp,  obj.stc], ...
                          [obj.smooth, obj.realign, obj.stc], ...
                          [obj.smooth, obj.unwarp], ...
                          [obj.smooth, obj.realign]},         obj.cfg.smooth
                        };

            for i_map = 1:size(prfx_spec, 1)
                obj = obj.add_mapping('prefix', prfx_spec{i_map, 1}, ...
                                      'name_spec', prfx_spec{i_map, 2});
            end

            obj = flatten_mapping(obj);

        end

    end
end
