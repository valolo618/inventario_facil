import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(const InventarioFacilApp());
}

class InventarioFacilApp extends StatelessWidget {
  const InventarioFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario Fácil',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2457C5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FC),
        fontFamily: 'Roboto',
      ),
      home: const InicioInventario(),
    );
  }
}



class Producto {
  final String nombre;
  final String categoria;
  final int cantidad;
  final double precio;
  final IconData icono;

  const Producto({
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.precio,
    required this.icono,
  });

  // Convierte el producto en información guardable.
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'precio': precio,
    };
  }

  // Recupera un producto desde la información guardada.
  factory Producto.fromMap(Map<String, dynamic> mapa) {
    return Producto(
      nombre: mapa['nombre'] as String,
      categoria: mapa['categoria'] as String,
      cantidad: mapa['cantidad'] as int,
      precio: (mapa['precio'] as num).toDouble(),
      icono: Icons.inventory_2_outlined,
    );
  }
}
class Movimiento {
  final String nombreProducto;
  final String tipo;
  final int cantidad;
  final DateTime fecha;

  const Movimiento({
    required this.nombreProducto,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombreProducto': nombreProducto,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> mapa) {
    return Movimiento(
      nombreProducto: mapa['nombreProducto'] as String,
      tipo: mapa['tipo'] as String,
      cantidad: mapa['cantidad'] as int,
      fecha: DateTime.parse(mapa['fecha'] as String),
    );
  }
}

class InicioInventario extends StatefulWidget {
  const InicioInventario({super.key});

  @override
  State<InicioInventario> createState() => _InicioInventarioState();
}

class _InicioInventarioState extends State<InicioInventario> {
  final TextEditingController buscadorController = TextEditingController();
final List<Movimiento> movimientos = [];

bool cargandoMovimientos = true;
  final List<Producto> productos = [
    const Producto(
      nombre: 'Arroz Diana 500 g',
      categoria: 'Granos y cereales',
      cantidad: 24,
      precio: 2500,
      icono: Icons.rice_bowl_outlined,
    ),
    const Producto(
      nombre: 'Aceite vegetal 1 L',
      categoria: 'Aceites',
      cantidad: 8,
      precio: 8900,
      icono: Icons.water_drop_outlined,
    ),
    const Producto(
      nombre: 'Leche entera 1 L',
      categoria: 'Lácteos',
      cantidad: 4,
      precio: 4200,
      icono: Icons.local_drink_outlined,
    ),
    const Producto(
      nombre: 'Café molido 250 g',
      categoria: 'Bebidas',
      cantidad: 15,
      precio: 12500,
      icono: Icons.coffee_outlined,
    ),
    const Producto(
      nombre: 'Galletas integrales',
      categoria: 'Snacks',
      cantidad: 3,
      precio: 3800,
      icono: Icons.cookie_outlined,
    ),
  ];
  bool cargando = true;

@override
void initState() {
  super.initState();
  _cargarProductos();
  _cargarMovimientos();
}

Future<void> _cargarProductos() async {
  final prefs = await SharedPreferences.getInstance();
  final datosGuardados = prefs.getString('productos');

  if (datosGuardados != null) {
    final List<dynamic> datos = jsonDecode(datosGuardados);

    productos.clear();
    productos.addAll(
      datos.map(
        (item) => Producto.fromMap(
          Map<String, dynamic>.from(item),
        ),
      ),
    );
  } else {
    await _guardarProductos();
  }

  if (!mounted) return;

  setState(() {
    cargando = false;
  });
}

Future<void> _guardarProductos() async {
  final prefs = await SharedPreferences.getInstance();

  final datos = jsonEncode(
    productos.map((producto) => producto.toMap()).toList(),
  );

  await prefs.setString('productos', datos);
}
Future<void> _cargarMovimientos() async {
  final prefs = await SharedPreferences.getInstance();
  final datosGuardados = prefs.getString('movimientos');

  if (datosGuardados != null) {
    final List<dynamic> datos = jsonDecode(datosGuardados);

    movimientos.clear();
    movimientos.addAll(
      datos.map(
        (item) => Movimiento.fromMap(
          Map<String, dynamic>.from(item),
        ),
      ),
    );
  }

  if (!mounted) return;

  setState(() {
    cargandoMovimientos = false;
  });
}

Future<void> _guardarMovimientos() async {
  final prefs = await SharedPreferences.getInstance();

  final datos = jsonEncode(
    movimientos.map((movimiento) => movimiento.toMap()).toList(),
  );

  await prefs.setString('movimientos', datos);
}
Future<void> _registrarMovimiento({
  required int indiceProducto,
  required String tipo,
  required int cantidad,
}) async {
  final producto = productos[indiceProducto];

  if (cantidad <= 0) {
    return;
  }

  if (tipo == 'Salida' && cantidad > producto.cantidad) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No hay suficientes unidades disponibles.'),
      ),
    );
    return;
  }

  final nuevaCantidad = tipo == 'Entrada'
      ? producto.cantidad + cantidad
      : producto.cantidad - cantidad;

  final productoActualizado = Producto(
    nombre: producto.nombre,
    categoria: producto.categoria,
    cantidad: nuevaCantidad,
    precio: producto.precio,
    icono: producto.icono,
  );

  setState(() {
    productos[indiceProducto] = productoActualizado;

    movimientos.insert(
      0,
      Movimiento(
        nombreProducto: producto.nombre,
        tipo: tipo,
        cantidad: cantidad,
        fecha: DateTime.now(),
      ),
    );
  });

  await _guardarProductos();
  await _guardarMovimientos();
}
Future<void> _mostrarDialogoMovimiento({
  required int indiceProducto,
  required String tipo,
}) async {
  final controlador = TextEditingController();

  final cantidad = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        tipo == 'Entrada'
            ? 'Registrar entrada'
            : 'Registrar salida',
      ),
      content: TextField(
        controller: controlador,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Cantidad de unidades',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final valor = int.tryParse(controlador.text);

            if (valor == null || valor <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ingresa una cantidad válida.'),
                ),
              );
              return;
            }

            Navigator.pop(context, valor);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  controlador.dispose();

  if (cantidad != null) {
    await _registrarMovimiento(
      indiceProducto: indiceProducto,
      tipo: tipo,
      cantidad: cantidad,
    );
  }
}
  String busqueda = '';
  String filtroMovimientos = 'Todos';

  @override
  void dispose() {
    buscadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productosFiltrados = productos.where((producto) {
      return producto.nombre.toLowerCase().contains(busqueda.toLowerCase());
    }).toList();

    final totalUnidades = productos.fold<int>(
      0,
      (total, producto) => total + producto.cantidad,
    );

    final productosBajos =
        productos.where((producto) => producto.cantidad <= 5).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Color(0xFF2457C5),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventario Fácil',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18233D),
                  ),
                ),
                Text(
                  'Controla tu negocio',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              '¡Hola! 👋',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF18233D),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Este es el resumen de tu inventario.',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
  builder: (context, constraints) {
    final ancho = constraints.maxWidth >= 700
        ? (constraints.maxWidth - 24) / 3
        : (constraints.maxWidth - 12) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: ancho,
          child: _TarjetaResumen(
            titulo: 'Productos',
            valor: '${productos.length}',
            icono: Icons.inventory_2_outlined,
            color: const Color(0xFF2457C5),
          ),
        ),
        SizedBox(
          width: ancho,
          child: _TarjetaResumen(
            titulo: 'Unidades',
            valor: '$totalUnidades',
            icono: Icons.widgets_outlined,
            color: const Color(0xFF159A80),
          ),
        ),
        SizedBox(
          width: constraints.maxWidth >= 700
              ? ancho
              : constraints.maxWidth,
          child: _TarjetaResumen(
            titulo: 'Productos con stock bajo',
            valor: '$productosBajos',
            icono: Icons.warning_amber_rounded,
            color: const Color(0xFFE58B25),
          ),
        ),
      ],
    );
  },
),

            const SizedBox(height: 25),
            const Text(
              'Mis productos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF18233D),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: buscadorController,
              onChanged: (valor) {
                setState(() {
                  busqueda = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (productosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No se encontraron productos.'),
                ),
              ),

            ...productosFiltrados.map(
  (producto) {
    final indice = productos.indexOf(producto);

    return _TarjetaProducto(
      producto: producto,
      onEntrada: () {
  _mostrarDialogoMovimiento(
    indiceProducto: indice,
    tipo: 'Entrada',
  );
},
onSalida: () {
  _mostrarDialogoMovimiento(
    indiceProducto: indice,
    tipo: 'Salida',
  );
},
      onEditar: () async {
        final productoEditado = await Navigator.push<Producto>(
          context,
          MaterialPageRoute(
            builder: (context) => FormularioProducto(
              producto: producto,
            ),
          ),
        );

        if (productoEditado != null) {
  setState(() {
    productos[indice] = productoEditado;
  });

  await _guardarProductos();
}
      },
      onEliminar: () async {
        final confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar producto'),
            content: Text(
              '¿Estás seguro de eliminar ${producto.nombre}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );

        if (confirmar == true) {
  setState(() {
    productos.remove(producto);
  });

  await _guardarProductos();

if (!mounted) return;

ScaffoldMessenger.of(this.context).showSnackBar(
  SnackBar(
    content: Text('${producto.nombre} eliminado correctamente'),
    backgroundColor: const Color(0xFF159A80),
  ),
);
}
      },
    );
  },
),
const SizedBox(height: 25),

const Text(
  'Historial de movimientos',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF18233D),
  ),
),

const SizedBox(height: 12),
Wrap(
  spacing: 8,
  children: ['Todos', 'Entradas', 'Salidas'].map((filtro) {
    final seleccionado = filtroMovimientos == filtro;

    return ChoiceChip(
      label: Text(filtro),
      selected: seleccionado,
      onSelected: (valor) {
        setState(() {
          filtroMovimientos = filtro;
        });
      },
      selectedColor: const Color(0xFF2457C5),
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : Colors.blueGrey,
        fontWeight: FontWeight.w600,
      ),
    );
  }).toList(),
),

const SizedBox(height: 12),
if (cargandoMovimientos)
  const Center(
    child: CircularProgressIndicator(),
  )
else if (movimientos.isEmpty)
  Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 28,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFE8ECF4),
      ),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE7EEFF),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            size: 32,
            color: Color(0xFF2457C5),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '¡Todo está tranquilo!',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF18233D),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Cuando registres entradas o salidas de productos, aparecerán aquí.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
            height: 1.5,
          ),
        ),
      ],
    ),
  )
else
  ...movimientos
      .where((movimiento) {
        if (filtroMovimientos == 'Entradas') {
          return movimiento.tipo == 'Entrada';
        }

        if (filtroMovimientos == 'Salidas') {
          return movimiento.tipo == 'Salida';
        }

        return true;
      })
      .map((movimiento) {
    final esEntrada = movimiento.tipo == 'Entrada';
   
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: esEntrada
                  ? const Color(0xFFE4F6EC)
                  : const Color(0xFFFFF0DB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              esEntrada
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: esEntrada ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.nombreProducto,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
               Wrap(
  spacing: 8,
  runSpacing: 5,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: esEntrada
            ? const Color(0xFFE4F6EC)
            : const Color(0xFFFFF0DB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        movimiento.tipo,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: esEntrada ? Colors.green : Colors.orange,
        ),
      ),
    ),
    Text(
      '${movimiento.fecha.day.toString().padLeft(2, '0')}/${movimiento.fecha.month.toString().padLeft(2, '0')}/${movimiento.fecha.year} · ${movimiento.fecha.hour.toString().padLeft(2, '0')}:${movimiento.fecha.minute.toString().padLeft(2, '0')}',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.blueGrey,
      ),
    ),
  ],
),
              ],
            ),
          ),
          Text(
            '${esEntrada ? '+' : '-'}${movimiento.cantidad} uds.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: esEntrada ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }),
            const SizedBox(height: 20),
            const Text(
              'Los datos mostrados son de ejemplo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
onPressed: () async {
  final nuevoProducto = await Navigator.push<Producto>(
    context,
    MaterialPageRoute(
      builder: (context) => const FormularioProducto(),
    ),
  );

  if (nuevoProducto != null) {
  setState(() {
    productos.add(nuevoProducto);
  });

  await _guardarProductos();
}
},
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto'),
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _TarjetaResumen({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 27),
          const SizedBox(height: 14),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF18233D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onEntrada;
final VoidCallback onSalida;

  const _TarjetaProducto({
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
    required this.onEntrada,
    required this.onSalida,
  });

  @override
  Widget build(BuildContext context) {
    final stockBajo = producto.cantidad <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              producto.icono,
              color: const Color(0xFF2457C5),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
  producto.nombre,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  ),
),
                const SizedBox(height: 4),
                Text(
                  producto.categoria,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${producto.precio.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF2457C5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFFE7EEFF),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text(
    '${producto.cantidad} uds.',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF2457C5),
      fontSize: 12,
    ),
  ),
),
              const SizedBox(height: 6),
              if (stockBajo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0DB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Icon(
      Icons.warning_amber_rounded,
      size: 12,
      color: Color(0xFF9C5A00),
    ),
    const SizedBox(width: 4),
    const Text(
      'Stock bajo',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9C5A00),
      ),
    ),
  ],
),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (opcion) {
  if (opcion == 'entrada') {
    onEntrada();
  } else if (opcion == 'salida') {
    onSalida();
  } else if (opcion == 'editar') {
    onEditar();
  } else if (opcion == 'eliminar') {
    onEliminar();
  }
},
            itemBuilder: (context) => [
              const PopupMenuItem(
  value: 'entrada',
  child: Row(
    children: [
      Icon(Icons.add_circle_outline, color: Colors.green),
      SizedBox(width: 8),
      Text('Registrar entrada'),
    ],
  ),
),
const PopupMenuItem(
  value: 'salida',
  child: Row(
    children: [
      Icon(Icons.remove_circle_outline, color: Colors.orange),
      SizedBox(width: 8),
      Text('Registrar salida'),
    ],
  ),
),
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class FormularioProducto extends StatefulWidget {
  final Producto? producto;

  const FormularioProducto({
    super.key,
    this.producto,
  });

  @override
  State<FormularioProducto> createState() =>
      _FormularioProductoState();
 
}

class _FormularioProductoState extends State<FormularioProducto> {
  @override
void initState() {
  super.initState();

  if (widget.producto != null) {
    nombreController.text = widget.producto!.nombre;
    categoriaController.text = widget.producto!.categoria;
    cantidadController.text = widget.producto!.cantidad.toString();
    precioController.text = widget.producto!.precio.toString();
  }
}
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final categoriaController = TextEditingController();
  final cantidadController = TextEditingController();
  final precioController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    categoriaController.dispose();
    cantidadController.dispose();
    precioController.dispose();
    super.dispose();
  }

  void guardarProducto() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombre = nombreController.text.trim();
    final categoria = categoriaController.text.trim();
    final cantidad = int.parse(cantidadController.text);
    final precio = double.parse(
      precioController.text.replaceAll(',', '.'),
    );

    final producto = Producto(
      nombre: nombre,
      categoria: categoria,
      cantidad: cantidad,
      precio: precio,
     icono: widget.producto?.icono ?? Icons.inventory_2_outlined,
    );

    Navigator.pop(context, producto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    widget.producto == null
        ? 'Registrar producto'
        : 'Editar producto',
  ),
  backgroundColor: Colors.white,
),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Icon(
  widget.producto == null
      ? Icons.add_box_outlined
      : Icons.edit_outlined,
  size: 65,
  color: const Color(0xFF2457C5),
),
              const SizedBox(height: 12),
              Text(
  widget.producto == null
      ? 'Nuevo producto'
      : 'Editar producto',
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF18233D),
  ),
),

              const SizedBox(height: 24),

              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  hintText: 'Ej. Arroz de 500 g',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Escribe el nombre del producto';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  hintText: 'Ej. Alimentos',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Escribe una categoría';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad disponible',
                  hintText: 'Ej. 20',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final cantidad = int.tryParse(valor ?? '');

                  if (cantidad == null || cantidad < 0) {
                    return 'Ingresa una cantidad entera igual o mayor a cero';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio unitario en pesos',
                  hintText: 'Ej. 2500',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final precio = double.tryParse(
                    (valor ?? '').replaceAll(',', '.'),
                  );

                  if (precio == null || precio < 0) {
                    return 'Ingresa un precio válido igual o mayor a cero';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: guardarProducto,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Guardar producto',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2457C5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

