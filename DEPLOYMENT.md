# Deploying 90 Mile Ride

The public app is now completely static. Upload the contents of this folder, including the `data` folder, to any ordinary web server. There is no Netlify setup, server function, API key, or user upload involved when the app is running.

## Generating the tide files

The repository includes `scripts/generate-static-tides.ps1`. It uses NIWA once to create one JSON file per year under `data/`, then the public app reads those files.

1. Revoke and regenerate any NIWA credentials that were shared in chat or committed anywhere.
2. Set the regenerated key in your current PowerShell session. Do not put it in a file:

   `$env:NIWA_API_KEY = "paste-your-regenerated-key-here"`

3. Run:

   `./scripts/generate-static-tides.ps1`

By default this generates only 2027, so a normal run uses a single year's data and cannot accidentally request the full 50-year range. The script requests NIWA in 31-day chunks and writes only tide predictions to the JSON file. The key is never written to the repository.

You can choose another range:

`./scripts/generate-static-tides.ps1 -StartYear 2027 -EndYear 2076`

## Publishing

Upload these items to the same directory on your web server:

- `index.html`
- `data/2027.json` through `data/2076.json`

Do not open `index.html` using a `file://` URL. Use a web server, because browsers block local JSON fetches from some file previews. No server-side programming is required.
