// OPERACIONES

class Operacion {
  const inmueble
  var reservadoPara = nadie
  var estado = disponible

  method comision()

  method sePuedeConcretar(persona) = reservadoPara.permiteOtroCierre(persona)

  method concretar() {
    estado = cerrado
    inmueble.comprar(reservadoPara)
    reservadoPara.propiedades().add(inmueble)
  }

  method sePuedeReservar() = reservadoPara.permiteOtraReserva()

  method reservar(posiblePropietario) {
    reservadoPara = posiblePropietario
  }

  method zona() = inmueble.zona()
}

class Alquiler inherits Operacion {
  const meses

  override method comision() = meses * inmueble.valor() / 50000
}

class Venta inherits Operacion {
  const porcentaje

  override method comision() = porcentaje * inmueble.valor()

  override method sePuedeConcretar(persona) = super(persona) && inmueble.puedeVenderse()
}

object disponible {}
object cerrado {}


// INMUEBLES

class Inmueble {
  const metros
  const ambientes
  const operacion
  const zona
  var propietario = nadie

  method valor() = zona.adicional()
  
  method comprar(nuevoPropietario) {
    propietario = nuevoPropietario
  }

  method puedeVenderse() = true
}

class Casa inherits Inmueble {
  const particular

  override method valor() = super() + particular
}

class PH inherits Inmueble {
  override method valor() = super() + (14000 * metros).max(500000)
}

class Departamento inherits Inmueble {
  override method valor() = super() + 350000 * ambientes
}

class Local inherits Casa {
  var tipo

  override method valor() = tipo.establecer(particular)

  override method puedeVenderse() = false

  method remodelar(nuevoTipo) {
    tipo = nuevoTipo
  }
}

class Galpon {
  method establecer(valorInicial) = valorInicial / 2
}

class ALaCalle {
  const fijo

  method establecer(valorInicial) = valorInicial + fijo
}

class Zona {
  const property adicional
}


// EMPLEADOS

class Empleado {
  const property reservas = []
  const property operacionesCerradas = []

  method reservarInmueble(operacion, cliente) {
    if (operacion.sePuedeReservar()) {
      operacion.reservar(cliente)
      reservas.add(operacion)
    }
  }

  method concretarOperacion(operacion, cliente) {
    if (operacion.sePuedeConcretar(cliente)) {
      operacion.concretar()
      operacionesCerradas.add(operacion)
    }
  }

  method comisionesTotales() = operacionesCerradas.sum({operacion => operacion.comision()})

  method zonasCerradas() = operacionesCerradas.map({operacion => operacion.zona()})

  method mismaZona(otroEmpleado) = self.zonasCerradas().any({zona => otroEmpleado.zonasCerradas().contains(zona)})

  method roboOperacion(otroEmpleado) = operacionesCerradas.any({operacion => otroEmpleado.reservas().contains(operacion)})

  method tieneProblemas(otroEmpleado) = self.mismaZona(otroEmpleado) && self.roboOperacion(otroEmpleado)
}


// CLIENTES

class Cliente {
  const property propiedades = []

  method solicitarReserva(propiedad, empleado) {
    empleado.reservarInmueble(propiedad, self)
  }

  method permiteOtraReserva() = false

  method permiteOtroCierre(persona) = persona == self
}

object nadie {
  method permiteOtraReserva() = true

  method permiteOtroCierre(persona) = true
}


// INMOBILIARIA

class Inmobiliaria {
  const empleados

  method mejorEmpleado(criterio) = criterio.mejor(empleados)
}

object comisionesTotales {
  method mejor(empleados) = empleados.max({empleado => empleado.comisionesTotales()})
}

object operacionesCerradas {
  method mejor(empleados) = empleados.max({empleado => empleado.operacionesCerradas().size()})
}

object reservas {
  method mejor(empleados) = empleados.max({empleado => empleado.reservas().size()})
}

object alquiler {}