const NIWA_ENDPOINT = "https://api.niwa.co.nz/tides/data";

exports.handler = async event => {
  const apiKey = process.env.NIWA_API_KEY;
  const params = event.queryStringParameters || {};
  const startDate = params.startDate;
  const numberOfDays = Number(params.numberOfDays || 14);

  if (!apiKey) {
    return json(500, { error: "The tide service is not configured yet." });
  }

  if (!/^\d{4}-\d{2}-\d{2}$/.test(startDate || "") || !Number.isInteger(numberOfDays) || numberOfDays < 1 || numberOfDays > 31) {
    return json(400, { error: "Invalid tide forecast request." });
  }

  const url = new URL(NIWA_ENDPOINT);
  url.searchParams.set("lat", "-34.537");
  url.searchParams.set("long", "172.736");
  url.searchParams.set("numberOfDays", String(numberOfDays));
  url.searchParams.set("startDate", startDate);
  url.searchParams.set("datum", "LAT");

  try {
    const response = await fetch(url, { headers: { "x-apikey": apiKey } });
    const body = await response.text();

    if (!response.ok) {
      return json(response.status, { error: "NIWA rejected the tide request." });
    }

    const data = JSON.parse(body);
    const predictions = (data.predictions || data.data || [])
      .map(item => ({
        time: item.timestamp || item.time || item.dateTime,
        height: Number(item.value ?? item.height)
      }))
      .filter(item => item.time && Number.isFinite(item.height));

    return json(200, { predictions });
  } catch (error) {
    return json(502, { error: "The tide service is temporarily unavailable." });
  }
};

function json(statusCode, body) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "public, max-age=1800"
    },
    body: JSON.stringify(body)
  };
}