require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'Mastodon'
  c.service_version = '4.2.3'

  c.use('OpenTelemetry::Instrumentation::Rack', { record_frontend_span: true, allowed_request_headers: :all, allowed_response_headers: :all })
  c.use('OpenTelemetry::Instrumentation::Redis', { capture_arguments: true, db_statement: :include })
  c.use('OpenTelemetry::Instrumentation::Postgres', { enable_sql_obfuscation: false, db_statement: :include })
  c.use('OpenTelemetry::Instrumentation::Sidekiq', { span_naming: :job_class, propagation_style: :link })
  c.use('OpenTelemetry::Instrumentation::Excon', { untraced_hosts: [], peer_services: 'NameOfExternalService'})
  c.use('OpenTelemetry::Instrumentation::Faraday', { peer_service: 'NameOfExternalService' })
  c.use 'OpenTelemetry::Instrumentation::HTTP'
  c.use 'OpenTelemetry::Instrumentation::Rails'
  c.use 'OpenTelemetry::Instrumentation::ActionPack'
  c.use 'OpenTelemetry::Instrumentation::ActionView'
  c.use 'OpenTelemetry::Instrumentation::ActiveJob'
  c.use 'OpenTelemetry::Instrumentation::ActiveModelSerializers'

  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::Jaeger::AgentExporter.new(
        host: ENV['JAEGER_HOST'] || 'localhost',
        port: ENV['JAEGER_PORT'] || 6831
      )
    )
  )
end
