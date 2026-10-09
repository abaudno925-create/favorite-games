.pragma library

// Favorite Games — общая логика плагина, только данные (никаких синглтонов QML здесь).
// Игра — это { id, name, command, appId, icon, iconName, terminal }:
//   command   командная строка для `sh -c` (steam, lutris, wine, эмулятор — что угодно)
//   appId     id .desktop-файла: запуск идёт через оболочку, как из «Пуска», — игра
//             получает правильное окружение; если .desktop пропал, останется command
//   icon      имя пиксельного значка (widgets/Icons.js) для пиксельной темы
//   iconName  имя значка из темы или путь к картинке (для обеих тем)

// Чистит и доводит список до рабочего вида: без имени и без способа запуска — не строка.
// id назначается, только если его нет, и всегда уникальный (по нему строку находят).
function normalize(list) {
    const out = [];
    const taken = {};
    for (const raw of (list || [])) {
        if (!raw || typeof raw !== "object")
            continue;
        const name = String(raw.name === undefined ? "" : raw.name).trim();
        const command = String(raw.command === undefined ? "" : raw.command).trim();
        const appId = String(raw.appId === undefined ? "" : raw.appId).trim();
        if (!name || (!command && !appId))
            continue;
        let id = String(raw.id === undefined ? "" : raw.id).trim() || slug(name);
        while (taken[id])
            id += "-";
        taken[id] = true;
        out.push({
            "id": id,
            "name": name,
            "command": command,
            "appId": appId,
            "icon": String(raw.icon === undefined ? "" : raw.icon).trim(),
            "iconName": String(raw.iconName === undefined ? "" : raw.iconName).trim(),
            "terminal": !!raw.terminal
        });
    }
    return out;
}

// «Hollow Knight ♡» → «hollow-knight»
function slug(text) {
    const s = String(text || "").toLowerCase().replace(/[^\p{L}\p{N}]+/gu, "-").replace(/^-+|-+$/g, "");
    return s || "game";
}

// id, которого ещё нет в списке
function uniqueId(list, wanted) {
    const taken = (list || []).map(g => g.id);
    let id = wanted || "game";
    while (taken.indexOf(id) >= 0)
        id += "-";
    return id;
}

// что показать под именем: команда или .desktop
function subtitle(g) {
    if (!g)
        return "";
    return g.command || g.appId || "";
}

// Значок строки: картинка темы / .desktop, иначе пиксельный.
function usesAppIcon(g) {
    return !!g && (g.iconName !== "" || g.appId !== "");
}

// Пиксельный значок по умолчанию.
function pixelIcon(g) {
    return (g && g.icon) || "gamepad";
}

// Игра ли это: в категориях .desktop ищем «Game» (Game, ActionGame, RolePlaying…).
function isGameApp(app) {
    if (!app)
        return false;
    let cats = app.categories;
    if (cats && typeof cats.join === "function")
        cats = cats.join(";");
    const parts = String(cats || "").split(";").map(s => s.trim().toLowerCase());
    return parts.some(c => c.indexOf("game") >= 0);
}

// Насколько строка подходит запросу (лаунчер): -1 — нет.
function score(g, q) {
    const query = String(q || "").trim().toLowerCase();
    if (!query)
        return 60;
    const name = String(g.name || "").toLowerCase();
    if (name.startsWith(query))
        return 100 - name.length / 10;
    if (name.includes(query))
        return 70 - name.indexOf(query) / 10;
    return -1;
}

function search(list, q) {
    const query = String(q || "").trim().toLowerCase();
    return (list || []).map(g => ({ "g": g, "s": score(g, query) })).filter(r => r.s > 0).sort((a, b) => b.s - a.s).map(r => r.g);
}

// Уже запущено? У окон niri есть id .desktop (app_id, «.desktop» бывает и есть и нет)
// и заголовок. Сверяем id точно, заголовок — по началу: «Hades» совпадёт с
// «Hades 64-bit…», а «Hollow Knight» — с самим собой.
function isRunning(g, windows) {
    if (!g || !windows || !windows.length)
        return false;
    const name = String(g.name || "").toLowerCase();
    const appId = String(g.appId || "").toLowerCase().replace(/\.desktop$/, "");
    for (const w of windows) {
        const id = String((w && w.app_id) || "").toLowerCase();
        const title = String((w && w.title) || "").toLowerCase();
        if (appId && id === appId)
            return true;
        if (appId && appId.length >= 4 && (id.startsWith(appId) || appId.startsWith(id)))
            return true;
        if (name.length >= 3 && title.startsWith(name))
            return true;
    }
    return false;
}
