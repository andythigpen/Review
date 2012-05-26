Rails.application.config.after_initialize do
  if Rails.env == "development"
    # uncomment to enable trace in development
    # ActiveRecordQueryTrace.enabled = true
  end
end

