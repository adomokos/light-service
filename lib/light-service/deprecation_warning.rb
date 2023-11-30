module LightService
  def deprecation_warning(message, caller_info = caller(1..1).first)
    warning = "DEPRECATION WARNING: #{message}"
    warning << " (called from #{caller_info})" if caller_info
    puts warning
  end

  module_function :deprecation_warning
end
