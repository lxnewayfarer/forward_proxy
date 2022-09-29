# frozen_string_literal: true

require 'forward_proxy'

Rails.application.config.middleware.use ForwardProxy, streaming: false
