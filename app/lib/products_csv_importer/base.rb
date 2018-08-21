class ProductsCsvImporter::Base
  extend Dry::Initializer

  option :logger, default: proc { Rails.logger }

  private

  def result(status, payload = nil)
    [status, payload]
  end

  def resolve_result(status, payload)
    resolver_name = "resolve_#{status}_result".to_sym

    if respond_to?(resolver_name, :include_private)
      send(resolver_name, payload)
    else
      unknown_status_resolver(status, payload)
    end
  end

  def unknown_status_resolver(status, _payload)
    logger.error "No resolver registered for status :#{status}"
  end

  def attributes
    __dry_initializer_config__.attributes(self)
  end
end
