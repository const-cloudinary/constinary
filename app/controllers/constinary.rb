class Constinary
  @@supported_actions = %w[resize rotate effect named].freeze
  @@supported_effects = %w[blur].freeze

  class << self
    def load(path)
      @@image = Rszr::Image.load(path)
      self
    end

    def resize(*args, **opts)
      if opts.include?(:width)
        args[0] = opts.delete(:width)
      end
      if opts.include?(:height)
        args[1] = opts.delete(:height)
      end

      if args.length == 1
        args[1] = :auto
      end

      if args[0].nil?
        args[0] = :auto
      end

      opts[:skew] = true

      @@image.resize!(*args, **opts)
      self
    end

    def rotate(*args, **opts)
      if opts.include?(:angle)
        args.prepend(opts.delete(:angle))
      end
      @@image.rotate!(*args)
      self
    end

    def effect(effect_name, **opts)
      unless @@supported_effects.include?(effect_name)
        raise StandardError.new "Unsupported effect: '" + effect_name + "', available effects:" + @@supported_effects.to_s
      end
      # call the right effect.
      @@image.blur(5)
      self
    end

    def named(tr_name)
      tr = Transformation.all.select { |t| t.name == tr_name }.first
      if tr.nil?
        raise StandardError.new "Unsupported named transformation: \"" + tr_name +
                                  "\", available:" + Transformation.all.select(:name).collect(&:name).to_s
      end
      transformations = handle_transformation_string(tr.tr_string)
      transform_the_image(transformations)
      self
    end

    def save_data(format: nil, quality: nil)
      @@image.save_data(format: format, quality: quality)
    end

    def handle_transformation_string(tr_string)
      actions = tr_string.split("/")

      transformations = []
      actions.each do |action_str|
        action, args = handle_action(action_str)
        transformations.append([action, args])
      end
      transformations
    end

    def handle_action(action_str)
      unless action_str.start_with?("@")
        render json: { error: "invalid action:%s" % action_str, status: 400 }.to_json
      end

      action, params_str = action_str.delete_prefix("@").split(":", 2)

      args = handle_action_params(params_str)
      return action, args
    end

    def handle_action_params(action_params_str)
      return [], {} unless action_params_str

      params = action_params_str.delete("()").split(",")
      named_args_str, args = params.partition { |e| e.include?("=") }
      named_args = {}
      named_args_str.each do |keyword_arg|
        k, v = keyword_arg.split("=", 2)
        named_args[k] = v.to_i
      end
      return args, named_args
    end

    def transform_the_image(transformations)
      transformations.each do |e|
        action, args_named_args = e

        if !self.respond_to?(action) || !@@supported_actions.include?(action)
          raise StandardError.new "Unsupported action: \"" + action + "\", available actions:" + @@supported_actions.to_s
        end

        args = args_named_args[0].map do |arg|
          Integer(arg, exception: false) ? arg.to_i : arg
        end

        named_args = args_named_args[1].clone
        named_args.symbolize_keys!
        self.send(action, *args, **named_args)
      end
      self
    end
  end

end
