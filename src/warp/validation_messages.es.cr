module Warp::Validation
  struct Messages
    @@FIELD_PREFIX = "El campo "
    @@REQUIRED_SUFFIX = " es requerido"
    @@SIZED_BETWEEN_SUFFIX = " debe estar comprendido entre "
    @@SIZED_BETWEEN_CONNECTOR = " y "
    @@SIZED_EQUALS_SUFFIX = " debe ser igual a "
    @@FORMAT_BETWEEN_SUFFIX = " tiene un formato invalido. "
  end
end