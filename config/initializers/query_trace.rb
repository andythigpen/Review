Rails.application.config.after_initialize do
  ActiveRecordQueryTrace.enabled = true
end

