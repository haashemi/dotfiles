pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Installed apps for the launcher, ranked by how often each was launched.
// DesktopEntries reads the same XDG `applications` dirs as fuzzel and already
// drops NoDisplay/Hidden entries. Counts live in
// ~/.local/share/aurora/launcher/usage.json; the first start seeds them from
// fuzzel's ~/.cache/fuzzel.
Singleton {
    id: root

    readonly property list<string> terminal: ["alacritty", "-e"]

    readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || `${Quickshell.env("HOME")}/.local/share`
    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME") || `${Quickshell.env("HOME")}/.cache`

    // DesktopEntries scans lazily on first access; binding it here starts the
    // scan at startup instead of on the first open.
    readonly property var apps: DesktopEntries.applications.values

    // Desktop entry id (without .desktop) -> launch count.
    property var counts: ({})

    // Apps matching `query`: a word of the name starting with it first, then a
    // word of the generic name or keywords, then a substring of any field (also
    // id and exec), then a fuzzy match on the name. Within each tier the most
    // launched come first.
    function search(query: string): list<var> {
        const q = query.trim().toLowerCase();
        const ranked = [];
        for (const entry of apps) {
            const tier = q === "" ? 0 : rank(entry, q);
            if (tier >= 0)
                ranked.push({
                    entry: entry,
                    tier: tier,
                    count: counts[entry.id] ?? 0
                });
        }
        ranked.sort((a, b) => a.tier - b.tier || b.count - a.count || a.entry.name.localeCompare(b.entry.name));
        return ranked.map(item => item.entry);
    }

    function rank(entry: DesktopEntry, q: string): int {
        const name = entry.name.toLowerCase();
        const wordStarts = text => text.toLowerCase().split(/[\s\-_.;,]+/).some(word => word.startsWith(q));
        if (wordStarts(name))
            return 0;

        const extra = [entry.genericName, entry.keywords.join(" ")].join(" ");
        if (wordStarts(extra))
            return 1;

        const fields = [name, extra, entry.id, entry.execString].join("\n").toLowerCase();
        if (fields.includes(q))
            return 2;

        let i = 0;
        for (const c of name) {
            if (c === q[i])
                i++;
        }
        return i === q.length ? 3 : -1;
    }

    function launch(entry: DesktopEntry): void {
        counts = Object.assign({}, counts, {
            [entry.id]: (counts[entry.id] ?? 0) + 1
        });
        save();

        if (entry.runInTerminal) {
            Quickshell.execDetached({
                command: [...terminal, ...entry.command],
                workingDirectory: entry.workingDirectory
            });
        } else {
            entry.execute();
        }
    }

    function save(): void {
        usage.setText(JSON.stringify(counts, null, 2) + "\n");
    }

    FileView {
        id: usage
        path: `${root.dataHome}/aurora/launcher/usage.json`
        printErrors: false

        onLoaded: {
            try {
                root.counts = JSON.parse(text());
            } catch (e) {
                console.warn(`launcher: ignoring unreadable ${path}: ${e}`);
            }
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                fuzzelCache.path = `${root.cacheHome}/fuzzel`;
        }
    }

    // One-time import; fuzzel's cache is "<id>.desktop|<count>" per line.
    FileView {
        id: fuzzelCache
        printErrors: false

        onLoaded: {
            const seeded = {};
            for (const line of text().split("\n")) {
                const [file, count] = line.split("|");
                if (file && count > 0)
                    seeded[file.replace(/\.desktop$/, "")] = Number(count);
            }
            root.counts = seeded;
            root.save();
        }
        onLoadFailed: root.save()
    }
}
