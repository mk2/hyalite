module Hylite
  class EventDispatcher
    def initialize
      @enabled = true
    end

    def enabled?
      @enabled
    end

    def enabled=(enabled)
      @enabled = enabled
    end

    def trap_bubbled_event(top_level_type, handler_base_name, element)
      return nil unless element

      element.on! handler_base_name do |event|
        dispatch_event(top_level_type, event)
      end
    end

    def find_parent(node)
      node_id = Mount.id(node)
      root_id = InstanceHandles.root_id_from_node_id(node_id)
      container = Mount.container_for_id(root_id)
      Mount.find_first_hylite_dom(container)
    end

    def handle_top_level(book_keeping)
      ancestor = Mount.find_first_hylite_dom(book_keeping.event.target)
      while ancestor
        book_keeping.ancestors << ancestor
        ancestor = find_parent(ancestor)
      end

      book_keeping.ancestors.each do |top_level_target|
        top_level_target_id = Mount.node_to_id(top_level_target) || ''
        ReactEventListener._handleTopLevel(
          book_keeping.top_level_type,
          top_level_target,
          top_level_target_id,
          book_keeping.event,
          book_keeping.event.target
        )
      end
    end

    def dispatch_event(top_level_type, event)
      return unless @enabled

      book_keeping = TopLevelCallbackBookKeeping.new(top_level_type, event)
      Updates.batched_updates { handle_top_level(book_keeping) }
    end

    def put_listener(id:, name:, listener:)
      @lisetener_bank = @lisetener_bank || {}
      listeners = @lisetener_bank[name] || {}
      listeners[id] = listener
    end

    class TopLevelCallbackBookKeeping
      def initialize(top_level_type, event)
        @top_level_type = top_level_type
        @event = event
        @ancestors = []
      end
    end
  end
end
