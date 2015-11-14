require 'set'
require 'math'

module Hyalite
  module BrowserEvent
    EVENT_TYPES = {
      keyDown: {
        phasedRegistrationNames: {
          bubbled: :onKeyDown,
          captured: :onKeyDownCapture
        },
      },
    }

    TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG = {
      topKeyDown: EVENT_TYPES[:keyDown]
    }

    REGISTRATION_NAME_DEPENDENCIES = {
      "keydown" => [:topKeyDown]
    }

    TOP_EVENT_MAPPING = { topKeyDown: "keydown" }

    TOP_LISTENERS_ID_KEY = '_hyliteListenersID' + Math.rand.to_s.chars.drop(2).join

    def self.include?(name)
      EVENT_TYPES.has_key? name.downcase
    end

    def self.listen_to(registration_name, content_document_handle)
      mount_at = content_document_handle
      is_listening = listening_for_document(mount_at)
      dependencies = REGISTRATION_NAME_DEPENDENCIES[registration_name]

      dependencies.each do |dependency|
        unless is_listening.has_key? dependency && is_listening[dependency]
          case dependency
          when :top_wheel
            nil
          #   if isEventSupported('wheel')
          #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
          #       topLevelTypes.topWheel,
          #       'wheel',
          #       mountAt
          #     );
          #   elsif isEventSupported('mousewheel')
          #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
          #       topLevelTypes.topWheel,
          #       'mousewheel',
          #       mountAt
          #     );
          #   else
          #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
          #       topLevelTypes.topWheel,
          #       'DOMMouseScroll',
          #       mountAt
          #     );
          #   end
          # when :top_scroll
          #   if isEventSupported('scroll', true)
          #     ReactBrowserEventEmitter.ReactEventListener.trapCapturedEvent(
          #       topLevelTypes.topScroll,
          #       'scroll',
          #       mountAt
          #     );
          #   else
          #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
          #       topLevelTypes.topScroll,
          #       'scroll',
          #       ReactBrowserEventEmitter.ReactEventListener.WINDOW_HANDLE
          #     );
          #   end
          # when :top_focus, :top_blur
          #   if isEventSupported('focus', true)
          #     ReactBrowserEventEmitter.ReactEventListener.trapCapturedEvent(
          #       topLevelTypes.topFocus,
          #       'focus',
          #       mountAt
          #     );
          #     ReactBrowserEventEmitter.ReactEventListener.trapCapturedEvent(
          #       topLevelTypes.topBlur,
          #       'blur',
          #       mountAt
          #     );
          #   elsif isEventSupported('focusin')
          #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
          #       topLevelTypes.topFocus,
          #       'focusin',
          #       mountAt
          #     );
          #     ReactBrowserEventEmitter.ReactEventListener.trapBubbledEvent(
          #       topLevelTypes.topBlur,
          #       'focusout',
          #       mountAt
          #     );
          #   end
          #
          #   is_listening[:top_blur] = true
          #   is_listening[:top_focus] = true
          else
            if TOP_EVENT_MAPPING.has_key? dependency
              trapBubbledEvent(
                dependency,
                TOP_EVENT_MAPPING[dependency],
                mountAt
              );
            end
          end

          isListening[dependency] = true;
        end
      end
    end

    def extractEvents(top_level_type, top_level_target, top_level_target_id, native_event, native_event_target)
      dispatch_config = TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG[top_level_type]
      return nil unless dispatch_config
      case top_level_type
      when :topKeyDown, :topKeyUp
        EventClass = SyntheticKeyboardEvent
      end
      event = EventClass.new(dispatch_config, top_level_target_id, native_event, native_event_target)
      EventPropagators.accumulateTwoPhaseDispatches(event)
      event
    end

    def self.listening_for_document(mount_at)
      @already_listening_to ||= {}
      @top_listeners_counter ||= 0
      unless mount_at[TOP_LISTENERS_ID_KEY]
        @top_listeners_counter += 1
        mount_at[TOP_LISTENERS_ID_KEY] = @top_listeners_counter
        @already_listening_to[mount_at[TOP_LISTENERS_ID_KEY]] = {}
      end
      @already_listening_to[mount_at[TOP_LISTENERS_ID_KEY]]
    end

    def self.enabled?
      true
    end

    def self.enabled=(enabled)
      
    end
  end
end
