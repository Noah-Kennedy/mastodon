require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'Mastodon'
  c.service_version = '4.2.3'

  config = {
    'OpenTelemetry::Instrumentation::Rack' => {
      record_frontend_span: true,
      allowed_request_headers: :all,
      allowed_response_headers: :all
    },
    'OpenTelemetry::Instrumentation::ActiveRecord' => {
      enable_sql_obfuscation: false,
    },
    'OpenTelemetry::Instrumentation::Redis' => {
      capture_arguments: true,
      db_statement: :include
    },
    'OpenTelemetry::Instrumentation::Postgres' => {
      enable_sql_obfuscation: false,
      db_statement: :include
    },
    'OpenTelemetry::Instrumentation::Sidekiq' => {
      span_naming: :job_class,
      propagation_style: :link
    },
    'OpenTelemetry::Instrumentation::Excon' => {
      # List of hosts to be excluded from otel tracing
      untraced_hosts: [],
      peer_services: 'NameOfExternalService'
    },
    'OpenTelemetry::Instrumentation::Faraday' => {
      peer_service: 'NameOfExternalService'
    }
  }

  c.use_all(config)

  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::Jaeger::AgentExporter.new(
        host: ENV['JAEGER_HOST'] || 'localhost',
        port: ENV['JAEGER_PORT'] || 6831
      )
    )
  )
end
