// Cliente de la API JSON de MediLog (contrato en docs/api.md).
const Api = (() => {
  async function llamar(metodo, ruta, cuerpo) {
    const opciones = { method: metodo, headers: {} };
    if (cuerpo !== undefined) {
      opciones.headers['Content-Type'] = 'application/json';
      opciones.body = JSON.stringify(cuerpo);
    }
    const r = await fetch('/api/' + ruta, opciones);
    const datos = await r.json();
    if (!r.ok) throw new Error(datos.error || ('Error ' + r.status));
    return datos;
  }
  return {
    nuevaConsulta: () => llamar('POST', 'consulta', {}),
    paciente: (id, d) => llamar('POST', `consulta/${id}/paciente`, d),
    sintomas: (id, ids, texto) => llamar('POST', `consulta/${id}/sintomas`, { ids, texto }),
    responder: (id, sintoma, valor) => llamar('POST', `consulta/${id}/respuesta`, { sintoma, valor }),
    corregir: (id, sintoma, valor) => llamar('PUT', `consulta/${id}/respuesta`, { sintoma, valor }),
    porque: (id) => llamar('GET', `consulta/${id}/porque`),
    explicacion: (id) => llamar('GET', `consulta/${id}/explicacion`),
    catalogo: () => llamar('GET', 'sintomas'),
  };
})();
