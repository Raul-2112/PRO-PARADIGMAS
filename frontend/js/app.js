// Máquina de estados de la consulta: cada respuesta del backend es un "paso".
const $ = (sel) => document.querySelector(sel);
const NIVELES = {
  emergencia: 'Emergencia: llama al 123 o ve a urgencias.',
  urgente: 'Urgente: busca atención médica antes de 24 horas.',
  cita_prioritaria: 'Cita prioritaria: pide una cita médica pronto.',
  autocuidado: 'Autocuidado en casa: vigila tus síntomas y consulta si empeoran.',
};
const VALORES = { si: 'Sí', no: 'No', nose: 'No sé' };

let consultaId = null;
let catalogo = {};            // id -> etiqueta
let seleccionados = new Set();
let respuestas = {};          // sintoma -> valor (lo que el usuario respondió)

function hablar(texto, estado) {
  $('#subtitulo').textContent = texto;
  if (estado) $('#avatar').dataset.estado = estado;
}

function mostrar(...ids) {
  for (const s of ['#sec-paciente', '#sec-sintomas', '#sec-pregunta', '#sec-emergencia', '#sec-resultado']) {
    $(s).classList.toggle('oculto', !ids.includes(s));
  }
}

async function iniciar() {
  consultaId = (await Api.nuevaConsulta()).id;
  seleccionados = new Set();
  respuestas = {};
  $('#form-paciente').reset();
  $('#texto-sintomas').value = '';
  $('#explicacion').innerHTML = '';
  $('#sec-estado').classList.add('oculto');
  mostrar('#sec-paciente');
  hablar('Hola, soy la Dra. Lia. Primero, cuéntame un poco sobre ti.', 'saludo');
  if (!Object.keys(catalogo).length) {
    const lista = await Api.catalogo();
    const cont = $('#chips');
    cont.innerHTML = '';
    for (const s of lista) {
      catalogo[s.id] = s.etiqueta;
      const b = document.createElement('button');
      b.type = 'button';
      b.className = 'chip';
      b.textContent = s.etiqueta;
      b.onclick = () => {
        b.classList.toggle('activo');
        b.classList.contains('activo') ? seleccionados.add(s.id) : seleccionados.delete(s.id);
      };
      cont.appendChild(b);
    }
  }
  document.querySelectorAll('.chip.activo').forEach((c) => c.classList.remove('activo'));
}

$('#form-paciente').onsubmit = async (e) => {
  e.preventDefault();
  const f = e.target;
  const datos = {
    edad: Number(f.edad.value),
    sexo: f.sexo.value,
    embarazo: f.embarazo.checked,
    viajes: f.zona_endemica.checked ? ['zona_endemica'] : [],
    antecedentes: [],
  };
  await Api.paciente(consultaId, datos);
  mostrar('#sec-sintomas');
  hablar('Gracias. Ahora dime qué sientes, con tus palabras o seleccionando los síntomas.', 'escuchando');
};

$('#btn-sintomas').onclick = async () => {
  const texto = $('#texto-sintomas').value.trim();
  const ids = [...seleccionados];
  ids.forEach((s) => (respuestas[s] = 'si'));
  const paso = await Api.sintomas(consultaId, ids, texto || null);
  if (paso.tipo === 'inicio') {
    $('#msg-sintomas').textContent = 'No reconocí ningún síntoma. Intenta con otras palabras o selecciónalos.';
    return;
  }
  $('#msg-sintomas').textContent = '';
  // Incluye también los síntomas que el backend reconoció en el texto libre.
  const exp = await Api.explicacion(consultaId);
  exp.respuestas.forEach((x) => (respuestas[x.sintoma] = x.valor));
  renderPaso(paso);
};

document.querySelectorAll('#sec-pregunta [data-valor]').forEach((b) => {
  b.onclick = async () => {
    const sintoma = $('#sec-pregunta').dataset.sintoma;
    respuestas[sintoma] = b.dataset.valor;
    $('#porque').textContent = '';
    renderPaso(await Api.responder(consultaId, sintoma, b.dataset.valor));
  };
});

$('#btn-porque').onclick = async () => {
  const r = await Api.porque(consultaId);
  $('#porque').textContent = r.texto;
};

$('#btn-explicacion').onclick = async () => {
  const r = await Api.explicacion(consultaId);
  const cont = $('#explicacion');
  cont.innerHTML = '';
  for (const e of r.enfermedades) {
    const d = document.createElement('div');
    const fav = e.a_favor.map((x) => `${x.etiqueta} (+${x.peso})`).join(', ') || 'ninguno';
    const con = e.en_contra.map((x) => `${x.etiqueta} (−${x.peso})`).join(', ') || 'ninguno';
    const ctx = e.contexto.map((x) => `${x.condicion} (+${x.peso})`).join(', ');
    d.innerHTML = '<h4></h4><p></p>';
    d.querySelector('h4').textContent = `${e.nombre}: CF ${(e.cf * 100).toFixed(0)} % (MB ${e.mb} − MD ${e.md})`;
    d.querySelector('p').textContent =
      `A favor: ${fav}. En contra: ${con}.` + (ctx ? ` Contexto: ${ctx}.` : '');
    cont.appendChild(d);
  }
};

$('#btn-reiniciar').onclick = iniciar;

function renderPaso(p) {
  renderEstado(p);
  if (p.tipo === 'emergencia') {
    mostrar('#sec-emergencia');
    $('#msg-emergencia').textContent = p.alarma.mensaje;
    hablar(p.alarma.mensaje, 'emergencia');
  } else if (p.tipo === 'pregunta') {
    mostrar('#sec-pregunta');
    $('#sec-pregunta').dataset.sintoma = p.pregunta.sintoma;
    $('#texto-pregunta').textContent = p.pregunta.texto;
    $('#contador').textContent = `Pregunta ${p.num_pregunta + 1} de máximo 20`;
    hablar(p.pregunta.texto, 'hablando');
  } else if (p.tipo === 'resultado') {
    mostrar('#sec-resultado');
    $('#triage').textContent = NIVELES[p.triage];
    $('#triage').className = 'triage ' + p.triage;
    const ol = $('#lista-resultado');
    ol.innerHTML = '';
    for (const h of p.hipotesis) {
      const li = document.createElement('li');
      li.innerHTML = '<strong></strong><small class="ex"></small><small class="esp"></small><small class="rec"></small>';
      li.querySelector('strong').textContent =
        `${h.sospecha ? 'Sospecha de ' : 'Posible '}${h.nombre} (${h.cie10}): ${(h.cf * 100).toFixed(0)} %`;
      li.querySelector('.ex').textContent = 'Exámenes sugeridos: ' + h.examenes.join('; ');
      li.querySelector('.esp').textContent = 'Especialista: ' + h.especialista;
      li.querySelector('.rec').textContent = h.recomendaciones.join(' ');
      ol.appendChild(li);
    }
    if (!p.hipotesis.length) ol.innerHTML = '<li>No encontré una causa probable. Consulta a tu médico si los síntomas continúan.</li>';
    hablar('Terminé. ' + NIVELES[p.triage], p.estado_avatar);
  }
}

function renderEstado(p) {
  $('#sec-estado').classList.remove('oculto');
  const ul = $('#hipotesis');
  ul.innerHTML = '';
  for (const h of p.hipotesis) {
    const li = document.createElement('li');
    li.innerHTML = '<span></span><div class="barra"><span></span></div>';
    li.querySelector('span').textContent = `${h.nombre}: ${(h.cf * 100).toFixed(0)} %`;
    li.querySelector('.barra > span').style.width = `${Math.round(h.cf * 100)}%`;
    ul.appendChild(li);
  }
  const ur = $('#respuestas');
  ur.innerHTML = '';
  for (const [s, v] of Object.entries(respuestas)) {
    const li = document.createElement('li');
    const sel = document.createElement('select');
    for (const [k, t] of Object.entries(VALORES)) sel.add(new Option(t, k, false, k === v));
    sel.onchange = async () => {             // RF10: corregir sin reiniciar
      respuestas[s] = sel.value;
      renderPaso(await Api.corregir(consultaId, s, sel.value));
    };
    li.append(document.createTextNode(catalogo[s] || s), sel);
    ur.appendChild(li);
  }
}

window.addEventListener('unhandledrejection', (e) => {
  hablar('Ocurrió un problema de conexión con el servidor: ' + e.reason.message, 'preocupada');
});

iniciar();
