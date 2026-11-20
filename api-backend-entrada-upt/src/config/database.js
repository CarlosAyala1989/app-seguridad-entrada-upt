import mariadb from 'mariadb';
import { entorno } from './env.js';

// Grupo compartido de conexiones para reutilizar conexiones a MariaDB entre operaciones.
export const grupoConexiones = mariadb.createPool({
  host: entorno.db.host,
  port: entorno.db.port,
  database: entorno.db.database,
  user: entorno.db.user,
  password: entorno.db.password,
  connectTimeout: entorno.db.connectTimeout,
  allowPublicKeyRetrieval: entorno.db.allowPublicKeyRetrieval,
  cachingRsaPublicKey: entorno.db.cachingRsaPublicKey,
  connectionLimit: entorno.db.connectionLimit,
  // Lima no aplica horario de verano; el offset evita depender de tablas TZ SQL.
  timezone: '-05:00',
  acquireTimeout: 10_000,
  insertIdAsNumber: true,
  bigIntAsNumber: true,
});

// Comprueba la disponibilidad mediante una consulta mínima; la conexión se devuelve al grupo incluso si falla.
export async function verificarConexionBaseDatos() {
  let conexion;

  try {
    conexion = await grupoConexiones.getConnection();
    await conexion.query('SELECT 1 AS conectado');
  } finally {
    conexion?.release();
  }
}
