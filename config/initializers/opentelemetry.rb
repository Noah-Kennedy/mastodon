require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'
require 'opentelemetry/instrumentation/rails'
require 'opentelemetry/instrumentation/rack'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'Mastodon'
  c.service_version = '4.2.3'

  # c.use 'OpenTelemetry::Instrumentation::ActionPack'
  # c.use 'OpenTelemetry::Instrumentation::ActionView'
  # c.use 'OpenTelemetry::Instrumentation::ActiveJob'
  # c.use 'OpenTelemetry::Instrumentation::ActiveModelSerializers'
  # c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
  # c.use 'OpenTelemetry::Instrumentation::Rails'
  # c.use 'OpenTelemetry::Instrumentation::Rack', {
  #   allowed_request_headers: :all,
  #   allowed_response_headers: :all
  # }

  c.use_all

  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::Jaeger::AgentExporter.new(
        host: ENV['JAEGER_HOST'] || 'localhost',
        port: ENV['JAEGER_PORT'] || 6831
      )
    )
  )
end
