// docs/_static/js/timezone.js
document.addEventListener("DOMContentLoaded", function() {
  const element = document.getElementById("community-call-time");
  if (!element) return;

  // Base info
  const zurichZone = "Europe/Zurich"; // covers CET/CEST
  const targetWeekdayShort = "Wed";   // weekday short form returned by en-GB formatter
  const targetHour = 15;              // 3 PM Zurich time

  // Helper: find next Wednesday 15:00 in Zurich time
  function nextCommunityCallUTC() {
    const now = new Date();
    let candidate = new Date(now);
    candidate.setUTCMinutes(0, 0, 0, 0);

    const maxHours = 14 * 24; // 14 days safety cap
    for (let i = 0; i < maxHours; i++) {
      const check = new Date(candidate.getTime() + i * 3600000);
      let parts = [];
      try {
        parts = new Intl.DateTimeFormat("en-GB", {
          timeZone: zurichZone,
          weekday: "short",
          hour: "2-digit",
          hour12: false
        }).formatToParts(check);
      } catch (e) {
        // Intl might throw in very old environments; fallback to continue loop
        continue;
      }

      const weekdayPart = parts.find(p => p.type === "weekday");
      const hourPart = parts.find(p => p.type === "hour");
      const weekday = weekdayPart ? weekdayPart.value : null;
      const hour = hourPart ? parseInt(hourPart.value, 10) : NaN;

      if (weekday === targetWeekdayShort && hour === targetHour) return check;
    }
    // fallback: return "now" if not found (rare)
    return now;
  }

  function formatForZone(date, zone, locale) {
    try {
      return new Intl.DateTimeFormat(locale || undefined, {
        timeZone: zone,
        weekday: "long",
        day: "numeric",
        month: "long",
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
        timeZoneName: "short"
      }).format(date);
    } catch (e) {
      return date.toString();
    }
  }

  const targetUTC = nextCommunityCallUTC();

  const zurichTime = formatForZone(targetUTC, zurichZone, "en-GB");
  const userTZ = Intl.DateTimeFormat().resolvedOptions().timeZone || "your timezone";
  const localTime = formatForZone(targetUTC, userTZ);

  element.textContent = `Community calls are held on ${zurichTime} — Your local time: ${localTime}`;
});
