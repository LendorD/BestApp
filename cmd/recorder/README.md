# cs2-grenade-recorder

Local CLI utility for recording CS2 grenade throw and landing coordinates from `console.log`.

It does not read CS2 process memory. It only tails the log file written by the game console.

## CS2 Setup

Open the CS2 developer console and enable console logging:

```text
con_logfile "console.log"
```

Bind `getpos` to a key:

```text
bind "F9" "getpos"
```

Typical Windows log path:

```text
C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log
```

If your Steam library is on another disk, use that library path instead.

## Run

From the repository root:

```powershell
go run ./cmd/recorder -log-path "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log" -map de_mirage -type smoke
```

Or from this folder:

```powershell
go run main.go -log-path "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log" -map de_mirage -type smoke
```

You can also set the log path once:

```powershell
$env:CS2_CONSOLE_LOG="C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log"
go run ./cmd/recorder -map de_mirage -type smoke
```

## Recording Flow

1. Start the recorder.
2. Stand at the throw position in CS2 and press `F9`.
3. Move to the landing position and press `F9` again.
4. Confirm JSON export.

The first `getpos` line becomes `throw_position` and `view_angle`.
The second `getpos` line becomes `landing_position`.

## Flags

```text
-log-path   path to CS2 console.log
-map        map name for exported JSON, default de_mirage
-type       grenade type, default smoke
-out        export path, default grenade.json
-debounce   duplicate getpos debounce window, default 800ms
-yes        export JSON without confirmation
```

## Output

```json
{
  "map": "de_mirage",
  "grenade_type": "smoke",
  "throw_position": {
    "x": -1032.42,
    "y": -789.12,
    "z": -167.97
  },
  "view_angle": {
    "pitch": -18.4,
    "yaw": 91.2
  },
  "landing_position": {
    "x": -820.11,
    "y": -1020.44,
    "z": -160.97
  }
}
```
