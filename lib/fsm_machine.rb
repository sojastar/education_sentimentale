module FSM
  class Machine
    attr_reader :parent, :states, :current_state

    def initialize(parent,&configuation_block)
      @parent         = parent

      @initial_state  = nil

      @states         = {}
      @current_state  = nil

      instance_eval &configuation_block
    end

    def add_state(name,&configuration_block)
      @states[name]   = State.new name, &configuration_block
    end

    def set_initial_state(state_name)
      @initial_state  = state_name
    end

    def set_current_state(state_name)
      @parent.instance_eval &@states[state_name].setup
      @current_state  = state_name
    end

    def set_parent(new_parent)
      @parent         = new_parent
    end

    def start
      set_current_state @initial_state
    end

    def update(args)
      new_state       = @states[@current_state].update parent, args

      set_current_state(new_state) if new_state != @current_state
    end
  end

  def self.new_machine(parent,&configuration_block)
    Machine.new(parent, &configuration_block)
  end

  def serialize
    { states: @states.keys }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
