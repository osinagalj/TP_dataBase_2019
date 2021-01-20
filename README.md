# WMS Tandil

El Trabajo Práctico Especial consiste en la resolución de un conjunto de controles y servicios sobre una base de datos que mantiene un sistema de la empresa “WMS Tandil” según las consignas que se indican en la sección “Pautas de Desarrollo”. El esquema inicial es provisto por la Cátedra.

# DEFINICIÓN DE WMS Tandil (Warehouse Management System)

La Empresa “WMS Tandil” maneja un depósito de almacenamiento de pallets. Estos se guardan en estanterías a lo largo del depósito, que están divididas en filas y a su vez estas filas se dividen en posiciones; en cada posición se puede guardar un único pallet al mismo tiempo. Cada posición se identifica por la estantería, la fila y su número de posición dentro de la fila; también el depósito maneja un número único de posición. Cada fila tiene un alto y el peso máximo que puede soportar.
Las posiciones se alquilan a un cliente a partir de una fecha dada y en dos modalidades para la fecha de fin del alquiler (se especifica por el tipo de alquiler): una que es fija y otra que inicialmente es indefinida y se establece cuando se retira la mercadería. El cliente no puede retirar la mercadería si tiene un saldo negativo en la cuenta corriente. Al realizarse el alquiler las posiciones involucradas, pasan a estar en el estado de “Reservado”.
Cuando ingresa un pallet, existe un movimiento de entrada y se le asigna una posición de las que el cliente tiene alquiladas (de las posiciones que tiene reservadas ) y se marca como en estado “ocupada” dicha posición. También se registran los movimientos de egreso y los movimientos internos, los cuales se hacen porque por alguna razón se necesita cambiar el pallet de posición (por ejemplo, porque el cliente está próximo a buscar el mismo y se trae a una posición más cercana a la zona de armado). Cada movimiento debe hacer referencia al movimiento anterior en caso de que corresponda: un movimiento interno hace referencia a un movimiento de entrada o a otro Interno y un movimiento de salida puede hacer referencia a un movimiento de entrada o a uno interno.
El depósito está dividido en zonas, las mismas van cambiando en el tiempo. Cuando se produce un cambio de zona, el sistema debería poder identificar qué pallets cambiaron de zona  y proceder a generar una lista de cambios.
El sistema debe manejar la cuenta corriente de los clientes, con sus débitos (alquileres) y créditos (pagos). Cada pago tiene un responsable (del lado de la empresa) que es empleado administrativo del área de atención al cliente, no es un empleado del depósito o de otra área.

#Esquema
<img src="https://raw.githubusercontent.com/osinagalj/TP_dataBase_2019/master/Esquema.png" />

#Resoluciones

## Restricciones

B1.3: Controlar que el movimiento a insertar sea el último, tanto en orden
como cronológicamente (respecto del mismo pallet)

B2.2: Mantener actualizada automáticamente la cantidad de posiciones
alquiladas de cada cliente.

## Servicios 

C1.1: Generar una lista de las estanterías que en este momento tienen más
de cierto porcentaje (configurable) de las posiciones ocupadas.

C2.3 Indicar cuál es la próxima fecha en que habrá disponibilidad de espacio,
junto con la cantidad de posiciones que estarán disponibles para alquilar.

C3: Diariamente se debe actualizar la Cuenta Corriente de cada cliente con
los alquileres que tiene activos, agregando un movimiento de débito (importe
negativo) en la cuenta corriente del mismo.

## Vistas
D1.1: Listar los datos de todos los clientes junto con el último movimiento de
pago de mayor importe que cada uno de éstos realizó en los últimos 12
meses, en el caso que corresponda.

D2.1: Listar todos los datos de las posiciones de la fila número 5 en adelante
que nunca han sido alquiladas.

