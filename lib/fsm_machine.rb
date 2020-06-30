module FSM
  class Machine
    attr_reader :parent, :states, :current_state

    def initialize(parent,&configuation_block)
      @parent         = parent

      @states         = {}
      @current_state  = nil

      instance_eval &configuation_block
    end

    def add_state(name,&configuration_block)
      @states[name]   = State.new name, &configuration_block
    end

    def set_current_state(state_name)
      @parent.instance_eval &@states[state_name].setup
      @current_state  = state_name
    end
    alias_method :set_initial_state, :set_current_state

    def update(args)
      new_state  = @states[@current_state].update parent, args

      set_current_state(new_state) if new_state != @current_state
    end
  end

  def self.new_machine(parent,&configuration_block)
    Machine.new(parent, &configuration_block)
  end
end
