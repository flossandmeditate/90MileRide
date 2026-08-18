# Deploying 90 Mile Ride

This app uses a Netlify Function so the NIWA credential never reaches the browser.

## Netlify setup

1. Revoke and regenerate any NIWA credentials that were shared in chat or committed anywhere.
2. Create a Netlify site connected to this repository.
3. Set the build publish directory to `.`. The included `netlify.toml` already configures this and the functions directory.
4. In Netlify, open **Site configuration -> Environment variables** and add:

   - Name: `NIWA_API_KEY`
   - Value: the regenerated NIWA API key

5. Deploy the site.
6. Open the deployed site and select a date range. The page calls `/.netlify/functions/tides`; the function calls NIWA with the private key.

## Local testing

To test the function locally, run the site with Netlify tooling (not plain file preview):

1. Install Netlify CLI.
2. In this folder run `netlify dev`.
3. Open the local URL shown by Netlify and test the planner there.

If you open `index.html` directly or with a generic static preview, `/.netlify/functions/tides` will not exist and the app will show an endpoint unavailable message.

The NIWA secret is not needed by the Tide API request shown in the developer documentation and should not be added to the site or repository.
