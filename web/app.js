// o-link placement NUI: hint card renderer + gizmo mouse/keyboard capture.
// Driven one-way by SendNUIMessage; gizmo input streams back through the
// olinkGizmo* NUI callbacks registered in modules/placement/gizmo/client.lua.

const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'o-link'

function post(name, data) {
    return fetch(`https://${RES}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
    })
}

// Stroke-based inline icons (feather-style) — no icon font without a build step.
const ICONS = {
    pin: '<path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>',
    user: '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
    car: '<path d="M3 16v-4l2-5h10l4 5h2v4h-1"/><circle cx="7" cy="16.5" r="1.8"/><circle cx="17" cy="16.5" r="1.8"/><path d="M9 16.5h6"/>',
    screen: '<rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>',
    polygon: '<polygon points="12 2 22 8.5 18 21 6 21 2 8.5"/>',
    cube: '<path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/>',
}

const card = document.getElementById('hint-card')
const iconEl = document.getElementById('hint-icon')
const labelEl = document.getElementById('hint-label')
const phaseEl = document.getElementById('hint-phase')
const linesEl = document.getElementById('hint-lines')
const capture = document.getElementById('gizmo-capture')

// ---- hint card ----

let hideTimer = null

function renderHints(data) {
    if (!data || data.visible === false) {
        card.classList.remove('visible')
        if (!hideTimer) {
            hideTimer = setTimeout(() => {
                hideTimer = null
                card.style.display = 'none'
            }, 240)
        }
        return
    }
    if (hideTimer) {
        clearTimeout(hideTimer)
        hideTimer = null
    }
    const wasHidden = card.style.display !== 'block'
    card.style.display = 'block'
    if (wasHidden) void card.offsetHeight // let the transition play from the hidden state

    iconEl.innerHTML = ICONS[data.icon] || ICONS.pin
    labelEl.textContent = data.label || 'Placement'
    phaseEl.textContent = data.phase || 'Aim'
    phaseEl.classList.toggle('hot', !!data.phaseHot)

    linesEl.replaceChildren(...(data.lines || []).map((line) => {
        const row = document.createElement('span')
        line.forEach((seg, i) => {
            const key = document.createElement('b')
            key.className = 'tone-' + (seg.tone || 'neutral')
            key.textContent = seg.key
            row.appendChild(key)
            row.appendChild(document.createTextNode(' ' + (seg.desc || '')))
            if (i < line.length - 1) {
                const sep = document.createElement('span')
                sep.className = 'sep'
                sep.textContent = ' • '
                row.appendChild(sep)
            }
        })
        return row
    }))
    card.classList.add('visible')
}

// ---- gizmo capture ----

let gizmoOn = false
let raf = null
let pending = null
let inflight = false

function norm(e) {
    return { x: e.clientX / window.innerWidth, y: e.clientY / window.innerHeight }
}

function flush() {
    raf = null
    if (pending && !inflight) {
        const p = pending
        pending = null
        inflight = true
        post('olinkGizmoCursor', p).finally(() => { inflight = false })
    }
}

window.addEventListener('mousemove', (e) => {
    if (!gizmoOn) return
    pending = norm(e)
    if (!raf) raf = requestAnimationFrame(flush)
})

window.addEventListener('mousedown', (e) => {
    if (!gizmoOn) return
    if (e.button === 0) {
        post('olinkGizmoGrab', norm(e))
    } else if (e.button === 2) {
        // RMB: hand the camera back to the game without ending the session.
        post('olinkGizmoLook', {})
    }
})

window.addEventListener('mouseup', (e) => {
    if (!gizmoOn || e.button !== 0) return
    post('olinkGizmoRelease', {})
})

window.addEventListener('contextmenu', (e) => {
    if (gizmoOn) e.preventDefault()
})

window.addEventListener('wheel', (e) => {
    if (!gizmoOn) return
    e.preventDefault() // keep Ctrl+wheel from zooming the CEF page
    post('olinkGizmoWheel', { delta: e.deltaY < 0 ? 1 : -1, fine: e.shiftKey, ctrl: e.ctrlKey })
}, { passive: false })

const GIZMO_KEYS = ['Enter', 'Escape', 'Backspace', 'Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight']

window.addEventListener('keydown', (e) => {
    if (!gizmoOn) return
    const key = e.key === ' ' ? 'Space' : e.key
    if (!GIZMO_KEYS.includes(key)) return
    e.preventDefault()
    // Arrows keep browser auto-repeat (hold to nudge); one-shot keys don't.
    if (e.repeat && !key.startsWith('Arrow')) return
    post('olinkGizmoKey', { key, ctrl: e.ctrlKey, shift: e.shiftKey })
})

function setGizmo(enabled) {
    enabled = !!enabled
    if (gizmoOn && !enabled) post('olinkGizmoRelease', {})
    gizmoOn = enabled
    capture.classList.toggle('on', enabled)
    if (!enabled) {
        pending = null
        if (raf) {
            cancelAnimationFrame(raf)
            raf = null
        }
    }
}

// ---- message router ----

window.addEventListener('message', (e) => {
    const msg = e.data
    if (!msg || !msg.action) return
    if (msg.action === 'olink:placement:hints') {
        renderHints(msg.data)
    } else if (msg.action === 'olink:placement:gizmo') {
        setGizmo(msg.data && msg.data.enabled)
    }
})
