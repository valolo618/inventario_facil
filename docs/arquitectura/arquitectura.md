# Arquitectura del proyecto – Inventario Fácil

## 1. Descripción general

Inventario Fácil es una aplicación desarrollada con Flutter y Dart para facilitar la gestión de productos y el control de inventarios en pequeños negocios y emprendimientos.

La aplicación permite registrar productos, modificar su información, consultar existencias y controlar los movimientos de entrada y salida de mercancía.

## 2. Tecnologías utilizadas

- **Flutter:** framework utilizado para desarrollar la interfaz de la aplicación.
- **Dart:** lenguaje de programación utilizado para implementar la lógica.
- **Shared Preferences:** mecanismo utilizado para almacenar información localmente en el dispositivo.
- **Visual Studio Code:** entorno de desarrollo utilizado para trabajar en el proyecto.

## 3. Organización de la aplicación

Actualmente, el código principal se encuentra en el archivo `lib/main.dart`.

Este archivo contiene los componentes principales de la aplicación:

- **Interfaz de usuario:** elementos visuales, pantallas, tarjetas, botones y formularios.
- **Gestión de productos:** registro, edición, consulta y eliminación de productos.
- **Control de inventario:** actualización de cantidades mediante entradas y salidas.
- **Historial de movimientos:** almacenamiento y consulta de los movimientos realizados.
- **Persistencia local:** funciones para guardar y recuperar la información mediante Shared Preferences.

## 4. Almacenamiento de información

La aplicación utiliza Shared Preferences para conservar los datos localmente.

La información de productos y movimientos se almacena mediante estructuras de datos convertidas a formato JSON.

Cuando se inicia nuevamente la aplicación, se recupera la información almacenada para mantener los registros disponibles.

## 5. Flujo general de funcionamiento

1. El usuario ingresa a la aplicación.
2. La aplicación recupera los productos y movimientos guardados.
3. El usuario puede registrar, editar o eliminar productos.
4. Puede registrar entradas y salidas de mercancía.
5. El sistema actualiza las cantidades disponibles y valida que las salidas no superen las existencias.
6. Los movimientos quedan registrados en el historial.
7. Los cambios se guardan en el almacenamiento local.

## 6. Proyección tecnológica

Como evolución del proyecto, se contempla incorporar servicios en la nube para permitir el almacenamiento remoto, la sincronización y el acceso a la información desde diferentes dispositivos.

Esta integración se considera una mejora futura y no forma parte de la implementación actual.

## 7. Conclusión

La arquitectura actual permite desarrollar las funcionalidades principales de Inventario Fácil mediante una aplicación construida con Flutter y Dart, con almacenamiento local de información. Su estructura puede evolucionar posteriormente hacia una solución con servicios en la nube.