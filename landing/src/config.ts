const env = import.meta.env;

const withFallback = (value: string | undefined, fallback = "#zbt") =>
  value && value.trim().length > 0 ? value : fallback;

const defaultApkUrl =
  "https://82soys46zdxg7yh3.public.blob.vercel-storage.com/RybnoeMesto_0.1.0-beta.3_v547.apk";
const defaultTelegramUrl = "https://t.me/+6jhVn0EWIPE0MzE8";

export const links = {
  apk: withFallback(env.NEXT_PUBLIC_APK_URL, defaultApkUrl),
  telegram: withFallback(env.NEXT_PUBLIC_TELEGRAM_URL, defaultTelegramUrl),
  bugReport: withFallback(env.NEXT_PUBLIC_BUG_REPORT_URL, defaultTelegramUrl),
  vk: withFallback(env.NEXT_PUBLIC_VK_URL),
  youtube: withFallback(env.NEXT_PUBLIC_YOUTUBE_URL),
  privacy: withFallback(env.NEXT_PUBLIC_PRIVACY_URL),
};

export const externalLinkProps = (href: string) => {
  const isExternal = /^https?:\/\//i.test(href);

  return {
    href,
    target: isExternal ? "_blank" : undefined,
    rel: isExternal ? "noreferrer" : undefined,
  };
};
